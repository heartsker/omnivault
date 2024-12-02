# Makefile for managing git repositories with submodules 💻

.PHONY: pull push submodules

# Constants

GITHUB_DEFAULT_REPO_URL_PREFIX = git@github.com:heartsker/
GIT_EXTENSION = .git
INFRA_PATH = _infra

# Pull the main repo and all submodules recursively
pull:
	@_infra/pull.sh

# Commit all changes in submodules and main repository and push
commit:
	$(call assert,git submodule status --recursive | grep -q "^[+-]",❌ Some submodules have uncommitted changes. Please commit or stash them before)
	@echo "🔄 Committing changes for the main repository..."
	@git add .
	@git commit -m "$m"
	@echo "✅ Commit complete!"

# 🚀 Push all repositories (main repo + submodules)
push:
	@echo "⬆️ Pushing changes for all submodules..."
	@git submodule foreach git push origin "$$(git rev-parse --abbrev-ref HEAD)"
	@echo "⬆️ Pushing changes for the main repository..."
	@git push origin "$$(git rev-parse --abbrev-ref HEAD)"
	@echo "✅ Push complete!"

# Add a new submodule
# p: path of the submodule
# u: URL of the submodule (optional) - default is the GitHub URL
add-submodule:
	$(call assert-argument, key=$(p), name="path", usage="make add-submodule p=<path> [u=<url>]")

	@if [ ! -d "$(p)" ]; then \
		echo "👀 Path $(p) does not exist. Trying to clone the submodule..."; \
		git clone $(GITHUB_DEFAULT_REPO_URL_PREFIX)$p$(GIT_EXTENSION) $(p) || exit 1; \
	fi

	git submodule add $(GITHUB_DEFAULT_REPO_URL_PREFIX)$p$(GIT_EXTENSION) $(p)

	@echo "✅ Submodule added and setup!"

# Push all changes (from root and submodules)
push-all:
	@echo "🚀 Pushing changes for all submodules..."
	@find . -type f -name "Makefile" -execdir $(MAKE) push \;
	@echo "✅ All submodules pushed!"

# Run a command for all submodules
# c: command to run
submodules:
	$(call assert-argument,command,$(c),make submodules c=<your-command>)

	@echo "🔄 Running command $c for all submodules..."
	@git submodule foreach --quiet $c
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