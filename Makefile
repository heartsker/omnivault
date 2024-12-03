# Makefile for managing git repositories with submodules 💻

.PHONY: pull push submodules

# Constants

GITHUB_DEFAULT_REPO_URL_PREFIX = git@github.com:heartsker/
GIT_EXTENSION = .git
INFRA_PATH = _infra

# Setup omnivault
setup:
	@echo "🚀 Setting up repository"

	@$(MAKE) -C $(INFRA_PATH) install-requirements

	@$(MAKE) -C $(INFRA_PATH) install-hooks

	@echo "✅ Setup complete!"

# Pull the main repo and all submodules recursively
pull:
	@_infra/pull.sh

# 🚀 Push all repositories (main repo + submodules)
push:
	@git push

# Commit all changes in repository
# Guard against uncommitted changes in submodules
# m: commit message
commit:
	$(call assert,git submodule status --recursive | grep -q "^[+-]",❌ Some submodules have uncommitted changes. Please commit or stash them before)
	$(call assert-argument,message,$(m),make commit m=<message>)

	@echo "🚀 Committing changes for the main repository"

	@git commit -am "$m" || echo "❌ Something went wrong while committing changes. Please check the error message above." && exit 1

	@echo "✅ Commit complete!"

# Add a new submodule
# p: path of the submodule
# u: URL of the submodule (optional) - default is the GitHub URL
add-submodule:
	$(call assert-argument,path,$(p),make add-submodule p=<path> [u=<url>])

	@echo "🚀 Adding submodule at path $(p)"

	@if [ ! -d "$(p)" ]; then \
		echo "💡 Path $(p) does not exist. Trying to clone the submodule"; \
		git clone $(GITHUB_DEFAULT_REPO_URL_PREFIX)$p$(GIT_EXTENSION) $(p) || exit 1; \
	fi

	@git submodule add $(GITHUB_DEFAULT_REPO_URL_PREFIX)$p$(GIT_EXTENSION) $(p) || echo "❌ Something went wrong while adding the submodule. Please check the error message above." && exit 1

	@echo "✅ Submodule added and setup!"

# Run a command for all submodules
# c: command to run
submodules:
	$(call assert-argument,command,$(c),make submodules c=<your-command>)

	@echo "🚀 Running command $c for all submodules"
	@git submodule foreach --quiet $c || echo "❌ Something went wrong while running the command. Please check the error message above." && exit 1
	@echo "✅ Finished running command for all submodules."

# Helpers

.PHONY: assert assert-argument

# Assert target for validating conditions
# $1: condition to check
# $2: message to display if condition is false (optional)
define assert
	@if ! [ "$1" ]; then \
		echo "$2"; \
		exit 1; \
	fi
endef

# Assert target for validating arguments
# $1: name of the argument
# $2: value of the argument
# $3: usage message (optional)
define assert-argument
	@if [ -z "$2" ]; then \
		echo "❌ Missing argument: $1"; \
		if [ ! -z "$3" ]; then \
			echo "\t👀 Usage: $3"; \
		fi; \
		exit 1; \
	fi
endef
