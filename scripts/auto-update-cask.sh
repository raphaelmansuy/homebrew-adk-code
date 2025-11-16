#!/usr/bin/env bash

# Automated Cask Update Script for adk-code
# This script automates the process of updating the Homebrew cask when a new release is published.
#
# Usage:
#   ./scripts/auto-update-cask.sh [VERSION]
#   ./scripts/auto-update-cask.sh --latest
#   ./scripts/auto-update-cask.sh 0.3.1
#
# Options:
#   --latest       Fetch the latest release from GitHub
#   --no-test      Skip local installation test
#   --no-commit    Skip git commit and push
#   --help         Show this help message

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="raphaelmansuy"
REPO_NAME="adk-code"
CASK_FILE="Casks/adk-code.rb"
TEMP_DIR="/tmp/adk-code-update-$$"

# Flags
RUN_TEST=true
RUN_COMMIT=true
VERSION=""

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    cat << EOF
Automated Cask Update Script for adk-code

Usage:
  $0 [OPTIONS] [VERSION]

Arguments:
  VERSION        Specific version to update to (e.g., 0.3.1)

Options:
  --latest       Fetch and use the latest release from GitHub
  --no-test      Skip local installation test
  --no-commit    Skip git commit and push
  --help, -h     Show this help message

Examples:
  $0 --latest                    # Update to latest release
  $0 0.3.1                       # Update to specific version
  $0 --latest --no-commit        # Update without committing
  $0 0.3.1 --no-test            # Update without testing

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --latest)
            VERSION="latest"
            shift
            ;;
        --no-test)
            RUN_TEST=false
            shift
            ;;
        --no-commit)
            RUN_COMMIT=false
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            if [[ -z "$VERSION" ]]; then
                VERSION="$1"
            else
                print_error "Unknown option: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Function to get the latest release version
