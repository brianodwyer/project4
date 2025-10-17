#!/usr/bin/env bash
#
# reset-branches.sh
# Safely reset multiple branches to a specific commit and push to origin.
#
# Usage:
#   ./reset-branches.sh <commit_hash> <branch1> [branch2] [branch3] ...
#
# Example:
#   ./reset-branches.sh c7d8e9f main develop feature/login
#

set -e  # Exit on any error

if [ $# -lt 2 ]; then
  echo "Usage: $0 <commit_hash> <branch1> [branch2] ..."
  exit 1
fi

COMMIT=$1
shift  # Remove commit from args
BRANCHES=("$@")

echo "🛠  Preparing to reset the following branches to commit: $COMMIT"
printf '   - %s\n' "${BRANCHES[@]}"
echo

# Confirm with user
read -p "⚠️  This will rewrite history on remote branches. Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "❌ Operation cancelled."
  exit 0
fi

# Backup branches first
for BR in "${BRANCHES[@]}"; do
  BACKUP="backup-${BR}-$(date +%Y%m%d-%H%M%S)"
  echo "📦 Creating backup branch: $BACKUP"
  git branch "$BACKUP" "$BR"
done

# Reset and push each branch
for BR in "${BRANCHES[@]}"; do
  echo
  echo "🔄 Resetting branch '$BR' to commit '$COMMIT'..."
  git checkout "$BR"
  git reset --hard "$COMMIT"

  echo "☁️  Pushing branch '$BR' to origin (force-with-lease)..."
  git push origin "$BR" --force-with-lease
done

echo
echo "✅ Done! All branches have been reset and pushed."
echo "🪄 Backup branches created in case you need to restore."
