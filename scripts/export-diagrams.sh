#!/usr/bin/env bash
# Exports LikeC4 diagrams to multiple formats.
#
# Usage: scripts/export-diagrams.sh [model-dir] [output-dir]
#   model-dir  — directory with .c4 files (default: model/)
#   output-dir — output directory (default: export/)

set -euo pipefail

MODEL_DIR="${1:-model}"
OUTPUT_DIR="${2:-export}"

mkdir -p "$OUTPUT_DIR"

echo "=== Validating model first ==="
npx likec4 validate "$MODEL_DIR"

echo ""
echo "=== Exporting PNG ==="
npx likec4 export png "$MODEL_DIR" -o "$OUTPUT_DIR/" --flat

echo ""
echo "=== Exporting Mermaid ==="
npx likec4 gen mermaid "$MODEL_DIR" --outdir "$OUTPUT_DIR/"

echo ""
echo "=== Exporting JSON ==="
npx likec4 export json "$MODEL_DIR" -o "$OUTPUT_DIR/"

echo ""
echo "=== Export complete ==="
ls -lh "$OUTPUT_DIR/"
