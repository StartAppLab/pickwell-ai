"""Install the optional subscription module into this project's Supabase tree."""
import argparse
from datetime import datetime, timezone
from pathlib import Path
import re


def install(root: Path, timestamp: str):
    if not re.fullmatch(r'\d{14}', timestamp):
        raise ValueError('Timestamp must have 14 digits')
    source = root / 'modules' / 'subscriptions'
    if not (root / 'migrations').is_dir():
        raise ValueError('Supabase migrations directory is missing')
    existing = list((root / 'migrations').glob('*_subscription_entitlements.sql'))
    if len(existing) > 1:
        raise ValueError('Multiple subscription migrations found')
    migration = existing[0] if existing else root / 'migrations' / f'{timestamp}_subscription_entitlements.sql'
    pairs = [(source / 'migrations/subscription_entitlements.sql', migration)]
    for file in (source / 'functions').rglob('*.ts'):
        pairs.append((file, root / 'functions' / file.relative_to(source / 'functions')))
    pairs.append((source / 'tests/subscription_security_test.sql', root / 'tests/subscription_security_test.sql'))
    config_path = root / 'config.toml'
    config = config_path.read_text()
    names = ['revenuecat-webhook', 'refresh-entitlements', 'premium-status']
    if existing:
        for name in names:
            if f'[functions.{name}]\nverify_jwt = false' not in config:
                raise ValueError('Installed function configuration differs; review manually')
    elif any(f'[functions.{name}]' in config for name in names):
        raise ValueError('Function configuration already exists; review manually')
    # Validate all destinations before writing anything; never overwrite app-owned code.
    for source_file, destination in pairs:
        if destination.exists() and destination.read_bytes() != source_file.read_bytes():
            raise ValueError(f'Refusing to overwrite {destination}')
    for source_file, destination in pairs:
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(source_file.read_bytes())
    if not existing:
        config += '\n# Optional subscription module: handlers verify webhook/JWT authorization themselves.\n'
        config += ''.join(f'\n[functions.{name}]\nverify_jwt = false\n' for name in names)
        config_path.write_text(config)
    return migration


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--timestamp', default=datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S'))
    args = parser.parse_args()
    print(install(Path(__file__).resolve().parents[1], args.timestamp))
