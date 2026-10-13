#!/bin/bash
# Set a package's version in typst.toml, the template import, and the
# README init line. Add the changelog section yourself.
#
# Usage: scripts/bump.sh <package> <X.Y.Z>

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

pkg="${1:-}"; next="${2:-}"
require_package "$pkg"
if [[ ! "$next" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "usage: $0 <package> <X.Y.Z>" >&2
  exit 1
fi

dir="$REPO_ROOT/$pkg"
name="$(toml_field "$pkg" name)"
current="$(toml_field "$pkg" version)"
if git -C "$REPO_ROOT" rev-parse -q --verify "refs/tags/$pkg-v$next" >/dev/null; then
  echo "error: $pkg $next is already released" >&2
  exit 1
fi

sed -E -i.bak "s/^(version[[:space:]]*=[[:space:]]*\")$current(\")/\1$next\2/" "$dir/typst.toml"
while IFS= read -r f; do
  sed -E -i.bak "s|@preview/$name:$current|@preview/$name:$next|g" "$f"
done < <(grep -rlF "@preview/$name:$current" "$dir")
find "$dir" -name '*.bak' -delete

echo "bumped $pkg $current -> $next. Add '### $next' to $pkg/README.md, then run scripts/release.sh $pkg"
