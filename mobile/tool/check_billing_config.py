#!/usr/bin/env python3
"""Validate a production Flutter configuration without printing credential values."""
import argparse
import base64
import json
import re
from pathlib import Path
import sys
from urllib.parse import urlparse


class InvalidConfig(ValueError):
    pass


def invalid_constant(_):
    raise InvalidConfig('JSON cannot contain non-finite numbers')


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise InvalidConfig('JSON contains duplicate keys')
        result[key] = value
    return result


def load_json(path):
    try:
        return json.loads(Path(path).read_text(), object_pairs_hook=unique_object, parse_constant=invalid_constant)
    except (OSError, UnicodeError, json.JSONDecodeError):
        raise InvalidConfig('Cannot read valid JSON from the selected configuration file') from None


def identifier(value, label):
    if not isinstance(value, str) or not value.strip() or value != value.strip() or '{{' in value or 'your_' in value.lower():
        raise InvalidConfig(f'{label} requires a nonempty, non-placeholder string')
    return value


def mapping(config, key, nullable=False):
    raw = config.get(key, '{}')
    if not isinstance(raw, str):
        raise InvalidConfig(f'{key} must be a JSON object encoded as a string')
    try:
        result = json.loads(raw, object_pairs_hook=unique_object, parse_constant=invalid_constant)
    except json.JSONDecodeError:
        raise InvalidConfig(f'{key} contains invalid JSON') from None
    if not isinstance(result, dict):
        raise InvalidConfig(f'{key} must decode to an object')
    for name, value in result.items():
        identifier(name, f'{key} feature key')
        if not (nullable and value is None):
            identifier(value, f'{key} value')
    return result


def https_url(value, label, allow_public_user=False):
    identifier(value, label)
    try:
        uri = urlparse(value)
        _ = uri.port
        if uri.scheme != 'https' or not uri.hostname or (uri.username is not None and not allow_public_user) or uri.password is not None:
            raise ValueError()
        if allow_public_user and (not uri.username or not uri.path.rstrip('/')):
            raise ValueError()
    except ValueError:
        raise InvalidConfig(f'{label} requires a valid HTTPS URL with its documented public credentials only') from None


def public_supabase_key(value):
    identifier(value, 'SERVER_API_KEY')
    if value.startswith('sb_publishable_'):
        if len(value) <= len('sb_publishable_'):
            raise InvalidConfig('SERVER_API_KEY requires a complete publishable key')
        return
    if value.startswith('sb_secret_'):
        raise InvalidConfig('SERVER_API_KEY must not contain a private Supabase key')
    try:
        parts = value.split('.')
        if len(parts) != 3:
            raise ValueError()
        payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=' * (-len(parts[1]) % 4)))
        if not isinstance(payload, dict) or payload.get('role') != 'anon':
            raise ValueError()
    except (ValueError, UnicodeError):
        raise InvalidConfig('SERVER_API_KEY requires a publishable key or legacy anon JWT') from None


