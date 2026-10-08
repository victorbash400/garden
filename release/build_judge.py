"""Build the manual-approval flavor without altering developer target settings."""
import json
from pathlib import Path
import plistlib
import subprocess


def configure(project, directory):
    objects = project['objects']
    targets = {item['name']: item for item in objects.values()
               if item.get('isa') == 'PBXNativeTarget'}
    runner = targets['Runner']
    finder = targets['GardenFinder']
    runner['dependencies'] = [key for key in runner['dependencies']
                              if objects[key].get('target') != next(
                                  key for key, value in objects.items() if value is finder)]
    for phase in runner['buildPhases']:
        item = objects[phase]
        if item['isa'] == 'PBXCopyFilesBuildPhase':
            item['files'] = [key for key in item['files']
                             if objects[key].get('fileRef') != finder['productReference']]
    for name in ('Runner', 'GardenRemote'):
        target = targets[name]
        for key in objects[target['buildConfigurationList']]['buildConfigurations']:
            config = objects[key]
            if config['name'] != 'Release':
                continue
            settings = config['buildSettings']
            entitlements = plistlib.loads((directory / settings['CODE_SIGN_ENTITLEMENTS']).read_bytes())
            entitlements.pop('keychain-access-groups', None)
            path = directory / f'{name}.judge.entitlements'
            path.write_bytes(plistlib.dumps(entitlements))
            settings.update({
                'CODE_SIGN_STYLE': 'Manual',
                'CODE_SIGN_IDENTITY': 'Apple Development',
                'CODE_SIGN_INJECT_BASE_ENTITLEMENTS': 'NO',
                'CODE_SIGN_ENTITLEMENTS': str(path),
                'PROVISIONING_PROFILE_SPECIFIER': '',
                'PROVISIONING_PROFILE': '',
                'SWIFT_ACTIVE_COMPILATION_CONDITIONS': '$(inherited) GARDEN_MANUAL_INSTALL',
            })
            info_path = directory / settings['INFOPLIST_FILE']
            info = plistlib.loads(info_path.read_bytes())
            info['GardenCredentialMode'] = 'owner-file'
            info_path.write_bytes(plistlib.dumps(info))


def main():
    frontend = Path(__file__).resolve().parents[1] / 'frontend'
    macos = frontend / 'macos'
    project_path = macos / 'Runner.xcodeproj/project.pbxproj'
    paths = [project_path, macos / 'Runner/Info.plist', macos / 'RemoteDrive/Info.plist']
    originals = {path: path.read_bytes() for path in paths}
    try:
        subprocess.run(['flutter', 'build', 'macos', '--release', '--no-pub', '--config-only'],
                       cwd=frontend, check=True)
        converted = subprocess.run(['plutil', '-convert', 'json', '-o', '-', str(project_path)],
                                   check=True, capture_output=True)
        project = json.loads(converted.stdout)
        configure(project, macos)
        project_path.write_bytes(plistlib.dumps(project, sort_keys=False))
        subprocess.run(['xcodebuild', '-workspace', 'macos/Runner.xcworkspace', '-scheme', 'Runner',
                        '-configuration', 'Release', '-derivedDataPath', 'build/judge', 'build'],
                       cwd=frontend, check=True)
        print(frontend / 'build/judge/Build/Products/Release/Garden.app')
    finally:
        for path, data in originals.items():
            path.write_bytes(data)
        for name in ('Runner', 'GardenRemote'):
            (macos / f'{name}.judge.entitlements').unlink(missing_ok=True)


if __name__ == '__main__':
    main()
