# Makefile for managing git repositories with submodules 💻

.PHONY: pull push

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
	@git submodule foreach git add .
	@git submodule foreach git commit -m "$m"
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
	@git submodule add $u $p
	@echo "✅ Submodule added!"