from __future__ import annotations

from os import listdir
from os import makedirs
from os import path
from shutil import rmtree
from subprocess import CalledProcessError
from subprocess import run

from config import load_config
from utils import repo_hooks_path
from utils import repo_submodules_paths


def install_pre_commit_hooks(pre_commit_config_path: str, repo_path: str) -> None:
    install_pre_commit_command = [
        'pre-commit',
        'install', '-c', pre_commit_config_path,
    ]
    install_commit_msg_command = [
        'pre-commit', 'install', '-c', pre_commit_config_path, '--hook-type', 'commit-msg',
    ]
    try:
        run(
            install_pre_commit_command, check=True, cwd=repo_path,
            stdout=open('/dev/null', 'w'), stderr=open('/dev/null', 'w'),
        )
        run(
            install_commit_msg_command, check=True, cwd=repo_path,
            stdout=open('/dev/null', 'w'), stderr=open('/dev/null', 'w'),
        )
    except CalledProcessError as e:
        raise RuntimeError('❌ Failed to install pre-commit hooks', e) from e


def install_hooks(hooks_path: str, repo_path: str) -> None:
    module_hooks_path = repo_hooks_path(repo_path)
    if not module_hooks_path:
        return

    if path.isdir(module_hooks_path) and listdir(module_hooks_path):
        rmtree(module_hooks_path)

    if not path.isdir(module_hooks_path):
        makedirs(module_hooks_path)

    if not path.exists(hooks_path):
        return

    for hook in listdir(hooks_path):
        hook_source = path.join(hooks_path, hook)
        hook_destination = path.join(module_hooks_path, hook)
        copy_command = ['cp', hook_source, hook_destination]
        try:
            run(copy_command, check=True)
        except CalledProcessError as e:
            raise RuntimeError(f'❌ Failed to copy hook {hook}') from e


def add_local_precommit(repo_path: str) -> None:
    module_hooks_path = repo_hooks_path(repo_path)
    if not module_hooks_path:
        return

    precommit_file = path.join(module_hooks_path, 'pre-commit')
    local_precommit_filepath = path.join(
        repo_path, 'infra', 'hooks', 'pre-commit.sh',
    )
    if path.exists(precommit_file):
        command = f'''
# Run local pre-commit script if it exists
if [ -f "{local_precommit_filepath}" ]; then
    {local_precommit_filepath}
fi
        '''
        with open(precommit_file, 'a') as f:
            f.write(command)


def install_hooks_for_module(hooks_path: str, repo_path: str, pre_commit_config_path: str) -> None:
    print(f'⏳ Installing for {repo_path}')
    install_hooks(hooks_path=hooks_path, repo_path=repo_path)
    install_pre_commit_hooks(
        pre_commit_config_path=pre_commit_config_path, repo_path=repo_path,
    )
    add_local_precommit(repo_path=repo_path)

    for relative_submodule_path in repo_submodules_paths(repo_path):
        submodule_path = path.join(repo_path, relative_submodule_path)
        install_hooks_for_module(
            hooks_path=hooks_path, repo_path=submodule_path,
            pre_commit_config_path=pre_commit_config_path,
        )


def main() -> None:
    config = load_config()

    hooks_path = config.hooks_path

    print('⏳ Installing for root')

    install_hooks(hooks_path=config.hooks_path, repo_path=config.root_path)
    install_pre_commit_hooks(
        pre_commit_config_path=config.pre_commit_config_path, repo_path=config.root_path,
    )

    print('⏳ Installing for modules')

    for module_config in config.modules:
        if module_config.skip_hooks:
            continue
        install_hooks_for_module(
            hooks_path=hooks_path, repo_path=module_config.repo_path,
            pre_commit_config_path=config.pre_commit_config_path,
        )


if __name__ == '__main__':
    main()
