#!/usr/bin/env bash

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

K9S_VERSION=${VERSION:-"latest"}

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Update apt-get if necessary
if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
    echo "Running apt-get update..."
    apt-get update -y
fi

# Install required packages if not already installed
if ! dpkg -s curl git tar > /dev/null 2>&1; then
    apt-get -y install --no-install-recommends curl git tar
fi

# Determine architecture
architecture="$(uname -m)"
if [ "$architecture" = "x86_64" ]; then
    architecture_="amd64"
elif [ "$architecture" = "aarch64" ] || [[ "$architecture" =~ armv8* ]] || [ "$architecture" = "arm64" ]; then
    architecture_="arm64"
else
    echo "(!) Architecture $architecture unsupported"
    exit 1
fi

# Fetch the latest version of k9s if not specified
if [ "$K9S_VERSION" = "latest" ]; then
    version_list=$(git ls-remote --tags https://github.com/derailed/k9s | grep -oP "tags/v\K[0-9]+\.[0-9]+\.[0-9]+$" | sort -rV | head -n 1)
    K9S_VERSION="$version_list"
elif ! [[ "$K9S_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid K9S_VERSION value: $K9S_VERSION"
    exit 1
fi

# Prepare temporary directory
TMP_DIR="/tmp/tmp-k9s"
mkdir -p "$TMP_DIR"
chmod 700 "$TMP_DIR"

# Download and install k9s
echo "(*) Installing k9s..."
curl -sSL -o "$TMP_DIR/k9s.tar.gz" "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${architecture_}.tar.gz"
tar -xzf "$TMP_DIR/k9s.tar.gz" -C "$TMP_DIR" k9s
mv "$TMP_DIR/k9s" /usr/local/bin/k9s
chmod 0755 /usr/local/bin/k9s

# Clean up
rm -rf /var/lib/apt/lists/* "$TMP_DIR"

echo "Done!"
