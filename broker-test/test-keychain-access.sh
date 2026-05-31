#!/bin/bash
# Run this INSIDE a nono sandbox to test credential access.
# It tries to read both test Keychain items and reports results.

echo "=== Keychain Credential Access Test ==="
echo "  Date: $(date)"
echo "  PID:  $$"
echo ""

# Check if we're in a nono sandbox
if [ -n "${NONO_SESSION_ID:-}" ]; then
    echo "  Running inside nono sandbox (session: $NONO_SESSION_ID)"
else
    echo "  WARNING: Not running inside a nono sandbox"
fi

# Check if the credential broker is active
if [ -n "${NONO_CREDENTIAL_BROKER:-}" ]; then
    echo "  Credential broker: ACTIVE"
else
    echo "  Credential broker: not active"
fi

# Check which 'security' binary is in PATH
echo "  security binary: $(which security)"
echo ""

echo "--- Test 1: Read ALLOWED item (service=nono-broker-test-allowed) ---"
if secret=$(security find-generic-password -s "nono-broker-test-allowed" -a "test-user" -w 2>&1); then
    echo "  RESULT: ACCESS GRANTED"
    echo "  Secret: $secret"
else
    echo "  RESULT: ACCESS DENIED"
    echo "  Error:  $secret"
fi
echo ""

echo "--- Test 2: Read BLOCKED item (service=nono-broker-test-blocked) ---"
if secret=$(security find-generic-password -s "nono-broker-test-blocked" -a "test-user" -w 2>&1); then
    echo "  RESULT: ACCESS GRANTED"
    echo "  Secret: $secret"
else
    echo "  RESULT: ACCESS DENIED"
    echo "  Error:  $secret"
fi
echo ""

echo "--- Test 3: Read GitHub credentials (service=gh:github.com) ---"
if secret=$(security find-generic-password -s "gh:github.com" -w 2>&1); then
    echo "  RESULT: ACCESS GRANTED (secret redacted)"
else
    echo "  RESULT: ACCESS DENIED"
    echo "  Error:  $secret"
fi
echo ""

echo "--- Test 4: gh auth status ---"
if command -v gh &>/dev/null; then
    gh auth status 2>&1 | sed 's/^/  /'
else
    echo "  gh CLI not found, skipping"
fi
echo ""

echo "=== Tests complete ==="
