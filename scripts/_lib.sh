#!/bin/bash
# Shared helpers for the scripts in this folder. Source, do not run.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Package folders are top-level folders with a typst.toml.
packages() {
  local d
  for d in "$REPO_ROOT"/*/; do
    [[ -f "$d/typst.toml" ]] && basename "$d"
  done
}

# toml_field <package> <field>, reads a quoted field from [package].
toml_field() {
  sed -En "s/^$2[[:space:]]*=[[:space:]]*\"([^\"]+)\".*/\\1/p" "$REPO_ROOT/$1/typst.toml" | head -n1
}

require_package() {
  if [[ -z "${1:-}" || ! -f "$REPO_ROOT/$1/typst.toml" ]]; then
    echo "error: '${1:-}' is not a package. Packages: $(packages | tr '\n' ' ')" >&2
    exit 1
  fi
}
