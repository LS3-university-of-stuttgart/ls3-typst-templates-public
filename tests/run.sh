#!/bin/bash
# Compile every package's template as typst init would scaffold it and
# fail on any warning, then run tests/<package>.sh where present.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/_lib.sh"

"$REPO_ROOT/scripts/dev-link.sh" >/dev/null

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export TEST_TMP="$TMP"

for pkg in $(packages); do
  dir="$REPO_ROOT/$pkg"
  path="$(sed -En '/^\[template\]/,$ s/^path[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$dir/typst.toml")"
  entry="$(sed -En '/^\[template\]/,$ s/^entrypoint[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$dir/typst.toml")"
  if [[ -n "$path" ]]; then
    cp -R "$dir/$path" "$TMP/$pkg"
    if ! out="$(typst compile --package-path "$REPO_ROOT/.dev/packages" --font-path "$REPO_ROOT/fonts" \
        "$TMP/$pkg/$entry" "$TMP/$pkg.pdf" 2>&1)"; then
      echo "FAIL: $pkg template does not compile" >&2; echo "$out" >&2; exit 1
    fi
    # Only real warnings count. A fresh machine also prints download
    # progress for @preview dependencies on stderr.
    if grep -q '^warning:' <<<"$out"; then
      echo "FAIL: $pkg template compiles with warnings" >&2; echo "$out" >&2; exit 1
    fi
    echo "ok: $pkg template"
  fi
  if [[ -f "$REPO_ROOT/tests/$pkg.sh" ]]; then
    bash "$REPO_ROOT/tests/$pkg.sh"
  fi
done
echo "tests: all passed"
