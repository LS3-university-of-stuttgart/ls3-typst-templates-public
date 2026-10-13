#!/bin/bash
# Render the template's first page as the Universe thumbnail, at least
# 1080 px on the long edge as required.
#
# Usage: scripts/thumbnail.sh <package>

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

pkg="${1:-}"
require_package "$pkg"
"$REPO_ROOT/scripts/dev-link.sh" >/dev/null
dir="$REPO_ROOT/$pkg"
path="$(sed -En '/^\[template\]/,$ s/^path[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$dir/typst.toml")"
entry="$(sed -En '/^\[template\]/,$ s/^entrypoint[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$dir/typst.toml")"
typst compile --package-path "$REPO_ROOT/.dev/packages" --font-path "$REPO_ROOT/fonts" \
  --pages 1 --ppi 120 "$dir/$path/$entry" "$dir/thumbnail.png"
echo "rendered $pkg/thumbnail.png"
