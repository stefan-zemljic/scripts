set -euo pipefail

bump_type="${1:-}"
shift || true
modules=("$@")

if [[ -z "$bump_type" || ${#modules[@]} -eq 0 ]]; then
  echo "Usage: $0 <patch|minor> <module1> [module2 ...]"
  exit 1
fi

case "$bump_type" in
  patch|minor) ;;
  *)
    echo "Invalid bump type: $bump_type"
    exit 1
    ;;
esac

for module in "${modules[@]}"; do
  if [ ! -d "$module" ]; then
    echo "Skipping '$module': not a directory"
    continue
  fi

  # Ensure clean working tree for this module
  if ! git diff --quiet -- "$module" || ! git diff --cached --quiet -- "$module"; then
    echo "Skipping '$module': has uncommitted changes"
    continue
  fi

  if [[ "$module" == "." ]]; then
    # Root module: tags are plain vX.Y.Z
    tags=$(git tag --list "v*" 2>/dev/null || true)
    if [ -z "$tags" ]; then
      version="v0.0.0"
    else
      version=$(printf "%s\n" $tags \
        | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" \
        | sort -V \
        | tail -n1)
    fi
  else
    # Submodule: tags are module/vX.Y.Z
    tags=$(git tag --list "${module}/v*" 2>/dev/null || true)
    if [ -z "$tags" ]; then
      version="v0.0.0"
    else
      version=$(printf "%s\n" $tags \
        | grep -E "^${module}/v[0-9]+\.[0-9]+\.[0-9]+$" \
        | sed "s#^${module}/##" \
        | sort -V \
        | tail -n1)
    fi
  fi

  echo "[$module] Current greatest version: $version"

  IFS=. read -r major minor patch <<<"${version#v}"

  case "$bump_type" in
    patch)
      patch=$((patch + 1))
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
  esac

  new_version="v${major}.${minor}.${patch}"

  if [[ "$module" == "." ]]; then
    new_tag="$new_version"
  else
    new_tag="${module}/${new_version}"
  fi

  echo "[$module] Creating tag $new_tag"
  git tag "$new_tag"
done

echo "Pushing all tags to origin..."
git push origin --tags
