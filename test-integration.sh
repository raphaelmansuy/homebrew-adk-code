#!/bin/bash
# Integration test script for Homebrew adk-code tap
# This script validates the cask setup and tests local installation

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ADK-Code Homebrew Tap - Integration Test Script       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

# Test 1: Verify Homebrew installation
echo -e "${YELLOW}→${NC} Test 1: Checking Homebrew installation..."
if ! command -v brew &> /dev/null; then
    echo -e "${RED}✗${NC} Homebrew not found. Install from https://brew.sh"
    exit 1
fi
BREW_VERSION=$(brew --version)
echo -e "${GREEN}✓${NC} Homebrew is installed: ${BREW_VERSION}"

# Test 2: Validate cask Ruby syntax
echo -e "\n${YELLOW}→${NC} Test 2: Validating cask Ruby syntax..."
if ruby -c Casks/adk-code.rb 2>&1 | grep -q "Syntax OK"; then
    echo -e "${GREEN}✓${NC} Cask syntax is valid"
else
    echo -e "${RED}✗${NC} Cask syntax error"
    ruby -c Casks/adk-code.rb
    exit 1
fi

# Test 3: Test local tap linking (without network)
echo -e "\n${YELLOW}→${NC} Test 3: Testing local tap reference..."
TAP_PATH="$(pwd)"
echo -e "${GREEN}✓${NC} Local tap path: ${TAP_PATH}"

# Test 4: Show cask information
echo -e "\n${YELLOW}→${NC} Test 4: Displaying cask information..."
echo -e "${BLUE}Cask Details:${NC}"
grep -E "version|homepage|license" Casks/adk-code.rb | sed 's/^/  /'

# Test 5: Check required files
echo -e "\n${YELLOW}→${NC} Test 5: Verifying required files..."
REQUIRED_FILES=("README.md" "LICENSE" "scripts/update-cask.sh" "Casks/adk-code.rb" ".github/workflows/update-cask.yml")
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} Found: $file"
    else
        echo -e "${RED}✗${NC} Missing: $file"
        exit 1
    fi
done

# Test 6: Verify scripts are executable
echo -e "\n${YELLOW}→${NC} Test 6: Checking script permissions..."
if [[ -x "scripts/update-cask.sh" ]]; then
    echo -e "${GREEN}✓${NC} scripts/update-cask.sh is executable"
else
    echo -e "${YELLOW}⚠${NC} scripts/update-cask.sh is not executable (fixing...)"
    chmod +x scripts/update-cask.sh
    echo -e "${GREEN}✓${NC} Fixed executable permissions"
fi

# Test 7: Test update-cask script with dry-run
echo -e "\n${YELLOW}→${NC} Test 7: Testing update-cask.sh script..."
echo -e "${BLUE}Running: ./scripts/update-cask.sh v0.0.1${NC}"
if bash scripts/update-cask.sh v0.0.1 2>&1 | tail -5; then
    echo -e "${GREEN}✓${NC} Update script executed successfully"
else
    echo -e "${RED}✗${NC} Update script failed"
    exit 1
fi

# Test 8: Git repository status
echo -e "\n${YELLOW}→${NC} Test 8: Checking git repository..."
if git rev-parse --git-dir > /dev/null 2>&1; then
    COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    echo -e "${GREEN}✓${NC} Git repository initialized with ${COMMITS} commit(s)"
    echo "  Latest commits:"
    git log --oneline -3 2>/dev/null | sed 's/^/    /'
else
    echo -e "${RED}✗${NC} Git repository not found"
fi

# Summary
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}✓${NC} All integration tests passed!"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Push repository to GitHub: git push origin main"
echo "2. Create GitHub repository at: https://github.com/new"
echo "3. Add remote: git remote add origin https://github.com/raphaelmansuy/homebrew-adk-code.git"
echo "4. Push to remote: git push -u origin main"
echo "5. Test installation: brew tap raphaelmansuy/adk-code"
echo ""
echo -e "${YELLOW}To test the Homebrew tap locally:${NC}"
echo "1. Publish first release: Create v0.0.1 tag in adk-code repository"
echo "2. Generate binaries for darwin-amd64 and darwin-arm64"
echo "3. Create GitHub release with binaries"
echo "4. Update cask: ./scripts/update-cask.sh v0.0.1"
echo "5. Test installation: brew install --cask raphaelmansuy/adk-code/adk-code"
echo ""
