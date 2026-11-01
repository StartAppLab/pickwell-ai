import importlib.util
from pathlib import Path
import shutil
import tempfile
import unittest
import subprocess
import zipfile

spec = importlib.util.spec_from_file_location('installer', Path(__file__).with_name('install_subscriptions.py'))
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)

class InstallationTest(unittest.TestCase):
    def test_explicit_idempotent_install_and_no_overwrites(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(Path(__file__).resolve().parents[1] / 'modules', root / 'modules')
            (root / 'migrations').mkdir()
            (root / 'config.toml').write_text('[auth]\nenabled = true\n')
            first = installer.install(root, '20261015000000')
            self.assertTrue(first.exists())
            self.assertEqual(installer.install(root, '20261016000000'), first)
            config = (root / 'config.toml').read_text()
            self.assertEqual(config.count('[functions.revenuecat-webhook]'), 1)
            target = root / 'functions/revenuecat-webhook/index.ts'
            target.write_text('// app-owned change')
            with self.assertRaises(ValueError):
                installer.install(root, '20261017000000')
            self.assertEqual(target.read_text(), '// app-owned change')
            self.assertEqual((root / 'config.toml').read_text(), config)

class PackagingTest(unittest.TestCase):
    def test_server_secret_files_are_not_archived(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copy(Path(__file__).resolve().parents[1] / 'Makefile', root / 'Makefile')
            (root / '.env.subscriptions').write_text('SERVER_SECRET=do-not-package')
            (root / '.env').write_text('SERVER_SECRET=do-not-package')
            (root / '.env.example').write_text('SERVER_SECRET=')
            (root / '__pycache__').mkdir()
            (root / '__pycache__/test.pyc').write_bytes(b'cache')
            subprocess.run(['make', 'zip'], cwd=root, check=True, capture_output=True)
            with zipfile.ZipFile(root / 'supabase-backend-stable.zip') as archive:
                names = archive.namelist()
                self.assertTrue(any(name.endswith('/.env.example') for name in names))
                self.assertFalse(any(name.endswith('/.env') or '.env.subscriptions' in name or '__pycache__' in name for name in names))

if __name__ == '__main__':
    unittest.main()
