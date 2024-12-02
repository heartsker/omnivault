# Makefile for managing git repositories with submodules 💻

.PHONY: pull push submodules

# Constants

GITHUB_DEFAULT_REPO_URL_PREFIX = "git@github.com:heartsker/"
GIT_EXTENSION = ".git"
INFRA_PATH = "_infra"

# 🛠️ Pull all repositories (main repo + submodules)
pull:
	@echo "⬇️ Pulling changes for all submodules..."
	@git submodule update --init --recursive
	@git submodule foreach git fetch --all
	@git submodule foreach git pull origin "$$(git rev-parse --abbrev-ref HEAD)"
	@echo "⬇️ Pulling changes for the main repository..."
	@git pull origin "$$(git rev-parse --abbrev-ref HEAD)"
	@echo "✅ Pull complete!"

# Commit all changes in submodules and main repository and push
commit:
	@echo "🔄 Committing changes for all submodules..."
	@if [ -z "$(m)" ]; then echo "Please provide a commit message using 'm' parameter"; exit 1; fi
	@echo "👀 Checking for changes in submodules..."
	# check that no submodule has uncommitted changes
	@git submodule foreach git diff-index --quiet HEAD -- || (echo "❌ Some submodules have uncommitted changes. Please commit or stash them before proceeding."; exit 1)
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
add-submodule:
	@if [ -z "$(p)" ]; then echo "❌ Missing submodule path. Use: make add-submodule p=<path> [u=<url>]"; exit 1; fi
	@echo "🔄 Adding submodule at $(p)..."
	@if [ -z "$(u)" ]; then \
		u=$(GITHUB_DEFAULT_REPO_URL_PREFIX)$$p$(GIT_EXTENSION); \
		echo "ℹ️ Using default URL: $$u"; \
	else \
		url="$(u)"; \
	fi; \
	git submodule add $$url $(p)

	setup-submodule p=$p

	@echo "✅ Submodule added and setup!"

# Setup submodule
setup-submodule:
	@$(MAKE) assert c="[ -z $p ]" m="❌ Missing submodule path. Use: make setup-submodule p=<path>"
	@echo "🔄 Setting up submodule at $p..."

	@echo "📂 Copying infra/Makefile to $p..."
	@cp $(INFRA_PATH)/Makefile $p/Makefile

	@echo "✅ Submodule `$p` setup complete!"

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