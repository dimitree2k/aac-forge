#!/usr/bin/env bash
# End-to-end smoke test — validates the full aac-forge pipeline.
#
# Usage: bash tests/smoke-test.sh

set -euo pipefail

PASS=0
FAIL=0

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

# 1. Validate main model
check "Validate main model"        npx likec4 validate model/

# 2. Validate Order Management model
check "Validate Order Management"  npx likec4 validate examples/order-management/model/

# 3. Export PNG from Order Management (smoke — just one view)
check "Export Order Management PNG" npx likec4 export png examples/order-management/model/ -o examples/order-management/export/ --flat -f "landscape"

# 4. Export JSON from Order Management
check "Export Order Management JSON" npx likec4 export json --skip-layout -o /tmp/aac-forge-smoke-test.json examples/order-management/model/

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