def validate(config, catalog, platform, supabase_dir):
    if platform not in {'android', 'ios'}:
        raise InvalidConfig('Select android or ios')
    if not isinstance(config, dict) or not isinstance(catalog, dict):
        raise InvalidConfig('Configuration and feature catalog must be JSON objects')
    if config.get('APP_ENVIRONMENT') != 'prod':
        raise InvalidConfig('Production builds require APP_ENVIRONMENT=prod')
    identifier(config.get('APP_NAME', 'Pickwell'), 'APP_NAME')
    auth = config.get('AUTH_MODE', 'disabled')
    billing = config.get('BILLING_MODE', 'disabled')
    if auth not in {'disabled', 'optional', 'required'} or billing not in {'disabled', 'revenuecat'}:
        raise InvalidConfig('Invalid AUTH_MODE or BILLING_MODE')
    for key in ['BACKEND_ENABLED', 'ONBOARDING_ENABLED', 'ONBOARDING_PAYWALL_ENABLED',
                'NOTIFICATIONS_ENABLED', 'GOOGLE_SIGN_IN_ENABLED', 'APPLE_SIGN_IN_ENABLED',
                'ANALYTICS_ENABLED', 'CRASH_REPORTING_ENABLED']:
        if key in config and not isinstance(config[key], bool):
            raise InvalidConfig(f'{key} must be a JSON boolean')
    for key in ['REVENUECAT_SECRET_API_KEY', 'SUPABASE_SERVICE_ROLE_KEY',
                'SUPABASE_SECRET_KEY', 'SUPABASE_DB_PASSWORD', 'DATABASE_URL',
                'META_API_KEY', 'META_ACCESS_TOKEN', 'REVENUECAT_WEBHOOK_AUTHORIZATION']:
        if config.get(key):
            raise InvalidConfig(f'{key} belongs only in server secrets')
    # Check supplied credentials even for integrations disabled in this build.
    if config.get('SERVER_API_KEY'):
        public_supabase_key(config['SERVER_API_KEY'])
    for key in ['REVENUECAT_ANDROID_API_KEY', 'REVENUECAT_IOS_API_KEY']:
        value = config.get(key, '')
        if not isinstance(value, str):
            raise InvalidConfig(f'{key} must be a string')
        if value.strip().startswith('sk_'):
            raise InvalidConfig(f'{key} must not contain a RevenueCat secret key')
    backend = config.get('BACKEND_ENABLED', False) or auth != 'disabled'
    if backend:
        https_url(config.get('SERVER_BASE_URL'), 'SERVER_BASE_URL')
        public_supabase_key(config.get('SERVER_API_KEY'))
    if auth != 'disabled':
        identifier(config.get('AUTH_REDIRECT_URL'), 'AUTH_REDIRECT_URL')
    if config.get('ANALYTICS_ENABLED'):
        identifier(config.get('POSTHOG_API_KEY'), 'POSTHOG_API_KEY')
        https_url(config.get('POSTHOG_HOST'), 'POSTHOG_HOST')
    if config.get('CRASH_REPORTING_ENABLED'):
        https_url(config.get('SENTRY_DSN'), 'SENTRY_DSN', allow_public_user=True)
    if config.get('ONBOARDING_PAYWALL_ENABLED') and billing != 'revenuecat':
        raise InvalidConfig('Onboarding paywall requires billing')

    if set(catalog) != {'schema_version', 'default_premium_guard', 'features', 'server'} or type(catalog['schema_version']) is not int or catalog['schema_version'] != 1:
        raise InvalidConfig('Feature catalog requires schema_version=1 and the documented fields')
    default = catalog['default_premium_guard']
    features = catalog['features']
    if default not in {'none', 'client', 'server'} or not isinstance(features, dict):
        raise InvalidConfig('Invalid default guard or features catalog')
    entitlements = mapping(config, 'FEATURE_ENTITLEMENTS', nullable=True)
    offerings = mapping(config, 'FEATURE_OFFERINGS')
    if set(entitlements) != set(features):
        raise InvalidConfig('Named FEATURE_ENTITLEMENTS keys must exactly match the feature catalog')
    if not set(offerings).issubset(features):
        raise InvalidConfig('FEATURE_OFFERINGS contains an undeclared feature')
    paid = default != 'none'
    server_ids = set()
    default_id = config.get('REVENUECAT_ENTITLEMENT_ID', 'premium')
    if default == 'server':
        server_ids.add(identifier(default_id, 'REVENUECAT_ENTITLEMENT_ID'))
    for name, feature in features.items():
        identifier(name, 'Feature catalog key')
        if not isinstance(feature, dict) or feature.get('access') not in {'free', 'premium'}:
            raise InvalidConfig('Each feature must declare free or premium access')
        if feature['access'] == 'free':
            if set(feature) != {'access'} or entitlements[name] is not None or name in offerings:
                raise InvalidConfig('Free features require a null entitlement and no paid offering/enforcement')
        else:
            if set(feature) != {'access', 'enforcement'} or feature['enforcement'] not in {'client', 'server'}:
                raise InvalidConfig('Premium features require client or server enforcement')
            if entitlements[name] is None:
                raise InvalidConfig('Premium features cannot map to a null/free entitlement')
            paid = True
            if feature['enforcement'] == 'server':
                server_ids.add(entitlements[name])
    if paid and billing != 'revenuecat':
        raise InvalidConfig('Declared premium guards require BILLING_MODE=revenuecat')
    if billing == 'revenuecat':
        key = 'REVENUECAT_IOS_API_KEY' if platform == 'ios' else 'REVENUECAT_ANDROID_API_KEY'
        value = identifier(config.get(key), key)
        prefix = 'appl_' if platform == 'ios' else 'goog_'
        if not value.startswith(prefix) or len(value) <= len(prefix):
            raise InvalidConfig(f'{key} requires the selected store public SDK key; Test Store and private keys are forbidden')
        identifier(default_id, 'REVENUECAT_ENTITLEMENT_ID')
    if not server_ids:
        if catalog['server'] is not None:
            raise InvalidConfig('Server manifest is only needed for server-protected premium features')
        return
    server = catalog['server']
    if auth == 'disabled' or not backend:
        raise InvalidConfig('Server-protected features require Supabase authentication and backend access')
    if not isinstance(server, dict) or set(server) != {'environment', 'entitlement_ids'} or server['environment'] != 'PRODUCTION':
        raise InvalidConfig('Server-protected features require a PRODUCTION server manifest')
    ids = server['entitlement_ids']
    if not isinstance(ids, list):
        raise InvalidConfig('Server entitlement_ids must be a list')
    for value in ids:
        identifier(value, 'Server entitlement ID')
    if len(ids) != len(set(ids)) or not server_ids.issubset(ids):
        raise InvalidConfig('Server manifest must include every protected entitlement without duplicates')
    root = Path(supabase_dir)
    if len(list((root / 'migrations').glob('*_subscription_entitlements.sql'))) != 1:
        raise InvalidConfig('Install the optional Supabase subscription migration before release')
    required_files = ['revenuecat-webhook/index.ts', 'revenuecat-webhook/handler.ts',
                      'refresh-entitlements/index.ts', 'premium-status/index.ts',
                      '_shared/subscription_core.ts', '_shared/subscription_runtime.ts',
                      '_shared/subscription_handlers.ts']
    if not all((root / 'functions' / file).is_file() for file in required_files):
        raise InvalidConfig('Installed Supabase subscription functions are incomplete')
    try:
        server_config = (root / 'config.toml').read_text()
    except (OSError, UnicodeError):
        raise InvalidConfig('Installed Supabase configuration is missing') from None
    for name in ['revenuecat-webhook', 'refresh-entitlements', 'premium-status']:
        blocks = re.findall(r'^[ \t]*\[functions\.' + re.escape(name) + r'\][ \t]*(?:#.*)?\n(.*?)(?=^[ \t]*\[|\Z)', server_config, re.M | re.S)
        settings = re.findall(r'^[ \t]*verify_jwt[ \t]*=(.*)$', blocks[0], re.M) if len(blocks) == 1 else []
        if len(settings) != 1 or settings[0].split('#', 1)[0].strip() != 'false':
            raise InvalidConfig('Installed subscription functions require one verify_jwt=false setting')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', required=True)
    parser.add_argument('--catalog', default='config/features.json')
    parser.add_argument('--platform', required=True, choices=['android', 'ios'])
    parser.add_argument('--supabase-dir', default='../supabase')
    args = parser.parse_args()
    try:
        validate(load_json(args.config), load_json(args.catalog), args.platform, args.supabase_dir)
    except (InvalidConfig, TypeError) as error:
        # Do not echo JSON, credential values, or parser snippets into build logs.
        print(f'Billing preflight failed: {error if isinstance(error, InvalidConfig) else "Invalid configuration value type"}', file=sys.stderr)
        return 1
    print(f'Billing preflight passed for {args.platform}. Local checks do not verify remote products or deployment.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
