#!/usr/bin/env bash
# Build a typslides deck to PDF and render every page to PNG for inspection.
# Usage: check.sh deck.typ [ppi]
# Writes deck.pdf next to the source and deck-render/page-NN.png.
set -euo pipefail

deck=$1
ppi=${2:-60}
out="${deck%.typ}-render"

typst compile "$deck"
mkdir -p "$out"
rm -f "$out"/page-*.png
typst compile --ppi "$ppi" "$deck" "$out/page-{0p}.png"

pages=$(find "$out" -name 'page-*.png' | wc -l)
calls=$(grep -cE '^\s*#(front-slide|table-of-contents|title-slide|slide|focus-slide|blank-slide|bibliography-slide)\b' "$deck" || true)

echo "pdf:         ${deck%.typ}.pdf"
echo "renders:     $out/"
echo "pages:       $pages"
echo "slide calls: $calls"
if [ "$pages" -ne "$calls" ]; then
  echo "MISMATCH: a slide overflowed onto an extra page, content sits outside a slide," \
    "slides are generated in code, or overlays added subslides. View the renders to find which."
fi
