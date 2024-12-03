.PHONY: install-hooks

VAULT_ROOT = $(shell git rev-parse --show-toplevel)
HOOKS_TEMPLATES = $(VAULT_ROOT)/_infra/hooks/*
GIT_HOOKS_PATH = $(VAULT_ROOT)/.git/hooks/
CONFIGS = $(VAULT_ROOT)/_infra/configs

install-hooks:
	@echo "🚀 Setting up git hooks"

	rm -rf $(GIT_HOOKS_PATH)
	mkdir -p $(GIT_HOOKS_PATH)
	find $(HOOKS_TEMPLATES) -type f ! -name 'Makefile' -exec cp {} $(GIT_HOOKS_PATH) \;

	@pre-commit install -c $(CONFIGS)/.pre-commit-config.yaml

	@git submodule foreach --quiet --recursive "\
		echo \"⏳ Setting up hooks for \$$name...\"; \
		rm -rf \$$sm_path/.git/hooks; \
		mkdir -p \$$sm_path/.git/hooks; \
		find $(HOOKS_TEMPLATES) -type f ! -name 'Makefile' -exec cp {} \$$sm_path/.git/hooks/ \; \
	"

	@echo "✅ Hooks setup complete!"
