#!/usr/bin/env bash
set -euo pipefail

# Check if inside a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not inside a Git repository."
  exit 1
fi

if [ -d "$(git rev-parse --git-dir)/rebase-apply" ] || \
   [ -d "$(git rev-parse --git-dir)/rebase-merge" ]; then
  echo "Continuing rebase..."
  git rebase --continue

elif [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ]; then
  echo "Continuing merge..."
  git merge --continue

elif [ -f "$(git rev-parse --git-dir)/CHERRY_PICK_HEAD" ]; then
  echo "Continuing cherry-pick..."
  git cherry-pick --continue

elif [ -f "$(git rev-parse --git-dir)/REVERT_HEAD" ]; then
  echo "Continuing revert..."
  git revert --continue

else
  echo "No ongoing rebase/merge/cherry-pick/revert detected."
fi
