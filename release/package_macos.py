import argparse
from datetime import datetime, timezone
import plistlib
import shutil
import subprocess
import tempfile
from pathlib import Path


def run(*args):
    return subprocess.run(args, check=True, capture_output=True)


def validate_profile(data):
    if data.get('ProvisionedDevices') and not data.get('ProvisionsAllDevices'):
        raise ValueError('Device-restricted development provisioning cannot '
                         'serve as a general judge download.')
    expiration = data.get('ExpirationDate')
    if not isinstance(expiration, datetime):
        raise ValueError('The provisioning profile has no expiration date.')
    if expiration.tzinfo is None:
        expiration = expiration.replace(tzinfo=timezone.utc)
    if expiration <= datetime.now(timezone.utc):
        raise ValueError('The provisioning profile has expired.')


def signing_team(bundle):
    details = run('codesign', '-dv', '--verbose=4', str(bundle)).stderr.decode()
    lines = details.splitlines()
    if not any(line.startswith('Authority=Developer ID Application:') for line in lines):
        raise ValueError(f'{bundle.name} requires Developer ID Application signing '
                         'for the current shared Keychain configuration.')
    team = next((line.partition('=')[2] for line in lines
                 if line.startswith('TeamIdentifier=')), None)
    if not team or team == 'not set':
        raise ValueError(f'{bundle.name} has no signing team.')
    return team


def validate_app(app):
    with (app / 'Contents/Info.plist').open('rb') as source:
        info = plistlib.load(source)
    if info.get('CFBundleIdentifier') != 'com.victorbash.garden':
        raise ValueError('Expected a Garden application bundle.')
    helper = app / 'Contents/Helpers/GardenRemote.app/Contents/Info.plist'
    if not helper.is_file():
        raise ValueError('The Garden Finder helper is missing from the app.')
    with helper.open('rb') as source:
        if plistlib.load(source).get('CFBundleIdentifier') != 'com.victorbash.garden.remote':
            raise ValueError('The app contains an unexpected Finder helper.')
    run('codesign', '--verify', '--deep', '--strict', str(app))
    for profile in app.rglob('embedded.provisionprofile'):
        data = plistlib.loads(run('security', 'cms', '-D', '-i', str(profile)).stdout)
        validate_profile(data)
    team = signing_team(app)
    for bundle in app.rglob('*'):
        if bundle.is_dir() and bundle.suffix in {'.app', '.appex'}:
            if signing_team(bundle) != team:
                raise ValueError(f'{bundle.name} is signed by a different team.')
    return info


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('app', type=Path)
    parser.add_argument('output', type=Path)
    options = parser.parse_args()
    app = options.app.resolve()
    output = options.output.resolve()
    if output.suffix != '.dmg' or output.exists():
        raise ValueError('Provide a new .dmg output path.')
    info = validate_app(app)
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='garden-release-') as temporary:
        staging = Path(temporary)
        run('ditto', str(app), str(staging / 'Garden.app'))
        (staging / 'Applications').symlink_to('/Applications')
        shutil.copyfile(Path(__file__).with_name('INSTALL.txt'), staging / 'INSTALL.txt')
        run('hdiutil', 'create', '-volname', 'Garden', '-srcfolder', str(staging),
            '-format', 'UDZO', str(output))
    run('hdiutil', 'verify', str(output))
    print(f'Created {output.name} for Garden {info["CFBundleShortVersionString"]}.')
    print('Notarization and installation testing are separate release checks.')


if __name__ == '__main__':
    main()
