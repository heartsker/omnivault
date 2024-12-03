.PHONY: install-hooks

VAULT_ROOT = $(shell git rev-parse --show-toplevel)
HOOKS_TEMPLATES = $(VAULT_ROOT)/_infra/hooks/*
GIT_HOOKS_PATH = $(VAULT_ROOT)/.git/hooks/

install-hooks:
	@echo "🚀 Setting up git hooks"

	@mkdir -p $(VAULT_ROOT)/.git/hooks
	@cp $(HOOKS_TEMPLATES) $(GIT_HOOKS_PATH)
	@git submodule foreach --quiet --recursive "\
		echo \"⏳ Setting up hooks for \$$name...\"; \
		mkdir -p \$$sm_path/.git/hooks; \
		cp $(HOOKS_TEMPLATES) \$$sm_path/.git/hooks/; \
	"

	@echo "✅ Hooks setup complete!"
