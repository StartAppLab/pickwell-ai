import copy
import base64
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('billing_check', Path(__file__).with_name('check_billing_config.py'))
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)
ROOT = Path(__file__).resolve().parents[1]


def free_config():
    return {'APP_ENVIRONMENT': 'prod', 'APP_NAME': 'Consumer App', 'BILLING_MODE': 'disabled'}


def empty_catalog():
    return {'schema_version': 1, 'default_premium_guard': 'none', 'features': {}, 'server': None}


def paid_config():
    return {**free_config(), 'BILLING_MODE': 'revenuecat',
            'REVENUECAT_ANDROID_API_KEY': 'goog_public', 'REVENUECAT_IOS_API_KEY': 'appl_public',
            'REVENUECAT_ENTITLEMENT_ID': 'premium', 'FEATURE_ENTITLEMENTS': '{}', 'FEATURE_OFFERINGS': '{}'}


class BillingValidationTest(unittest.TestCase):
    def validate(self, config, catalog, platform='android', backend='/nonexistent'):
        check.validate(config, catalog, platform, backend)

    def test_free_recipe_has_no_external_credentials(self):
        self.validate(free_config(), empty_catalog())
        catalog = empty_catalog()
        catalog['features'] = {'browse': {'access': 'free'}}
        self.validate({**free_config(), 'FEATURE_ENTITLEMENTS': '{"browse":null}'}, catalog)

    def test_empty_mappings_support_default_premium_guard_on_both_platforms(self):
        catalog = {**empty_catalog(), 'default_premium_guard': 'client'}
        for platform in ['android', 'ios']:
            self.validate(paid_config(), catalog, platform)
        with self.assertRaises(check.InvalidConfig):
            self.validate(free_config(), catalog)

    def test_named_features_and_offerings_require_exact_catalog_keys(self):
        catalog = empty_catalog()
        catalog['features'] = {'export': {'access': 'premium', 'enforcement': 'client'}}
        config = {**paid_config(), 'FEATURE_ENTITLEMENTS': '{"export":"premium"}'}
        self.validate(config, catalog)
        for updates in [
            {'FEATURE_ENTITLEMENTS': '{"export":null}'},
            {'FEATURE_ENTITLEMENTS': '{}'},
            {'FEATURE_ENTITLEMENTS': '{"typo":"premium"}'},
            {'FEATURE_OFFERINGS': '{"typo":"plans"}'},
            {'FEATURE_ENTITLEMENTS': {'export': 'premium'}},
            {'FEATURE_ENTITLEMENTS': '{"export":""}'},
            {'FEATURE_ENTITLEMENTS': '{"export":"premium","export":null}'},
        ]:
            with self.assertRaises(check.InvalidConfig):
                self.validate({**config, **updates}, catalog)

    def test_selected_store_key_and_environment_are_required(self):
        for updates in [
            {'APP_ENVIRONMENT': 'dev'}, {'REVENUECAT_ANDROID_API_KEY': ''},
            {'REVENUECAT_ANDROID_API_KEY': 'appl_wrong-platform'},
            {'REVENUECAT_ANDROID_API_KEY': 'test_store'},
            {'REVENUECAT_ANDROID_API_KEY': 'sk_private'},
            {'BACKEND_ENABLED': 'false'}, {'REVENUECAT_ENTITLEMENT_ID': ''},
        ]:
            with self.assertRaises(check.InvalidConfig):
                self.validate({**paid_config(), **updates}, empty_catalog())
        self.validate({**paid_config(), 'REVENUECAT_IOS_API_KEY': ''}, empty_catalog())

    def test_client_config_cannot_contain_private_keys_even_when_disabled(self):
        for updates in [
            {'REVENUECAT_SECRET_API_KEY': 'private'},
            {'SUPABASE_SERVICE_ROLE_KEY': 'private'},
            {'SERVER_API_KEY': 'sb_secret_private'},
            {'REVENUECAT_IOS_API_KEY': 'sk_private'},
        ]:
            with self.assertRaises(check.InvalidConfig):
                self.validate({**free_config(), **updates}, empty_catalog())

    def test_legacy_anon_keys_work_but_service_role_and_empty_publishable_keys_fail(self):
        def token(role):
            payload = base64.urlsafe_b64encode(json.dumps({'role': role}).encode()).decode().rstrip('=')
            return 'header.' + payload + '.signature'
        self.validate({**free_config(), 'SERVER_API_KEY': token('anon')}, empty_catalog())
        for key in [token('service_role'), 'sb_publishable_', 'bad.jwt.payload']:
            with self.assertRaises(check.InvalidConfig):
                self.validate({**free_config(), 'SERVER_API_KEY': key}, empty_catalog())

    def test_sentry_public_dsn_does_not_get_rejected_as_a_password(self):
        self.validate({**free_config(), 'CRASH_REPORTING_ENABLED': True,
                       'SENTRY_DSN': 'https://public-key@sentry.example.com/123'}, empty_catalog())

    def test_invalid_urls_and_non_json_numbers_fail_without_tracebacks(self):
        for url in ['https://[invalid', 'https://example.com:invalid', 'https://@example.com']:
            with self.assertRaises(check.InvalidConfig):
                self.validate({**free_config(), 'BACKEND_ENABLED': True,
                               'SERVER_BASE_URL': url, 'SERVER_API_KEY': 'sb_publishable_public'}, empty_catalog())
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'bad.json'
            path.write_text('{"extra":NaN}')
            with self.assertRaises(check.InvalidConfig):
                check.load_json(path)

    def test_server_features_require_auth_manifest_and_real_installation(self):
        catalog = empty_catalog()
        catalog['features'] = {'generate': {'access': 'premium', 'enforcement': 'server'}}
        catalog['server'] = {'environment': 'PRODUCTION', 'entitlement_ids': ['premium']}
        config = {**paid_config(), 'AUTH_MODE': 'optional',
                  'SERVER_BASE_URL': 'https://consumer.supabase.co', 'SERVER_API_KEY': 'sb_publishable_public',
                  'AUTH_REDIRECT_URL': 'com.example.consumer://auth-callback',
                  'FEATURE_ENTITLEMENTS': '{"generate":"premium"}'}
        with tempfile.TemporaryDirectory() as directory:
            backend = Path(directory)
            (backend / 'migrations').mkdir()
            (backend / 'config.toml').write_text('[auth]\nenabled = true\n')
            with self.assertRaises(check.InvalidConfig):
                self.validate(config, catalog, backend=backend)
            # Fixture of the installed artifacts checked by preflight. The optional
            # module's own suite separately exercises its real installer and SQL.
            (backend / 'migrations/20261015000000_subscription_entitlements.sql').write_text('-- module fixture')
            for file in ['revenuecat-webhook/index.ts', 'revenuecat-webhook/handler.ts',
                         'refresh-entitlements/index.ts', 'premium-status/index.ts',
                         '_shared/subscription_core.ts', '_shared/subscription_runtime.ts',
                         '_shared/subscription_handlers.ts']:
                target = backend / 'functions' / file
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text('// installed module fixture')
            (backend / 'config.toml').write_text(''.join(
                f'[functions.{name}]\nverify_jwt = false\n'
                for name in ['revenuecat-webhook', 'refresh-entitlements', 'premium-status']))
            self.validate(config, catalog, backend=backend)
            for update in [{'AUTH_MODE': 'disabled'}, {'SERVER_BASE_URL': 'http://localhost:54321'}]:
                with self.assertRaises(check.InvalidConfig):
                    self.validate({**config, **update}, catalog, backend=backend)
            invalid = copy.deepcopy(catalog)
            invalid['server']['environment'] = 'SANDBOX'
            with self.assertRaises(check.InvalidConfig):
                self.validate(config, invalid, backend=backend)
            invalid['server'] = {'environment': 'PRODUCTION', 'entitlement_ids': ['different']}
            with self.assertRaises(check.InvalidConfig):
                self.validate(config, invalid, backend=backend)
            config_path = backend / 'config.toml'
            original = config_path.read_text()
            for setting in ['verify_jwt = true', 'verify_jwt = false\nverify_jwt = true']:
                config_path.write_text(original.replace('verify_jwt = false', setting, 1))
                with self.assertRaises(check.InvalidConfig):
                    self.validate(config, catalog, backend=backend)
            config_path.write_text(original.replace('verify_jwt = false', '  verify_jwt = false # handler auth'))
            self.validate(config, catalog, backend=backend)
            (backend / 'functions/revenuecat-webhook/index.ts').unlink()
            with self.assertRaises(check.InvalidConfig):
                self.validate(config, catalog, backend=backend)

    def test_cli_error_never_prints_config_or_private_values(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / 'config.json'
            config.write_text(json.dumps({**free_config(), 'SERVER_API_KEY': 'sb_secret_do-not-print'}))
            result = subprocess.run(['python3', str(ROOT / 'tool/check_billing_config.py'),
                                     '--config', str(config), '--catalog', str(ROOT / 'config/features.json'),
                                     '--platform', 'android'], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('sb_secret_do-not-print', result.stdout + result.stderr)

    def test_make_blocks_invalid_release_before_flutter_for_both_makefiles_and_platforms(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / 'tool', root / 'tool')
            shutil.copytree(ROOT / 'config', root / 'config')
            config = root / 'production config.json'
            config.write_text(json.dumps({**free_config(), 'APP_ENVIRONMENT': 'dev'}))
            binary = root / 'bin'
            binary.mkdir()
            fvm = binary / 'fvm'
            fvm.write_text('#!/bin/sh\nprintf \"%s\\n\" \"$@\" > flutter-called\n')
            fvm.chmod(0o755)
            env = {**os.environ, 'PATH': str(binary) + os.pathsep + os.environ['PATH']}
            for makefile in ['Makefile', 'Makefile.prod']:
                # The packager renames Makefile.prod to Makefile in generated apps.
                source = ROOT / makefile
                if not source.exists():
                    source = ROOT / 'Makefile.prod' if (ROOT / 'Makefile.prod').exists() else ROOT / 'Makefile'
                shutil.copy(source, root / makefile)
                for target in ['build-android', 'build-ios']:
                    result = subprocess.run(['make', '-f', makefile, target, 'APP_CONFIG=production config.json'],
                                            cwd=root, env=env, capture_output=True, text=True)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertFalse((root / 'flutter-called').exists())
            config.write_text(json.dumps(free_config()))
            for makefile in ['Makefile', 'Makefile.prod']:
                for target in ['build-android', 'build-ios']:
                    result = subprocess.run(['make', '-f', makefile, target, 'APP_CONFIG=production config.json'],
                                            cwd=root, env=env, capture_output=True, text=True)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertTrue((root / 'flutter-called').exists())
                    self.assertIn('--dart-define-from-file=production config.json', (root / 'flutter-called').read_text())
                    (root / 'flutter-called').unlink()
                for target, field, opposite in [('build-android', 'REVENUECAT_ANDROID_API_KEY', 'ios'),
                                                 ('build-ios', 'REVENUECAT_IOS_API_KEY', 'android')]:
                    config.write_text(json.dumps({**paid_config(), field: ''}))
                    result = subprocess.run(['make', '-f', makefile, target, 'APP_CONFIG=production config.json',
                                             f'PLATFORM={opposite}'], cwd=root, env=env, capture_output=True, text=True)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertFalse((root / 'flutter-called').exists())
                config.write_text(json.dumps(free_config()))



if __name__ == '__main__':
    unittest.main()
