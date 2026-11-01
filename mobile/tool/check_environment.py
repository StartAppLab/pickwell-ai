#!/usr/bin/env python3
"""Scan tracked/nonignored files and optionally validate Pickwell public defines.

No network calls; findings report paths, line numbers and categories, never values.
This detects known patterns, not all possible secrets or git history.
"""
import argparse
import base64
import json
from pathlib import Path
import re
import subprocess
import sys

from check_billing_config import InvalidConfig, load_json, validate


PATTERNS = {
    'private key': re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'),
    'Supabase secret key': re.compile(r'\bsb_secret_[A-Za-z0-9_-]{20,}'),
    'provider token': re.compile(r'\b(?:sk_live_|sk_test_|sk-proj-|ghp_|github_pat_)[A-Za-z0-9_-]{20,}'),
    'Meta access token': re.compile(r'\bEAA[A-Za-z0-9]{60,}'),
    'credential URL': re.compile(r'\b(?:postgres(?:ql)?|https?)://[^\s/:]+:[^\s/@]+@'),
}
JWT = re.compile(r'\beyJ[A-Za-z0-9_-]+\.([A-Za-z0-9_-]+)\.[A-Za-z0-9_-]+')


def findings(content):
    result = []
    for number, line in enumerate(content.splitlines(), 1):
        for label, pattern in PATTERNS.items():
            if pattern.search(line):
                result.append((number, label))
        for token in JWT.finditer(line):
            try:
                payload = json.loads(base64.urlsafe_b64decode(token[1] + '=' * (-len(token[1]) % 4)))
                if isinstance(payload, dict) and payload.get('role') == 'service_role':
                    result.append((number, 'service-role JWT'))
            except (ValueError, UnicodeError):
                pass
    return result


def scan(root):
    paths = subprocess.check_output(
        ['git', 'ls-files', '--cached', '--others', '--exclude-standard', '-z'], cwd=root,
    ).decode().split('\0')
    result = []
    for name in sorted(set(filter(None, paths))):
        path = root / name
        if not path.is_file() or path.is_symlink():
            continue
        try:
            content = path.read_text()
        except UnicodeError:
            continue
        result.extend((name, line, label) for line, label in findings(content))
    return result


def check_public_config(config):
    template = Path(__file__).resolve().parents[1] / 'config/app.example.json'
    if not isinstance(config, dict) or set(config) - set(load_json(template)):
        raise InvalidConfig('Public defines contain unknown fields; server secrets are forbidden')
    if findings(json.dumps(config)):
        raise InvalidConfig('Known private credential pattern in public defines')
    if config.get('APP_ENVIRONMENT') not in {'dev', 'stg', 'prod'}:
        raise InvalidConfig('Select a dev, stg, or prod environment')
    if config.get('AUTH_MODE') != 'optional' or config.get('BACKEND_ENABLED') is not True:
        raise InvalidConfig('Pickwell requires optional auth and enabled backend')
    if config.get('BILLING_MODE') != 'disabled':
        raise InvalidConfig('Pickwell billing must remain disabled')
    for key in ['NOTIFICATIONS_ENABLED', 'ONBOARDING_ENABLED', 'ONBOARDING_PAYWALL_ENABLED',
                'ANALYTICS_ENABLED', 'CRASH_REPORTING_ENABLED',
                'GOOGLE_SIGN_IN_ENABLED', 'APPLE_SIGN_IN_ENABLED']:
        if config.get(key) is not False:
            raise InvalidConfig('Deferred Pickwell integrations must remain disabled')
    # Reuse the release validator's credential/type checks without changing the file.
    catalog = {'schema_version': 1, 'default_premium_guard': 'none', 'features': {}, 'server': None}
    for platform in ['android', 'ios']:
        validate({**config, 'APP_ENVIRONMENT': 'prod'}, catalog, platform, Path('/unused'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', help='Ignored public Flutter JSON file to validate')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    try:
        hits = scan(root)
        for name, line, label in hits:
            print(f'{name}:{line}: {label} detected (value suppressed)', file=sys.stderr)
        if hits:
            return 1
        if args.config:
            check_public_config(load_json(args.config))
    except (InvalidConfig, OSError, subprocess.CalledProcessError, TypeError, ValueError) as error:
        message = str(error) if isinstance(error, InvalidConfig) else 'Unable to complete environment check'
        print(f'Environment check failed: {message}', file=sys.stderr)
        return 1
    print('Known-secret pattern scan passed (tracked and nonignored files; not git history).')
    if args.config:
        print('Public config preflight passed; live connectivity and authorization are unverified.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
