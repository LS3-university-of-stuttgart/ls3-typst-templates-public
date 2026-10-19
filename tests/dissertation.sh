#!/bin/bash
# Dissertation specific checks: the variants the default template does
# not compile, A5 print, accepted status with the VLB page, German,
# serif body, and the heading rule.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/_lib.sh"

TMP="${TEST_TMP:?run through tests/run.sh}"
fail() { echo "FAIL: dissertation: $1" >&2; exit 1; }
compile() {
  typst compile --package-path "$REPO_ROOT/.dev/packages" --font-path "$REPO_ROOT/fonts" "$@"
}

# with_args <name> <line>... copies the template and sets the given
# "key: value," lines in dissertation.with(...), never in the abbr.make
# call above it. A line replaces the template's line for the same key,
# or is added when the key is absent.
with_args() {
  local dir="$TMP/dissertation-$1"; shift
  cp -R "$REPO_ROOT/dissertation/template" "$dir"
  local l key
  for l in "$@"; do
    key="${l%%:*}"
    awk -v key="$key" -v line="  $l" '
      /^#show: dissertation\.with\($/ { inside = 1 }
      inside && !done && index($0, "  " key ":") == 1 { print line; done = 1; next }
      inside && !done && /^\)$/ { print line; done = 1 }
      { print }
    ' "$dir/main.typ" > "$dir/main.new" && mv "$dir/main.new" "$dir/main.typ"
  done
  echo "$dir"
}

# check_variant <name> <line>... compiles a variant and fails on errors
# or warnings.
check_variant() {
  local name="$1"; shift
  local dir out
  dir="$(with_args "$name" "$@")"
  if ! out="$(compile "$dir/main.typ" "$TMP/dissertation-$name.pdf" 2>&1)"; then
    fail "$name does not compile: $out"
  fi
  if grep -q '^warning:' <<<"$out"; then
    fail "$name compiles with warnings: $out"
  fi
}

check_variant a5 'paper: "a5",'
echo "ok: dissertation A5 print"

check_variant print 'paper: "a5",' 'status: "accepted",' \
  'vlb: (heft: "320", isbn: "978-3-910293-00-0", printer: "Printer"),'
echo "ok: dissertation accepted print with VLB page"

check_variant de 'language: "german",' 'simtech: true,'
echo "ok: dissertation German with SimTech"

check_variant serif 'body-font: "serif",' 'heading-rule: true,'
echo "ok: dissertation serif body with heading rule"

# Leaving out a required abstract must fail with the rule it breaks.
dir="$(with_args noabstract 'abstract-de: none,')"
if err="$(compile "$dir/main.typ" "$TMP/noabstract.pdf" 2>&1)"; then
  fail "a missing abstract was accepted"
fi
grep -q "§ 2 (3)" <<<"$err" || fail "missing abstract error does not name the rule: $err"
echo "ok: dissertation requires both abstracts"
