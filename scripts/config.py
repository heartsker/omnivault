from __future__ import annotations

from os import path
from typing import Any

from utils import repo_root_path
from yaml import safe_load

CONFIG_PATH = 'configs/modules.yaml'


class CONFIG_KEYS:
    SETTINGS_KEY = 'settings'
    MODULES_KEY = 'modules'

    class SETTINGS:
        DESTINATION = 'destination'
        HOOKS = 'hooks'
        PRE_COMMIT_CONFIG = 'pre_commit_config'
        USERNAME = 'username'

    class MODULES:
        NAME = 'name'
        URL = 'url'
        DESTINATION = 'destination'
        BRANCH = 'branch'
        SKIP_HOOKS = 'skip_hooks'


class ModuleConfig:
    name: str
    url: str
    repo_path: str
    branch: str | None

    def __init__(
        self,
        name: str,
        url: str,
        repo_path: str,
        branch: str | None = None,
        skip_hooks: bool = False,
    ) -> None:
        self.name = name
        self.url = url
        self.repo_path = repo_path
        self.branch = branch
        self.skip_hooks = skip_hooks


class Config:
    root_path: str
    username: str
    hooks_path: str
    pre_commit_config_path: str
    modules: list[ModuleConfig]

    def __init__(
        self,
        root_path: str = '',
        username: str = '',
        hooks_path: str = '',
        pre_commit_config_path: str = '',
        modules: list[ModuleConfig] = [],
    ) -> None:
        self.root_path = root_path
        self.username = username
        self.hooks_path = hooks_path
        self.pre_commit_config_path = pre_commit_config_path
        self.modules = modules


__config: Config | None = None


def check_config(raw_config: dict[str, Any]) -> None:
    if CONFIG_KEYS.SETTINGS_KEY not in raw_config:
        raise ValueError('Settings are required')
    if CONFIG_KEYS.SETTINGS.DESTINATION not in raw_config.get(CONFIG_KEYS.SETTINGS_KEY, {}):
        raise ValueError('Destination is required')
    if CONFIG_KEYS.SETTINGS.HOOKS not in raw_config.get(CONFIG_KEYS.SETTINGS_KEY, {}):
        raise ValueError('Hooks are required')
    if CONFIG_KEYS.SETTINGS.PRE_COMMIT_CONFIG not in raw_config.get(CONFIG_KEYS.SETTINGS_KEY, {}):
        raise ValueError('Pre commit config is required')
    if CONFIG_KEYS.SETTINGS.USERNAME not in raw_config.get(CONFIG_KEYS.SETTINGS_KEY, {}):
        raise ValueError('Username is required')

    if CONFIG_KEYS.MODULES_KEY not in raw_config:
        raise ValueError('Modules are required')
    for module in raw_config.get(CONFIG_KEYS.MODULES_KEY, []):
        if CONFIG_KEYS.MODULES.NAME not in module:
            raise ValueError('Module name is required')


def default_repo_url(username: str, name: str) -> str:
    return f'git@github.com:{username}/{name}.git'


def create_config(raw_config: dict[str, Any]) -> Config:
    username = raw_config.get(CONFIG_KEYS.SETTINGS_KEY, {}).get(
        CONFIG_KEYS.SETTINGS.USERNAME,
    )
    hooks = raw_config.get(CONFIG_KEYS.SETTINGS_KEY, {}).get(
        CONFIG_KEYS.SETTINGS.HOOKS,
    )
    pre_commit_config = raw_config.get(CONFIG_KEYS.SETTINGS_KEY, {}).get(
        CONFIG_KEYS.SETTINGS.PRE_COMMIT_CONFIG,
    )

    default_destination = raw_config.get(
        CONFIG_KEYS.SETTINGS_KEY, {},
    ).get(CONFIG_KEYS.SETTINGS.DESTINATION)
    modules: list[ModuleConfig] = []

    for raw_module in raw_config.get(CONFIG_KEYS.MODULES_KEY, dict()):
        name = raw_module.get(CONFIG_KEYS.MODULES.NAME)
        url = raw_module.get(
            CONFIG_KEYS.MODULES.URL,
            default_repo_url(username=username, name=name),
        )
        relative_path = raw_module.get(
            CONFIG_KEYS.MODULES.DESTINATION, path.join(
                default_destination, name,
            ),
        )
        repo_path = path.normpath(path.join(repo_root_path(), relative_path))
        branch = raw_module.get(CONFIG_KEYS.MODULES.BRANCH)
        skip_hooks = raw_module.get(CONFIG_KEYS.MODULES.SKIP_HOOKS, False)

        modules.append(
            ModuleConfig(
                name=name, url=url,
                repo_path=repo_path, branch=branch,
                skip_hooks=skip_hooks,
            ),
        )

    return Config(
        root_path=repo_root_path(),
        username=username,
        hooks_path=path.normpath(path.join(repo_root_path(), hooks)),
        pre_commit_config_path=path.normpath(
            path.join(repo_root_path(), pre_commit_config),
        ),
        modules=modules,
    )


def config_file() -> str:
    return path.normpath(path.join(repo_root_path(), CONFIG_PATH))


def load_config() -> Config:
    global __config
    if not __config:
        with open(config_file()) as file:
            raw_config = safe_load(file)

            check_config(raw_config=raw_config)

            __config = create_config(raw_config=raw_config)

    return __config
