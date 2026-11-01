import base64
import contextlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import check_environment as check


ROOT = Path(__file__).resolve().parents[1]


class EnvironmentTest(unittest.TestCase):
    def config(self):
        data = json.loads((ROOT / 'config/pickwell.dev.example.json').read_text())
        return {**data, 'SERVER_BASE_URL': 'https://example.supabase.co',
                'SERVER_API_KEY': 'sb_publishable_fixture'}

    def test_public_profile_and_incomplete_samples(self):
        check.check_public_config(self.config())
        for name in ['dev', 'stg']:
            sample = json.loads((ROOT / f'config/pickwell.{name}.example.json').read_text())
            with self.assertRaises(check.InvalidConfig):
                check.check_public_config(sample)

    def test_private_injection_and_privilege_flags_fail(self):
        for updates in [{'META_API_KEY': 'fixture'}, {'SUPABASE_SECRET_KEY': 'fixture'},
                        {'SERVER_API_KEY': 'sb_secret_' + 'fixture' * 8},
                        {'SUPPORT_URL': 'sb_secret_' + 'fixture' * 8},
                        {'BILLING_MODE': 'revenuecat'}, {'AUTH_MODE': 'required'},
                        {'NOTIFICATIONS_ENABLED': True}, {'verified': True}, {'plan': 'premium'}]:
            with self.subTest(fields=list(updates)), self.assertRaises(check.InvalidConfig):
                check.check_public_config({**self.config(), **updates})

    def test_scanner_detects_keys_and_service_jwt_without_classifying_public_key(self):
        payload = base64.urlsafe_b64encode(json.dumps({'role': 'service_role'}).encode()).decode().rstrip('=')
        content = '\n'.join(['sb_secret_' + 'x' * 30, 'EAA' + 'x' * 70,
                             'eyJhbGciOiJIUzI1NiJ9.' + payload + '.signature',
                             '-----BEGIN ' + 'PRIVATE KEY-----'])
        self.assertEqual(len(check.findings(content)), 4)
        self.assertEqual(check.findings('sb_publishable_fixture\nMETA_API_KEY=\nBILLING_ENABLED=false'), [])

    def test_scan_includes_tracked_and_new_files_but_respects_ignored_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(['git', 'init', '-q', directory], check=True)
            (root / '.gitignore').write_text('.env.dev\n')
            (root / '.env.dev').write_text('sb_secret_' + 'x' * 30)
            (root / 'tracked.txt').write_text('sb_secret_' + 'y' * 30)
            subprocess.run(['git', 'add', '.'], cwd=root, check=True)
            (root / 'new.txt').write_text('sb_secret_' + 'z' * 30)
            self.assertEqual({hit[0] for hit in check.scan(root)}, {'tracked.txt', 'new.txt'})

    def test_cli_failure_does_not_print_config_or_key(self):
        key = 'sb_secret_' + 'redactionfixture' * 5
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'client.json'
            path.write_text(json.dumps({**self.config(), 'SERVER_API_KEY': key}))
            with patch.object(sys, 'argv', ['check_environment.py', '--config', str(path)]), \
                    patch.object(check, 'scan', return_value=[]), \
                    contextlib.redirect_stderr(io.StringIO()) as output:
                self.assertEqual(check.main(), 1)
                self.assertNotIn(key, output.getvalue())


if __name__ == '__main__':
    unittest.main()
