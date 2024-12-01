# Makefile for managing git repositories with submodules 💻

.PHONY: pull push

# Constants

GITHUB_DEFAULT_REPO_URL_PREFIX = "git@github.com:heartsker/"
GIT_EXTENSION = ".git"

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

# ➕ Add a new submodule
add-submodule:
	@echo "🔄 Adding submodule at $p..."
	@if [ -z "$u" ]; then \
		u=$(GITHUB_DEFAULT_REPO_URL_PREFIX)$$p$(GIT_EXTENSION); \
		echo "ℹ️ Using default URL: $$u"; \
	fi; \
	git submodule add $$u $$p
	@echo "✅ Submodule added!"
