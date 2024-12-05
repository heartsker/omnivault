from __future__ import annotations

from subprocess import CalledProcessError
from subprocess import run

from config import load_config
from config import ModuleConfig


def pull_module(config: ModuleConfig) -> None:
    try:
        pull_command = ['git', 'pull']
        run(
            pull_command, check=True, cwd=config.repo_path,
            capture_output=True,
        ).stdout.decode('utf-8')
    except CalledProcessError as e:
        print(f'❌ Error pulling repo {config.name}: {e}')


def main() -> None:
    config = load_config()

    for module_config in config.modules:
        pull_module(config=module_config)


if __name__ == '__main__':
    main()
