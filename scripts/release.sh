#!/bin/bash
# Tag the current version of one package as <package>-v<version> after
# checks and tests pass. Other packages are not touched.
#
# Usage: scripts/release.sh <package>

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

pkg="${1:-}"
require_package "$pkg"
cd "$REPO_ROOT"

if [[ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]]; then
  echo "error: releases are cut from main" >&2
  exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree is not clean" >&2
  exit 1
fi

version="$(toml_field "$pkg" version)"
tag="$pkg-v$version"
if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  echo "error: $tag already exists, bump first with scripts/bump.sh $pkg <X.Y.Z>" >&2
  exit 1
fi

./scripts/check.sh
./tests/run.sh

git tag -a "$tag" -m "Release $pkg $version"
echo "tagged $tag"
echo "push with: git push origin main $tag"
echo "then publish with: scripts/publish.sh $pkg <path-to-typst-packages-clone>"
