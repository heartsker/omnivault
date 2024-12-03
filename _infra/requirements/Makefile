.PHONY: install-hooks

VAULT_ROOT = $(shell git rev-parse --show-toplevel)
HOOKS_TEMPLATES = $(VAULT_ROOT)/_infra/hooks/*
GIT_HOOKS_PATH = $(VAULT_ROOT)/.git/hooks/

install-requirements:
	@echo "🚀 Installing requirements for omnivault"

	@python3 -m pip install --quiet -r requirements.txt

	@echo "✅ Requirements installed!"
