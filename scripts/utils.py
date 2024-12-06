from __future__ import annotations

from os import path
from subprocess import CalledProcessError
from subprocess import run


def repo_root_path() -> str:
    command = ['git', 'rev-parse', '--show-toplevel']
    try:
        return run(command, check=True, capture_output=True).stdout.strip().decode('utf-8')
    except CalledProcessError as e:
        raise Exception(f'Error getting repo root path: {e}')


def repo_hooks_path(repo_path: str) -> str:
    command = ['git', 'rev-parse', '--git-path', 'hooks']
    try:
        hooks_path = run(
            command, check=True, cwd=repo_path,
            capture_output=True,
        ).stdout.strip().decode('utf-8')
        return path.normpath(path.join(repo_path, hooks_path))
    except CalledProcessError as e:
        raise Exception(f'Error getting repo hooks path: {e}')


def repo_submodules_paths(repo_path: str) -> list[str]:
    command = ['git', 'submodule', 'status', '--recursive']
    try:
        submodules = run(
            command, check=True, cwd=repo_path,
            capture_output=True,
        ).stdout.strip().decode('utf-8').split('\n')
        return [line.split()[1] for line in submodules if line]
    except CalledProcessError as e:
        raise Exception(f'Error getting repo submodules: {e}')
