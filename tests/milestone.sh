#!/bin/bash
# Milestone specific checks: the variants the default template does not
# compile, German, serif body with heading rule, no university logo, and
# another department.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/_lib.sh"

TMP="${TEST_TMP:?run through tests/run.sh}"
fail() { echo "FAIL: milestone: $1" >&2; exit 1; }

# check_variant <name> <line>... copies the template, sets the given
# "key: value," lines in milestone.with(...), compiles it, and fails on
# errors or warnings. A line replaces the template's line for the same
# key, or is added when the key is absent.
check_variant() {
  local name="$1"; shift
  local dir="$TMP/milestone-$name" out l key
  cp -R "$REPO_ROOT/milestone/template" "$dir"
  for l in "$@"; do
    key="${l%%:*}"
    awk -v key="$key" -v line="  $l" '
      /^#show: milestone\.with\($/ { inside = 1 }
      inside && !done && index($0, "  " key ":") == 1 { print line; done = 1; next }
      inside && !done && /^\)$/ { print line; done = 1 }
      { print }
    ' "$dir/main.typ" > "$dir/main.new" && mv "$dir/main.new" "$dir/main.typ"
  done
  if ! out="$(typst compile --package-path "$REPO_ROOT/.dev/packages" --font-path "$REPO_ROOT/fonts" \
      "$dir/main.typ" "$TMP/milestone-$name.pdf" 2>&1)"; then
    fail "$name does not compile: $out"
  fi
  if grep -q '^warning:' <<<"$out"; then
    fail "$name compiles with warnings: $out"
  fi
}

check_variant de 'language: "german",'
echo "ok: milestone German"

check_variant serif 'body-font: "serif",' 'heading-rule: true,'
echo "ok: milestone serif body with heading rule"

check_variant nologo 'university-logo: none,' 'additional-logo: rect(width: 60mm, height: 20mm),'
echo "ok: milestone without university logo, with additional logo"

check_variant dept 'institute: "Institute of Engineering Geodesy",' \
  'chair: "Department of Geodetic Measurement Systems",' 'examiners: ("Prof. A", "Prof. B"),'
echo "ok: milestone other department with examiners"
