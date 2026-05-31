#!/usr/bin/env bash
# End-to-end smoke test — validates the full aac-forge pipeline.
#
# Usage: bash tests/smoke-test.sh

set -euo pipefail

PASS=0
FAIL=0
ORDER_MODEL_DIR=""

green() { echo -e "\033[32m✓ $1\033[0m"; }
red()   { echo -e "\033[31m✗ $1\033[0m"; }

check() {
    local desc="$1"
    shift
    echo ""
    echo "--- $desc ---"
    if "$@"; then
        green "$desc"
        PASS=$((PASS + 1))
    else
        red "$desc"
        FAIL=$((FAIL + 1))
    fi
}

prepare_example_model() {
    local src_dir="$1"
    local dest_dir
    dest_dir="$(mktemp -d)"
    ORDER_MODEL_DIR="$dest_dir"

    while IFS= read -r src_file; do
        local relative_path="${src_file#$src_dir/}"
        local dest_file="$dest_dir/${relative_path%.example}"
        mkdir -p "$(dirname "$dest_file")"
        cp "$src_file" "$dest_file"
    done < <(find "$src_dir" -type f -name '*.c4.example')

    echo "$dest_dir"
}

cleanup() {
    if [[ -n "$ORDER_MODEL_DIR" && -d "$ORDER_MODEL_DIR" ]]; then
        rm -rf "$ORDER_MODEL_DIR"
    fi
}

trap cleanup EXIT

ORDER_MODEL_DIR="$(prepare_example_model "examples/order-management/model")"

# 1. Validate main model
check "Validate main model"        npx likec4 validate model/

# 2. Validate Order Management model
check "Validate Order Management"  npx likec4 validate "$ORDER_MODEL_DIR"

# 3. Export PNG from Order Management (smoke — just one view)
check "Export Order Management PNG" npx likec4 export png "$ORDER_MODEL_DIR" -o examples/order-management/export/ --flat -f "landscape"

# 4. Export JSON from Order Management
check "Export Order Management JSON" npx likec4 export json --skip-layout -o /tmp/aac-forge-smoke-test.json "$ORDER_MODEL_DIR"

# 6. Extract labels from JSON
JSON_FILE="/tmp/aac-forge-smoke-test.json"
if [[ -f "$JSON_FILE" ]]; then
    python3 scripts/extract-labels.py "$JSON_FILE" || true
    echo "  (consistency analysis complete — see details above)"
    rm -f "$JSON_FILE"
fi

# 7. Format check
check "Format check"               npx likec4 format model/

echo ""
echo "========================================="
echo "  Smoke test: $PASS passed, $FAIL failed"
echo "========================================="

exit $FAIL
