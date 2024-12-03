#!/bin/bash

set -e

echo "⬆️ Pushing changes for all submodules and the main repository..."

# Push changes for each submodule
git submodule foreach --recursive '
	echo "🔧 Pushing changes for $name..."
	if [ -d "$toplevel/$path" ]; then
		branch=$(git -C "$toplevel/$path" rev-parse --abbrev-ref HEAD || echo "")
		if [ -z "$branch" ]; then
			branch=$(git config -f "$toplevel/.gitmodules" submodule."$name".branch || echo "main")
		fi
		git -C "$toplevel/$path" push origin "$branch" || exit 1
	else
		echo "⚠️  Skipping submodule $name (missing path: $path)"
	fi
'

# Push changes for the main repository
echo "⬆️ Pushing changes for the main repository..."
current_branch=$(git rev-parse --abbrev-ref HEAD)
git push origin $current_branch

echo "✅ Push complete!"
