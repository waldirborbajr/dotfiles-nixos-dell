#!/bin/bash
set -euf -o pipefail

# Fetch the latest stable Go version from https://go.dev/dl/
echo "Fetching the latest stable Go version..."
LATEST_VERSION=$(curl -s https://go.dev/dl/ | grep -oP 'go\K[0-9]+\.[0-9]+(\.[0-9]+)?' | sort -V | tail -1)
if [[ -z "$LATEST_VERSION" ]]; then
  echo "Error: Could not fetch the latest Go version. Exiting."
  exit 1
fi
echo "Latest Go version available: ${LATEST_VERSION}"

# Check if Go is already installed and get its version
INSTALLED_VERSION=""
if command -v go &> /dev/null; then
  INSTALLED_VERSION=$(go version | grep -oP 'go\K[0-9]+\.[0-9]+(\.[0-9]+)?')
  echo "Installed Go version: ${INSTALLED_VERSION}"
else
  echo "No Go installation found."
fi

PLATFORM="linux-amd64" # Adjust if your system architecture is different (e.g., linux-arm64)

# Compare versions and skip if the installed version is the latest
if [[ "$INSTALLED_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Go version ${LATEST_VERSION} is already installed and up to date."
  # Ensure environment variables are set even if we skip installation
  echo "Verifying Go environment variables..."
  PROFILE_FILE="$HOME/.zshrc"
  if ! grep -q "export PATH=\"\$PATH\":/usr/local/go/bin" "$PROFILE_FILE"; then
    echo "export PATH=\"\$PATH\":/usr/local/go/bin" >> "$PROFILE_FILE"
  fi
  if ! grep -q "export GOPATH=\$HOME/go" "$PROFILE_FILE"; then
    echo "export GOPATH=\$HOME/go" >> "$PROFILE_FILE"
  fi
  if ! grep -q "export PATH=\"\$PATH\":\$GOPATH/bin" "$PROFILE_FILE"; then
    echo "export PATH=\"\$PATH\":\$GOPATH/bin" >> "$PROFILE_FILE"
  fi
  source "$PROFILE_FILE"
  echo "Go environment variables verified."
  go version
  exit 0
fi

# Download the latest Go release if needed
echo "Downloading Go version ${LATEST_VERSION} for ${PLATFORM}..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
if ! curl -sL -o "go${LATEST_VERSION}.${PLATFORM}.tar.gz" "https://golang.org/dl/go${LATEST_VERSION}.${PLATFORM}.tar.gz"; then
  echo "Error: Failed to download Go. Check your internet connection or the version availability."
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Remove the old Go installation
echo "Removing old Go version..."
sudo rm -rf /usr/local/go

# Install the new Go version
echo "Installing new Go version..."
sudo tar -C /usr/local -xzf "go${LATEST_VERSION}.${PLATFORM}.tar.gz"

# Set up Go environment variables (if not already configured in your shell profile)
echo "Setting up Go environment variables..."
PROFILE_FILE="$HOME/.zshrc"
if ! grep -q "export PATH=\"\$PATH\":/usr/local/go/bin" "$PROFILE_FILE"; then
  echo "export PATH=\"\$PATH\":/usr/local/go/bin" >> "$PROFILE_FILE"
fi
if ! grep -q "export GOPATH=\$HOME/go" "$PROFILE_FILE"; then
  echo "export GOPATH=\$HOME/go" >> "$PROFILE_FILE"
fi
if ! grep -q "export PATH=\"\$PATH\":\$GOPATH/bin" "$PROFILE_FILE"; then
  echo "export PATH=\"\$PATH\":\$GOPATH/bin" >> "$PROFILE_FILE"
fi

# Source the profile to apply changes immediately
source "$PROFILE_FILE"

# Verify PATH includes Go bin
if [[ ":$PATH:" != *":/usr/local/go/bin:"* ]]; then
  echo "Warning: /usr/local/go/bin not in PATH. Restart your terminal or run 'source ~/.zshrc' manually."
else
  echo "PATH updated successfully."
fi

# Create the Go workspace directories if they don't exist
mkdir -p ~/go/{bin,pkg,src}

# Clean up downloaded archive
echo "Cleaning up downloaded files..."
cd "$HOME"  # Change back to home directory before cleanup
rm "go${LATEST_VERSION}.${PLATFORM}.tar.gz"
rmdir "$TEMP_DIR"

echo "Go update completed. Current Go version:"
if command -v go &> /dev/null; then
  go version
else
  echo "Go is installed but not yet in PATH. Run 'source ~/.zshrc' and try 'go version' again."
fi
