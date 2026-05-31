#!/usr/bin/env bash
# Verifies consistency between relationships and data flows in a LikeC4 model.
# Uses the JSON export to count arrows vs INF codes.
#
# Usage: scripts/verify-consistency.sh [model-dir]
#   model-dir — directory with .c4 files (default: model/)

set -euo pipefail

MODEL_DIR="${1:-model}"
TEMP_JSON="$(mktemp -d)/likec4-model.json"

cleanup() {
    rm -f "$TEMP_JSON"
}
trap cleanup EXIT

echo "=== Exporting model to JSON ==="
npx likec4 export json --skip-layout --pretty -o "$TEMP_JSON" "$MODEL_DIR" 2>&1

echo ""
echo "=== Analyzing consistency ==="
python3 scripts/extract-labels.py "$TEMP_JSON"

EXIT_CODE=$?
if [[ $EXIT_CODE -eq 0 ]]; then
    echo ""
    echo "✓ Model is consistent"
else
    echo ""
    echo "✗ Model has inconsistencies (see above)"
fi

exit $EXIT_CODE
