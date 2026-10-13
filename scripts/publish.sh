#!/bin/bash
# Copy the latest release of a package into a local clone of a
# typst/packages fork, ready to commit and open a pull request. Copies
# from the release tag, so only released states reach Typst Universe.
#
# Usage: scripts/publish.sh <package> <path-to-typst-packages-clone>

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

pkg="${1:-}"; clone="${2:-}"
require_package "$pkg"
if [[ -z "$clone" || ! -d "$clone/.git" ]]; then
  echo "usage: $0 <package> <path-to-typst-packages-clone>" >&2
  echo "the second argument must be a git clone of typst/packages, see CONTRIBUTING.md" >&2
  exit 1
fi
# A sparse checkout only has packages/preview while one of our package
# folders is checked out, so create it when missing.
mkdir -p "$clone/packages/preview"

tag="$(git -C "$REPO_ROOT" tag -l "$pkg-v*" --sort=-v:refname | head -n1)"
if [[ -z "$tag" ]]; then
  echo "error: $pkg has no release yet, run scripts/release.sh $pkg" >&2
  exit 1
fi
version="${tag#"$pkg"-v}"
name="$(git -C "$REPO_ROOT" show "$tag:$pkg/typst.toml" | sed -En 's/^name[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' | head -n1)"
dest="$clone/packages/preview/$name/$version"

if [[ -e "$dest" ]]; then
  echo "error: $dest already exists. Published versions never change, bump instead." >&2
  exit 1
fi
mkdir -p "$dest"
git -C "$REPO_ROOT" archive "$tag" "$pkg" | tar -x --strip-components=1 -C "$dest"

echo "copied $tag -> $dest"
echo "next: commit it in the clone, push, and open a pull request titled '$name:$version'"
