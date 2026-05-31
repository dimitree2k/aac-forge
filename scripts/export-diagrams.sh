#!/usr/bin/env bash
# Exports LikeC4 diagrams to multiple formats.
#
# Usage: scripts/export-diagrams.sh [model-dir] [output-dir] [view-filter...]
#   model-dir  — directory with .c4 files (default: model/)
#   output-dir — output directory (default: export/)
#   view-filter — optional LikeC4 -f filters for curated solution exports

set -euo pipefail

MODEL_DIR="${1:-model}"
OUTPUT_DIR="${2:-export}"
shift $(( $# > 0 ? 1 : 0 ))
shift $(( $# > 0 ? 1 : 0 ))

FILTER_ARGS=()
for VIEW_FILTER in "$@"; do
  FILTER_ARGS+=("-f" "$VIEW_FILTER")
done

mkdir -p "$OUTPUT_DIR"

echo "=== Validating model first ==="
npx likec4 validate "$MODEL_DIR"

echo ""
echo "=== Exporting PNG ==="
npx likec4 export png "$MODEL_DIR" -o "$OUTPUT_DIR/" --flat "${FILTER_ARGS[@]}"

echo ""
echo "=== Exporting Mermaid ==="
npx likec4 gen mermaid "$MODEL_DIR" --outdir "$OUTPUT_DIR/"

if ((${#FILTER_ARGS[@]} > 0)); then
  echo ""
  echo "=== Removing non-filtered Mermaid files ==="
  for FILE in "$OUTPUT_DIR"/*.mmd; do
    [[ -e "$FILE" ]] || continue
    BASENAME="$(basename "$FILE" .mmd)"
    KEEP=0
    for VIEW_FILTER in "$@"; do
      if [[ "$BASENAME" == $VIEW_FILTER ]]; then
        KEEP=1
      fi
    done
    if [[ "$KEEP" -eq 0 ]]; then
      rm "$FILE"
    fi
  done
fi

echo ""
echo "=== Exporting JSON ==="
npx likec4 export json "$MODEL_DIR" -o "$OUTPUT_DIR/"

echo ""
echo "=== Export complete ==="
ls -lh "$OUTPUT_DIR/"
