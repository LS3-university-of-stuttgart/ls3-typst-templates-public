#!/bin/bash
# Copy common/brand.typ into every package as src/common.typ. Packages
# are published as self-contained folders, so each carries its own copy.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

for pkg in $(packages); do
  if [[ -f "$REPO_ROOT/$pkg/src/common.typ" ]]; then
    cp "$REPO_ROOT/common/brand.typ" "$REPO_ROOT/$pkg/src/common.typ"
    echo "synced: $pkg/src/common.typ"
  fi
done
