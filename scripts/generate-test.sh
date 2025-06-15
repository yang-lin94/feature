#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if feature name is provided
if [ $# -eq 0 ]; then
    print_error "Usage: $0 <feature-name>"
    print_info "Example: $0 my-new-feature"
    exit 1
fi

FEATURE_NAME="$1"
TEST_DIR="test/$FEATURE_NAME"
SRC_DIR="src/$FEATURE_NAME"

# Check if feature exists
if [ ! -d "$SRC_DIR" ]; then
    print_error "Feature directory '$SRC_DIR' does not exist!"
    print_info "Please create the feature first in src/$FEATURE_NAME/"
    exit 1
fi

# Check if test already exists
if [ -d "$TEST_DIR" ]; then
    print_warning "Test directory '$TEST_DIR' already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Aborted."
        exit 0
    fi
    rm -rf "$TEST_DIR"
fi

# Create test directory
mkdir -p "$TEST_DIR"

# Generate test.sh
print_info "Generating test.sh for $FEATURE_NAME..."
cat > "$TEST_DIR/test.sh" << EOF
#!/usr/bin/env bash

# This test can be run with the following command:
#    devcontainer features test \\
#               --features $FEATURE_NAME \\
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
check "$FEATURE_NAME is installed" $FEATURE_NAME --version

# Add more specific tests for your feature here
# Example:
# check "feature binary exists" test -f /usr/local/bin/$FEATURE_NAME
# check "feature config is correct" test -f /etc/$FEATURE_NAME/config.json

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
EOF

# Generate scenarios.json
print_info "Generating scenarios.json for $FEATURE_NAME..."
cat > "$TEST_DIR/scenarios.json" << EOF
{
  "scenarios": [
    {
      "name": "$FEATURE_NAME-basic",
      "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
      "features": {
        "ghcr.io/yang-lin94/feature/$FEATURE_NAME:1": {}
      }
    }
  ]
}
EOF

# Make test.sh executable
chmod +x "$TEST_DIR/test.sh"

print_info "✅ Test files generated for '$FEATURE_NAME'!"
print_info "📁 Test directory: $TEST_DIR"
print_info "📝 Test script: $TEST_DIR/test.sh"
print_info "⚙️  Scenarios: $TEST_DIR/scenarios.json"
print_info ""
print_info "Next steps:"
print_info "1. Review and customize the generated test files"
print_info "2. Update the test.sh with feature-specific checks"
print_info "3. Add more scenarios to scenarios.json if needed"
print_info "4. Run tests locally: devcontainer features test -f $FEATURE_NAME ."