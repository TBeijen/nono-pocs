#!/bin/bash
# Credential broker test runner.
#
# Prerequisites:
#   1. Run setup-keychain-items.sh first (outside any sandbox)
#   2. Build nono from the keychain-broker-prototype branch:
#      cd ~/projects/personal/always-further/nono
#      make build
#
# This script runs three scenarios and you compare the output.

set -euo pipefail

NONO_CUSTOM="$HOME/projects/personal/always-further/nono/target/debug/nono"
NONO_STABLE=$(which nono)
TEST_SCRIPT="$(cd "$(dirname "$0")" && pwd)/test-keychain-access.sh"
WORKDIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=============================================="
echo " Credential Broker Test Suite"
echo "=============================================="
echo ""
echo "  nono (stable):  $NONO_STABLE ($($NONO_STABLE --version))"

if [ ! -f "$NONO_CUSTOM" ]; then
    echo ""
    echo "ERROR: Custom nono binary not found at $NONO_CUSTOM"
    echo "Build it first:"
    echo "  cd ~/projects/personal/always-further/nono"
    echo "  cargo build --release -p nono-cli"
    exit 1
fi

echo "  nono (custom):  $NONO_CUSTOM ($($NONO_CUSTOM --version))"
echo "  test script:    $TEST_SCRIPT"
echo ""

# Verify test keychain items exist
echo "Verifying test Keychain items exist..."
if ! security find-generic-password -s "nono-broker-test-allowed" -a "test-user" -w &>/dev/null; then
    echo "ERROR: Test keychain items not found. Run setup-keychain-items.sh first."
    exit 1
fi
echo "  OK"
echo ""

read -p "Press Enter to start Scenario 1 (default profile, full Keychain access)..."
echo ""

echo "=============================================="
echo " Scenario 1: Default (claude-code profile)"
echo " Expected: ALL items accessible"
echo "=============================================="
echo ""
"$NONO_STABLE" run --silent \
    --profile claude-code \
    --allow "$WORKDIR" \
    -- bash "$TEST_SCRIPT"

echo ""
read -p "Press Enter to start Scenario 2 (no-keychain profile, all blocked)..."
echo ""

echo "=============================================="
echo " Scenario 2: No Keychain (claude-code-no-keychain profile)"
echo " Expected: ALL items denied"
echo "=============================================="
echo ""
"$NONO_STABLE" run --silent \
    --profile claude-code-no-keychain \
    --allow "$WORKDIR" \
    -- bash "$TEST_SCRIPT"

echo ""
read -p "Press Enter to start Scenario 3 (broker profile, selective access)..."
echo ""

echo "=============================================="
echo " Scenario 3: Credential Broker"
echo " Expected: nono-broker-test-allowed GRANTED"
echo "           nono-broker-test-blocked DENIED"
echo "           gh:github.com            DENIED"
echo "=============================================="
echo ""
NONO_EXPERIMENTAL_KEYCHAIN_BROKER=1 \
"$NONO_CUSTOM" run --silent \
    --profile claude-code-tb-broker-test \
    --allow "$WORKDIR" \
    -- bash "$TEST_SCRIPT"

echo ""
echo "=============================================="
echo " All scenarios complete"
echo "=============================================="
