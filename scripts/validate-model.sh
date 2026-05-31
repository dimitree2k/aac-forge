#!/usr/bin/env bash
# Validates the LikeC4 architecture model.
# Wraps `npx likec4 validate`.
#
# Usage: scripts/validate-model.sh [model-dir]
#   model-dir — path to directory with .c4 files (default: model/)

set -euo pipefail

MODEL_DIR="${1:-model}"

echo "=== Validating LikeC4 model: $MODEL_DIR ==="
npx likec4 validate "$MODEL_DIR"
echo "=== Validation passed ==="
