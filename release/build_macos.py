import subprocess
from pathlib import Path


def main():
    frontend = Path(__file__).resolve().parents[1] / 'frontend'
    subprocess.run(['flutter', 'build', 'macos', '--release', '--no-pub'], cwd=frontend, check=True)
    print(frontend / 'build/macos/Build/Products/Release/Garden.app')


if __name__ == '__main__':
    main()
