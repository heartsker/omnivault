.PHONY: install-requirements install-hooks

VAULT_ROOT = $(shell git rev-parse --show-toplevel)
HOOKS_TEMPLATES_PATH = $(VAULT_ROOT)/_infra/hooks
HOOKS_TEMPLATES = $(HOOKS_TEMPLATES_PATH)/*
GIT_HOOKS_PATH = $(VAULT_ROOT)/.git/hooks/
CONFIGS = $(VAULT_ROOT)/_infra/configs
HOOKS = commit-msg post-commit pre-commit pre-push

install-requirements:
	@echo "🚀 Installing requirements for omnivault"

	@python3 -m pip install --quiet -r requirements.txt

	@echo "✅ Requirements installed!"


install-hooks:
	@echo "🚀 Setting up git hooks"

	@pre-commit install -c $(CONFIGS)/.pre-commit-config.yaml
	@cp $(GIT_HOOKS_PATH)/pre-commit $(HOOKS_TEMPLATES_PATH)
	@pre-commit install -c $(CONFIGS)/.pre-commit-config.yaml --hook-type commit-msg
	@cp $(GIT_HOOKS_PATH)/commit-msg $(HOOKS_TEMPLATES_PATH)

	@rm -rf $(GIT_HOOKS_PATH)
	@mkdir -p $(GIT_HOOKS_PATH)
	@cp $(HOOKS_TEMPLATES) $(GIT_HOOKS_PATH)

	@git submodule foreach --quiet --recursive "\
		echo \"⏳ Setting up hooks for \$$name...\"; \
		rm -rf .git/hooks; \
		mkdir -p .git/hooks; \
		cp $(HOOKS_TEMPLATES) .git/hooks; \
		pre-commit install -c $(CONFIGS)/.pre-commit-config.yaml; \
		pre-commit install -c $(CONFIGS)/.pre-commit-config.yaml --hook-type commit-msg; \
	"

	@echo "✅ Hooks setup complete!"
