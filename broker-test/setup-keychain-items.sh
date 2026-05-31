#!/bin/bash
# Creates two test Keychain items for validating the credential broker.
#
# - nono-broker-test-allowed: should be accessible through the broker
# - nono-broker-test-blocked: should be denied by the broker
#
# Run this OUTSIDE of any nono sandbox.

set -euo pipefail

echo "=== Setting up test Keychain items ==="

# Clean up any previous test items (ignore errors if they don't exist)
security delete-generic-password -s "nono-broker-test-allowed" -a "test-user" 2>/dev/null || true
security delete-generic-password -s "nono-broker-test-blocked" -a "test-user" 2>/dev/null || true

# Create test items
security add-generic-password -s "nono-broker-test-allowed" -a "test-user" -w "secret-allowed-value" -U
echo "  Created: service=nono-broker-test-allowed  account=test-user  secret=secret-allowed-value"

security add-generic-password -s "nono-broker-test-blocked" -a "test-user" -w "secret-blocked-value" -U
echo "  Created: service=nono-broker-test-blocked  account=test-user  secret=secret-blocked-value"

echo ""
echo "=== Verify items are accessible ==="
echo -n "  allowed item: "
security find-generic-password -s "nono-broker-test-allowed" -a "test-user" -w
echo -n "  blocked item: "
security find-generic-password -s "nono-broker-test-blocked" -a "test-user" -w

echo ""
echo "=== Setup complete ==="
echo "Now run the test scenarios in broker-test/run-tests.sh"
