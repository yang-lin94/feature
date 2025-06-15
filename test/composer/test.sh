#!/usr/bin/env bash

# This test can be run with the following command:
#    devcontainer features test \
#               --features composer \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
check "composer is installed" composer --version
check "composer is in /usr/local/bin" test -f /usr/local/bin/composer

# Test that composer can create a new project (basic functionality test)
check "composer can create a new project" composer create-project --prefer-dist --no-interaction --no-dev laravel/laravel-test test-project

# Clean up test project
rm -rf test-project

# Test composer self-update (optional, but good to verify it works)
check "composer can check for updates" composer self-update --dry-run

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults