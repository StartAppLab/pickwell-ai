#!/usr/bin/env python3
"""Create a portable template archive without local credentials or build caches."""
import argparse
import os
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

EXCLUDED_PARTS = {
    '.git', '.dart_tool', '.fvm', '.mason', '.idea', '.secrets', '.gradle',
    '.swiftpm', '.symlinks', 'Pods', 'build', 'node_modules', '__pycache__', 'xcuserdata', '.credentials',
    'temp_source_zip', '.widget_preview',
}
EXCLUDED_NAMES = {
    '.DS_Store', '.flutter-plugins',
    '.flutter-plugins-dependencies', 'local.properties', 'key.properties',
    'sentry.properties', 'report.xml', 'Generated.xcconfig', 'flutter_export_environment.sh',
}
CREDENTIAL_SUFFIXES = {'.jks', '.keystore', '.p8', '.p12', '.pem', '.mobileprovision'}


def included(relative):
    if any(part in EXCLUDED_PARTS for part in relative.parts):
        return False
    if relative.name in EXCLUDED_NAMES or relative.suffix in CREDENTIAL_SUFFIXES:
        return False
    if relative.name.startswith('.env') and not relative.name.endswith('.example'):
        return False
    if relative.suffix in {'.zip', '.log'}:
        return False
    if relative.parts[:3] == ('ios', 'Flutter', 'ephemeral'):
        return False
    if relative.parts[:2] in {('fastlane', 'generated'), ('fastlane', 'downloads')}:
        return False
    if (
        len(relative.parts) > 1
        and relative.parts[0] == 'test'
        and relative.as_posix() != 'test/widget_test.dart'
    ):
        return False
    return True


def create_archive(root, output, name='pickwell'):
    root, output = Path(root).resolve(), Path(output).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(output, 'w', ZIP_DEFLATED) as archive:
        for directory, directories, files in os.walk(root):
            directories[:] = sorted(d for d in directories if included((Path(directory) / d).relative_to(root)))
            for filename in sorted(files):
                path = Path(directory) / filename
                relative = path.relative_to(root)
                if path.is_symlink() or path == output or not included(relative):
                    continue
                archive.write(path, f'{name}/{relative.as_posix()}')
    return output


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True)
    parser.add_argument('--name', default='pickwell')
    args = parser.parse_args()
    print(create_archive(Path(__file__).resolve().parents[1], args.output, args.name))
