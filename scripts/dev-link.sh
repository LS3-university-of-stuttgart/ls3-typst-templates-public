#!/bin/bash
# Link every package into .dev/packages/preview/<name>/<version>, so the
# templates' @preview imports resolve to the working tree. Compile with
#   typst compile --package-path .dev/packages --font-path fonts ...
# or set TYPST_PACKAGE_PATH="$PWD/.dev/packages" for your editor.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

rm -rf "$REPO_ROOT/.dev/packages"
for pkg in $(packages); do
  name="$(toml_field "$pkg" name)"
  version="$(toml_field "$pkg" version)"
  mkdir -p "$REPO_ROOT/.dev/packages/preview/$name"
  ln -s "$REPO_ROOT/$pkg" "$REPO_ROOT/.dev/packages/preview/$name/$version"
  echo "linked: @preview/$name:$version -> $pkg/"
done
