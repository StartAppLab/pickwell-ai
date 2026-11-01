import tempfile
import shutil
import json
import subprocess
import unittest
from pathlib import Path
from zipfile import ZipFile

from package_template import create_archive


class PackagingTests(unittest.TestCase):
    def test_credentials_and_ephemeral_files_are_excluded(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'source'
            files = ['mason.yaml', 'mason-lock.json', '.mason/bricks/cache.txt', 'lib/main.dart', 'config/features.json', 'tool/check_billing_config.py', 'Makefile.prod', 'Makefile', '.secrets/prod.secrets',
                     '.env.fastlane', '.env.fastlane.example', 'android/key.properties',
                     'android/release.jks', 'sentry.properties', 'fastlane/downloads/listing.txt',
                     'ios/Flutter/ephemeral/package.swift', '.dart_tool/cache.txt']
            for name in files:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('fixture')
            output = create_archive(root, Path(directory) / 'template.zip')
            with ZipFile(output) as archive:
                self.assertEqual(set(archive.namelist()), {
                    'pickwell/mason.yaml',
                    'pickwell/mason-lock.json',
                    'pickwell/lib/main.dart',
                    'pickwell/config/features.json',
                    'pickwell/tool/check_billing_config.py',
                    'pickwell/Makefile',
                    'pickwell/.env.fastlane.example',
                })


    def test_generated_project_keeps_working_billing_gate(self):
        source = Path(__file__).resolve().parents[1]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'source'
            shutil.copytree(source / 'tool', root / 'tool')
            shutil.copytree(source / 'config', root / 'config')
            makefile = source / 'Makefile.prod' if (source / 'Makefile.prod').exists() else source / 'Makefile'
            shutil.copy(makefile, root / 'Makefile.prod')
            output = create_archive(root, Path(directory) / 'template.zip', name='consumer-app')
            with ZipFile(output) as archive:
                archive.extractall(Path(directory) / 'generated')
            generated = Path(directory) / 'generated/consumer-app'
            self.assertTrue((generated / 'Makefile').exists())
            self.assertFalse((generated / 'Makefile.prod').exists())
            (generated / 'release.json').write_text(json.dumps({
                'APP_ENVIRONMENT': 'prod', 'APP_NAME': 'Consumer App', 'BILLING_MODE': 'disabled'}))
            result = subprocess.run(['make', 'preflight-billing', 'APP_CONFIG=release.json'],
                                    cwd=generated, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            result = subprocess.run(['python3', '-m', 'unittest',
                'test_check_billing_config.BillingValidationTest.test_make_blocks_invalid_release_before_flutter_for_both_makefiles_and_platforms'],
                cwd=generated / 'tool', capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
