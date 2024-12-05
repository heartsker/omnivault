# Makefile for managing omnivault

.PHONY: setup install-requirements clone install-hooks pull push

# Constants

SCRIPTS_PATH = scripts

# Targets

# Setup omnivault
setup: install-requirements clone install-hooks

# Install requirements for omnivault
install-requirements:
	@echo "🚀 Installing requirements for omnivault"

	@python3 -m pip install --quiet -r requirements.txt

	@echo "✅ Requirements installed!"

# Clone all submodules
clone:
	@echo "🚀 Cloning modules"

	@python3 $(SCRIPTS_PATH)/clone_modules.py

	@echo "✅ Clone completed!"

# Install git hooks for the main repository and modules
install-hooks:
	@echo "🚀 Setting up git hooks"

	@python3 $(SCRIPTS_PATH)/install_hooks.py

	@echo "✅ Hooks setup complete!"

# Pull the main repo and all submodules recursively
pull:
	@python3 scripts/pull_modules.py

# 🚀 Push all repositories (main repo + submodules)
push:
	@python3 scripts/push_modules.py