get_latest_version() {
    print_info "Fetching latest release version from GitHub..."
    local latest_version
    latest_version=$(curl -sL "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"tag_name": "v?([^"]+)".*/\1/')
    
    if [[ -z "$latest_version" ]]; then
        print_error "Failed to fetch latest version"
        exit 1
    fi
    
    echo "$latest_version"
}

# Function to check if version exists
check_version_exists() {
    local version="$1"
    local url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/v${version}"
    
    if ! curl -sf "$url" > /dev/null; then
        print_error "Version v${version} does not exist in the repository"
        return 1
    fi
    return 0
}

# Function to download binary and compute SHA256
download_and_hash() {
    local version="$1"
    local arch="$2"
    local url="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/v${version}/adk-code-v${version}-darwin-${arch}"
    local output_file="${TEMP_DIR}/adk-code-v${version}-darwin-${arch}"
    
    print_info "Downloading darwin-${arch} binary..."
    if ! curl -sL -o "$output_file" "$url"; then
        print_error "Failed to download darwin-${arch} binary"
        return 1
    fi
    
    if [[ ! -f "$output_file" ]] || [[ ! -s "$output_file" ]]; then
        print_error "Downloaded file is missing or empty: $output_file"
        return 1
    fi
    
    print_info "Computing SHA256 for darwin-${arch}..."
    local sha256
    sha256=$(shasum -a 256 "$output_file" | awk '{print $1}')
    
    if [[ -z "$sha256" ]]; then
        print_error "Failed to compute SHA256 for darwin-${arch}"
        return 1
    fi
    
    echo "$sha256"
}

# Function to update the cask file
update_cask_file() {
    local version="$1"
    local arm64_sha="$2"
    local amd64_sha="$3"
    
    print_info "Updating cask file: ${CASK_FILE}"
    
    # Create a backup
    cp "$CASK_FILE" "${CASK_FILE}.backup"
    
    # Update version
    sed -i '' "s/version \"[^\"]*\"/version \"${version}\"/" "$CASK_FILE"
    
    # Update SHA256 hashes
    # This handles the multi-line sha256 format
    awk -v arm64="$arm64_sha" -v amd64="$amd64_sha" '
    /sha256 arm:/ {
        print "  sha256 arm:   \"" arm64 "\","
        getline
        print "         intel: \"" amd64 "\""
        next
    }
    {print}
    ' "$CASK_FILE" > "${CASK_FILE}.tmp"
    
    mv "${CASK_FILE}.tmp" "$CASK_FILE"
    
    # Verify the Ruby syntax
    if ! ruby -c "$CASK_FILE" > /dev/null 2>&1; then
        print_error "Cask file has syntax errors. Restoring backup..."
        mv "${CASK_FILE}.backup" "$CASK_FILE"
        return 1
    fi
    
    rm -f "${CASK_FILE}.backup"
    print_success "Cask file updated successfully"
}

# Function to test installation
test_installation() {
    print_info "Testing cask installation..."
    print_warning "This will uninstall and reinstall adk-code locally"
    
    # Untap if already tapped
    brew untap "${REPO_OWNER}/${REPO_NAME}" 2>/dev/null || true
    
    # Tap the local repository
    brew tap "${REPO_OWNER}/${REPO_NAME}" "https://github.com/${REPO_OWNER}/homebrew-${REPO_NAME}"
    
    # Clear cache
    rm -rf "$(brew --cache)/downloads/"*adk-code* 2>/dev/null || true
    
    # Install
    if brew install "${REPO_OWNER}/${REPO_NAME}/${REPO_NAME}"; then
        print_success "Installation test passed"
        
        # Verify binary works
        if command -v adk-code &> /dev/null; then
            print_info "Binary location: $(which adk-code)"
            print_info "Testing binary execution..."
            if adk-code --help > /dev/null 2>&1; then
                print_success "Binary execution test passed"
            else
                print_warning "Binary exists but execution test failed"
            fi
        else
            print_warning "Binary not found in PATH"
        fi
    else
        print_error "Installation test failed"
        return 1
    fi
}

# Function to commit and push changes
commit_and_push() {
    local version="$1"
    
    print_info "Committing changes..."
    
    if ! git diff --quiet "$CASK_FILE"; then
        git add "$CASK_FILE"
        git commit -m "chore(cask): update adk-code to v${version}"
        
        print_info "Pushing to remote repository..."
        if git push origin main; then
            print_success "Changes pushed successfully"
        else
            print_error "Failed to push changes"
            return 1
        fi
    else
        print_warning "No changes to commit"
    fi
}

# Function to cleanup
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Main execution
main() {
    print_info "Starting automated cask update process..."
    
    # Check if we're in the right directory
    if [[ ! -f "$CASK_FILE" ]]; then
        print_error "Cask file not found. Please run this script from the repository root."
        exit 1
    fi
    
    # Determine version
    if [[ -z "$VERSION" ]] || [[ "$VERSION" == "latest" ]]; then
        VERSION=$(get_latest_version)
        print_success "Latest version: v${VERSION}"
    else
        print_info "Using specified version: v${VERSION}"
        if ! check_version_exists "$VERSION"; then
            exit 1
        fi
    fi
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    # Download and hash binaries
    print_info "Processing darwin-arm64..."
    ARM64_SHA=$(download_and_hash "$VERSION" "arm64")
    if [[ -z "$ARM64_SHA" ]]; then
        cleanup
        exit 1
    fi
    print_success "ARM64 SHA256: $ARM64_SHA"
    
    print_info "Processing darwin-amd64..."
    AMD64_SHA=$(download_and_hash "$VERSION" "amd64")
    if [[ -z "$AMD64_SHA" ]]; then
        cleanup
        exit 1
    fi
    print_success "AMD64 SHA256: $AMD64_SHA"
    
    # Update cask file
    if ! update_cask_file "$VERSION" "$ARM64_SHA" "$AMD64_SHA"; then
        cleanup
        exit 1
    fi
    
    # Display the changes
    print_info "Changes to be committed:"
    git diff "$CASK_FILE"
    
    # Test installation
    if [[ "$RUN_TEST" == true ]]; then
        if ! test_installation; then
            print_error "Installation test failed. Not committing changes."
            cleanup
            exit 1
        fi
    else
        print_warning "Skipping installation test (--no-test flag)"
    fi
    
    # Commit and push
    if [[ "$RUN_COMMIT" == true ]]; then
        commit_and_push "$VERSION"
    else
        print_warning "Skipping commit and push (--no-commit flag)"
        print_info "You can manually commit with:"
        print_info "  git add $CASK_FILE"
        print_info "  git commit -m 'chore(cask): update adk-code to v${VERSION}'"
        print_info "  git push origin main"
    fi
    
    # Cleanup
    cleanup
    
    print_success "Update process completed successfully!"
    print_info "Cask updated to version: v${VERSION}"
    print_info "ARM64 SHA256: $ARM64_SHA"
    print_info "AMD64 SHA256: $AMD64_SHA"
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
main
