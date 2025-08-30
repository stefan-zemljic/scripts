#!/usr/bin/env bash
set -euo pipefail

# Check if inside a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not inside a Git repository."
  exit 1
fi

if [ -d "$(git rev-parse --git-dir)/rebase-apply" ] || \
   [ -d "$(git rev-parse --git-dir)/rebase-merge" ]; then
  echo "Aborting rebase..."
  git rebase --abort || true

elif [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ]; then
  echo "Aborting merge..."
  git merge --abort || true

elif [ -f "$(git rev-parse --git-dir)/CHERRY_PICK_HEAD" ]; then
  echo "Aborting cherry-pick..."
  git cherry-pick --abort || true

elif [ -f "$(git rev-parse --git-dir)/REVERT_HEAD" ]; then
  echo "Aborting revert..."
  git revert --abort || true

elif [ -f "$(git rev-parse --git-dir)/BISECT_LOG" ]; then
  echo "Aborting bisect..."
  git bisect reset || true

else
  echo "No ongoing rebase/merge/cherry-pick/revert/bisect detected."
fi
