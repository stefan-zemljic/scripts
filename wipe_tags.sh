set -euo pipefail

git fetch --tags

echo "Deleting all local tags..."
tags=$(git tag -l)
if [ -n "$tags" ]; then
  git tag -d $tags
fi

echo -n "Are you sure you want to delete all remote tags? (y/N): "
read -r confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Aborting remote tag deletion."
  exit 0
fi

echo "Deleting all remote tags..."
remote_tags=$(git ls-remote --tags origin \
  | awk '{print $2}' \
  | sed 's@refs/tags/@@')

if [ -n "$remote_tags" ]; then
  git push origin --delete $remote_tags
fi

echo "All tags deleted locally and remotely."