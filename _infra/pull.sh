#!/bin/bash

set -e

echo "⬇️ Pulling all content (main repository and submodules)..."

# Update and initialize submodules recursively
echo "🔄 Initializing and updating submodules recursively..."
git submodule update --init --recursive

# Pull changes for each submodule
git submodule foreach --recursive '
	echo "🔧 Pulling changes for $name..."
	if [ -d "$toplevel/$path" ]; then
		branch=$(git -C "$toplevel/$path" rev-parse --abbrev-ref HEAD || echo "")
		if [ -z "$branch" ]; then
			branch=$(git config -f "$toplevel/.gitmodules" submodule."$name".branch || echo "main")
		fi
		git -C "$toplevel/$path" fetch origin
		git -C "$toplevel/$path" reset --hard "origin/$branch" || exit 1
	else
		echo "⚠️  Skipping submodule $name (missing path: $path)"
	fi
'

# Pull changes for the main repository
echo "⬇️ Pulling changes for the main repository..."
current_branch=$(git rev-parse --abbrev-ref HEAD)
git pull origin $current_branch

echo "✅ Pull complete!"
