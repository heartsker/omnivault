.PHONY: install-hooks

VAULT_ROOT = $(shell git rev-parse --show-toplevel)
HOOKS_TEMPLATES_PATH = $(VAULT_ROOT)/_infra/hooks
HOOKS_TEMPLATES = $(HOOKS_TEMPLATES_PATH)/*
GIT_HOOKS_PATH = $(VAULT_ROOT)/.git/hooks/
CONFIGS = $(VAULT_ROOT)/_infra/configs

install-hooks:
	@echo "🚀 Setting up git hooks"

	@pre-commit install -c $(CONFIGS)/.pre-commit-config.yaml
	@cp $(GIT_HOOKS_PATH)/pre-commit $(HOOKS_TEMPLATES_PATH)
	@pre-commit install -c $(CONFIGS)/.pre-commit-config.yaml --hook-type commit-msg
	@cp $(GIT_HOOKS_PATH)/commit-msg $(HOOKS_TEMPLATES_PATH)

	@rm -rf $(GIT_HOOKS_PATH)
	@mkdir -p $(GIT_HOOKS_PATH)
	@find $(HOOKS_TEMPLATES) -type f ! -name 'Makefile' -exec cp {} $(GIT_HOOKS_PATH) \;

	@git submodule foreach --quiet --recursive "\
		echo \"⏳ Setting up hooks for \$$name...\"; \
		rm -rf \$$sm_path/.git/hooks; \
		mkdir -p \$$sm_path/.git/hooks; \
		find $(HOOKS_TEMPLATES) -type f ! -name 'Makefile' -exec cp {} \$$sm_path/.git/hooks/ \; \
	"

	@echo "✅ Hooks setup complete!"
