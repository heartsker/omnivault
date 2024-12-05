from __future__ import annotations

from os import makedirs
from os import path
from subprocess import CalledProcessError
from subprocess import run

from config import load_config
from config import ModuleConfig


def clone_repo(config: ModuleConfig) -> None:
    try:
        if not path.exists(path=config.repo_path):
            makedirs(name=config.repo_path)
        clone_command = [
            'git', 'clone',
            '--recurse-submodules', config.url, config.repo_path,
        ]
        if config.branch:
            clone_command.extend(['--branch', config.branch])
        run(clone_command, check=True)
    except CalledProcessError as e:
        print(f'❌ Error cloning repo {config.name}: {e}')


def main() -> None:
    config = load_config()

    for module_config in config.modules:
        clone_repo(config=module_config)


if __name__ == '__main__':
    main()
