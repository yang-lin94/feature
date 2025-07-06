#!/usr/bin/env bash

# This test can be run with the following command:
#    devcontainer features test \
#               --features claude \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
check "claude is installed" claude --version

# Add more specific tests for your feature here
# Example:
# check "feature binary exists" test -f /usr/local/bin/claude
# check "feature config is correct" test -f /etc/claude/config.json

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
