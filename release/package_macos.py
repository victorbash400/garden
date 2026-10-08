import argparse
import plistlib
import shutil
import subprocess
import tempfile
from pathlib import Path


def run(*args):
    return subprocess.run(args, check=True, capture_output=True)


def validate_app(app):
    with (app / 'Contents/Info.plist').open('rb') as source:
        info = plistlib.load(source)
    if info.get('CFBundleIdentifier') != 'com.victorbash.garden':
        raise ValueError('Expected a Garden application bundle.')
    run('codesign', '--verify', '--deep', '--strict', str(app))
    for profile in app.rglob('embedded.provisionprofile'):
        data = plistlib.loads(run('security', 'cms', '-D', '-i', str(profile)).stdout)
        if data.get('ProvisionedDevices') and not data.get('ProvisionsAllDevices'):
            raise ValueError('Device-restricted development provisioning cannot '
                             'serve as a general judge download.')
    details = run('codesign', '-dv', '--verbose=4', str(app)).stderr.decode()
    if not any(line.startswith('Authority=Developer ID Application:')
               for line in details.splitlines()):
        raise ValueError('This package requires Developer ID Application signing. '
                         'Manual approval does not remove provisioning restrictions.')
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
