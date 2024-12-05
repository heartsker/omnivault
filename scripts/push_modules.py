from __future__ import annotations

from subprocess import CalledProcessError
from subprocess import run

from config import load_config
from config import ModuleConfig


def push_module(config: ModuleConfig) -> None:
    try:
        push_command = ['git', 'push']
        run(push_command, check=True)
    except CalledProcessError as e:
        print(f'❌ Error pushing repo {config.name}: {e}')


def main() -> None:
    config = load_config()

    for module_config in config.modules:
        push_module(config=module_config)


if __name__ == '__main__':
    main()
