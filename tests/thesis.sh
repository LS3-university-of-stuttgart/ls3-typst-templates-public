#!/bin/bash
# Thesis specific checks. The logo crop is tested against the official
# university PDF, downloaded on the fly because it is not part of this
# repo. Without network access that check is skipped.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/_lib.sh"

TMP="${TEST_TMP:?run through tests/run.sh}"
fail() { echo "FAIL: thesis: $1" >&2; exit 1; }
compile() {
  typst compile --package-path "$REPO_ROOT/.dev/packages" --font-path "$REPO_ROOT/fonts" "$@"
}

work="$TMP/thesis-logos"
cp -R "$REPO_ROOT/thesis/template" "$work"

# A PNG university logo must fail with a pointer to the official PDF.
typst compile --font-path "$REPO_ROOT/fonts" - "$work/dot.png" --format png <<<'#set page(width: 1cm, height: 1cm)' 2>/dev/null
sed -E -i.bak 's|^  // (university-logo: )image\("logos/unistuttgart_logo_englisch.pdf"\)|  \1image("dot.png")|' "$work/main.typ"
grep -q '^  university-logo: image("dot.png")' "$work/main.typ" || fail "could not enable the university-logo line"
if err="$(compile "$work/main.typ" "$TMP/wrong.pdf" 2>&1)"; then
  fail "a PNG university logo was accepted"
fi
grep -q "official logo PDF" <<<"$err" || fail "PNG logo error does not explain the fix: $err"
echo "ok: thesis rejects a PNG logo"

# The official PDF must crop cleanly and compile.
url="https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/cd-dateien/01_Logo/pdf/unistuttgart_logo_englisch.pdf"
if curl -fsSL --max-time 30 -o "$work/logos/unistuttgart_logo_englisch.pdf" "$url"; then
  sed -E -i.bak 's|image\("dot.png"\)|image("logos/unistuttgart_logo_englisch.pdf")|' "$work/main.typ"
  compile "$work/main.typ" "$TMP/logo.pdf" >/dev/null 2>&1 || fail "template does not compile with the official logo"
  echo "ok: thesis compiles with the official university logo"
else
  echo "skip: could not download the official logo, crop not tested"
fi
