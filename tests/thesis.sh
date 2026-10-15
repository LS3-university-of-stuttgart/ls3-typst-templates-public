#!/bin/bash
# Thesis specific checks: the bundled logos render, a replacement
# university logo must be an official PDF, and replacing either logo
# compiles.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/_lib.sh"

TMP="${TEST_TMP:?run through tests/run.sh}"
fail() { echo "FAIL: thesis: $1" >&2; exit 1; }
compile() {
  typst compile --package-path "$REPO_ROOT/.dev/packages" --font-path "$REPO_ROOT/fonts" "$@"
}

# with_args <name> <line>... copies the template and adds the given
# lines as the first arguments of thesis.with(...).
with_args() {
  local dir="$TMP/thesis-$1"; shift
  cp -R "$REPO_ROOT/thesis/template" "$dir"
  local lines="" l
  for l in "$@"; do lines+="  $l\n"; done
  awk -v add="$lines" '{ print } /^#show: thesis\.with\($/ && !done { printf "%s", add; done = 1 }' \
    "$dir/main.typ" > "$dir/main.new" && mv "$dir/main.new" "$dir/main.typ"
  echo "$dir"
}

# German cover uses the German logo.
dir="$(with_args de)"
sed -E -i.bak 's/^  language: "english",/  language: "german",/' "$dir/main.typ"
grep -q '^  language: "german",' "$dir/main.typ" || fail "could not switch the template to German"
compile "$dir/main.typ" "$TMP/de.pdf" >/dev/null 2>&1 || fail "German cover does not compile"
echo "ok: thesis German cover with bundled logos"

# A PNG university logo must fail with a pointer to the official PDF.
dir="$(with_args png 'university-logo: image("dot.png"),')"
typst compile - "$dir/dot.png" --format png <<<'#set page(width: 1cm, height: 1cm)' 2>/dev/null
if err="$(compile "$dir/main.typ" "$TMP/png.pdf" 2>&1)"; then
  fail "a PNG university logo was accepted"
fi
grep -q "official logo PDF" <<<"$err" || fail "PNG logo error does not explain the fix: $err"
echo "ok: thesis rejects a PNG university logo"

# Both logos replaced from the project, and both left out.
dir="$(with_args replaced 'university-logo: image("uni.pdf"),' 'chair-logo: image("chair.png"),')"
cp "$REPO_ROOT/thesis/assets/unistuttgart_logo_englisch.pdf" "$dir/uni.pdf"
typst compile - "$dir/chair.png" --format png <<<'#set page(width: 2cm, height: 2cm, fill: red)' 2>/dev/null
compile "$dir/main.typ" "$TMP/replaced.pdf" >/dev/null 2>&1 || fail "replaced logos do not compile"
dir="$(with_args none 'university-logo: none,' 'chair-logo: none,')"
compile "$dir/main.typ" "$TMP/none.pdf" >/dev/null 2>&1 || fail "cover without logos does not compile"
echo "ok: thesis logos can be replaced or left out"

# The rule below chapter headings can be switched on.
dir="$(with_args rule 'heading-rule: true,')"
compile "$dir/main.typ" "$TMP/rule.pdf" >/dev/null 2>&1 || fail "heading-rule: true does not compile"
echo "ok: thesis heading rule can be switched on"
