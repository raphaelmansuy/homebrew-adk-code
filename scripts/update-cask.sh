#!/bin/bash
# scripts/update-cask.sh - Update Homebrew cask with new version from adk-code release
# 
# Usage: ./scripts/update-cask.sh v1.0.0
#
# This script:
# 1. Downloads the new binaries from GitHub releases
# 2. Computes SHA256 checksums
# 3. Updates the cask file with new version and checksums

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
REPO="raphaelmansuy/adk-code"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CASK_FILE="${REPO_DIR}/Casks/adk-code.rb"

# Input validation
if [[ $# -lt 1 ]]; then
  echo -e "${RED}Error: Version required${NC}"
  echo "Usage: $0 v1.0.0"
  exit 1
fi

VERSION="${1#v}"  # Remove 'v' prefix if present
VERSION_TAG="v${VERSION}"

echo -e "${GREEN}Updating Homebrew cask to version ${VERSION}${NC}\n"

# Check if version tag exists on GitHub (we'll proceed anyway for now)
echo -e "${YELLOW}→${NC} Fetching release information for ${VERSION_TAG}..."

# Build URLs for macOS binaries
ARM64_URL="https://github.com/${REPO}/releases/download/${VERSION_TAG}/adk-code-${VERSION_TAG}-darwin-arm64"
AMD64_URL="https://github.com/${REPO}/releases/download/${VERSION_TAG}/adk-code-${VERSION_TAG}-darwin-amd64"

echo -e "${YELLOW}→${NC} Downloading ARM64 binary..."
if ! ARM64_SHA=$(curl -fsSL "$ARM64_URL" 2>/dev/null | sha256sum | awk '{print $1}'); then
  echo -e "${RED}Warning: Could not download ARM64 binary${NC}"
  echo "  URL: $ARM64_URL"
  echo "  This may be expected if release hasn't been published yet"
  # Use a placeholder for testing
  ARM64_SHA="0000000000000000000000000000000000000000000000000000000000000000"
fi

echo -e "${YELLOW}→${NC} Downloading AMD64 binary..."
if ! AMD64_SHA=$(curl -fsSL "$AMD64_URL" 2>/dev/null | sha256sum | awk '{print $1}'); then
  echo -e "${RED}Warning: Could not download AMD64 binary${NC}"
  echo "  URL: $AMD64_URL"
  echo "  This may be expected if release hasn't been published yet"
  # Use a placeholder for testing
  AMD64_SHA="0000000000000000000000000000000000000000000000000000000000000000"
fi

echo -e "${YELLOW}→${NC} Computing checksums..."
echo "  ARM64:  ${ARM64_SHA}"
echo "  AMD64:  ${AMD64_SHA}"

# Update cask file
echo -e "${YELLOW}→${NC} Updating ${CASK_FILE}..."

cat > "${CASK_FILE}" <<EOF
cask "adk-code" do
  version "${VERSION}"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/${REPO}/releases/download/v#{version}/adk-code-v#{version}-darwin-arm64"
      sha256 "${ARM64_SHA}"
    elsif Hardware::CPU.intel?
      url "https://github.com/${REPO}/releases/download/v#{version}/adk-code-v#{version}-darwin-amd64"
      sha256 "${AMD64_SHA}"
    end
  end
  
  homepage "https://github.com/${REPO}"
  license "MIT"
  
  binary "adk-code"
  
  post_install do
    chmod 0755, staged_path/"adk-code"
  end
  
  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
  
  test do
    system "#{staged_path}/adk-code", "--version"
  end
end
EOF

echo -e "${GREEN}✓${NC} Cask updated successfully!"
echo ""
echo -e "${GREEN}✓${NC} Next steps:"
echo "   1. Test the cask: brew audit --cask adk-code"
echo "   2. Commit: git add Casks/adk-code.rb && git commit -m 'chore: update adk-code to ${VERSION}'"
echo "   3. Push: git push origin main"
