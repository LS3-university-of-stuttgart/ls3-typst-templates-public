#!/bin/bash
# Consistency checks for every package. Run by CI and before a release.
#   - src/common.typ is an exact copy of common/brand.typ
#   - the template imports the package at its own version
#   - the README's typst init line names the current version
#   - the README changelog has a section for the current version

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

fail=0
err() { echo "error: $1: $2" >&2; fail=1; }

for pkg in $(packages); do
  dir="$REPO_ROOT/$pkg"
  name="$(toml_field "$pkg" name)"
  version="$(toml_field "$pkg" version)"
  entry="$(sed -En '/^\[template\]/,$ s/^entrypoint[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$dir/typst.toml")"
  path="$(sed -En '/^\[template\]/,$ s/^path[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$dir/typst.toml")"

  if [[ -f "$dir/src/common.typ" ]] && ! cmp -s "$dir/src/common.typ" "$REPO_ROOT/common/brand.typ"; then
    err "$pkg" "src/common.typ differs from common/brand.typ, run scripts/sync-common.sh"
  fi
  if [[ -n "$path" ]]; then
    pins="$(grep -rhoE "@preview/$name:[0-9]+\.[0-9]+\.[0-9]+" "$dir/$path" | sort -u)"
    if [[ "$pins" != "@preview/$name:$version" ]]; then
      err "$pkg" "template imports ${pins:-nothing}, expected @preview/$name:$version"
    fi
    [[ -f "$dir/$path/$entry" ]] || err "$pkg" "template entrypoint $path/$entry is missing"
  fi
  grep -q "@preview/$name:$version" "$dir/README.md" \
    || err "$pkg" "README.md does not mention @preview/$name:$version"
  grep -qE "^### $version\$" "$dir/README.md" \
    || err "$pkg" "README.md changelog has no '### $version' section"
  for f in LICENSE README.md; do
    [[ -f "$dir/$f" ]] || err "$pkg" "$f is missing"
  done
done

if [[ "$fail" == "1" ]]; then exit 1; fi
echo "check: all packages consistent"
