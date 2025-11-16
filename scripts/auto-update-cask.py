#!/usr/bin/env python3
"""
Automated Cask Update Script for adk-code

This script automates the process of updating the Homebrew cask when a new release is published.

Usage:
    python scripts/auto-update-cask.py [VERSION]
    python scripts/auto-update-cask.py --latest
    python scripts/auto-update-cask.py 0.3.1

Options:
    --latest       Fetch the latest release from GitHub
    --no-test      Skip local installation test
    --no-commit    Skip git commit and push
    --help, -h     Show this help message
"""

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Optional
from urllib import request
from urllib.error import HTTPError, URLError


class Colors:
    """ANSI color codes for terminal output."""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color


class Logger:
    """Simple logger with colored output."""
    
    @staticmethod
    def info(message: str):
        print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")
    
    @staticmethod
    def success(message: str):
        print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")
    
    @staticmethod
    def warning(message: str):
        print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")
    
    @staticmethod
    def error(message: str):
        print(f"{Colors.RED}[ERROR]{Colors.NC} {message}", file=sys.stderr)


class CaskUpdater:
    """Handles the automated update of the Homebrew cask."""
    
    REPO_OWNER = "raphaelmansuy"
    REPO_NAME = "adk-code"
    CASK_FILE = "Casks/adk-code.rb"
    
    def __init__(self, version: Optional[str] = None, run_test: bool = True, run_commit: bool = True):
        self.version = version
        self.run_test = run_test
        self.run_commit = run_commit
        self.temp_dir = None
    
    def __enter__(self):
        self.temp_dir = tempfile.mkdtemp(prefix="adk-code-update-")
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.temp_dir and os.path.exists(self.temp_dir):
            import shutil
            shutil.rmtree(self.temp_dir)
    
    def get_latest_version(self) -> str:
        """Fetch the latest release version from GitHub."""
        Logger.info("Fetching latest release version from GitHub...")
        url = f"https://api.github.com/repos/{self.REPO_OWNER}/{self.REPO_NAME}/releases/latest"
        
        try:
            with request.urlopen(url) as response:
                data = json.loads(response.read().decode())
                version = data['tag_name'].lstrip('v')
                Logger.success(f"Latest version: v{version}")
                return version
        except (HTTPError, URLError, KeyError, json.JSONDecodeError) as e:
            Logger.error(f"Failed to fetch latest version: {e}")
            sys.exit(1)
    
    def check_version_exists(self, version: str) -> bool:
        """Check if the specified version exists in the repository."""
        url = f"https://api.github.com/repos/{self.REPO_OWNER}/{self.REPO_NAME}/releases/tags/v{version}"
        
        try:
            with request.urlopen(url) as response:
                return response.status == 200
        except HTTPError:
            Logger.error(f"Version v{version} does not exist in the repository")
            return False
    
    def download_binary(self, version: str, arch: str) -> Path:
        """Download a binary for the specified version and architecture."""
        url = f"https://github.com/{self.REPO_OWNER}/{self.REPO_NAME}/releases/download/v{version}/adk-code-v{version}-darwin-{arch}"
        output_file = Path(self.temp_dir) / f"adk-code-v{version}-darwin-{arch}"
        
        Logger.info(f"Downloading darwin-{arch} binary...")
        try:
            request.urlretrieve(url, output_file)
            
            if not output_file.exists() or output_file.stat().st_size == 0:
                Logger.error(f"Downloaded file is missing or empty: {output_file}")
                sys.exit(1)
            
            return output_file
        except (HTTPError, URLError) as e:
            Logger.error(f"Failed to download darwin-{arch} binary: {e}")
            sys.exit(1)
    
    def compute_sha256(self, file_path: Path) -> str:
        """Compute SHA256 hash of a file."""
        Logger.info(f"Computing SHA256 for {file_path.name}...")
        sha256_hash = hashlib.sha256()
        
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        
        return sha256_hash.hexdigest()
    
    def download_and_hash(self, version: str, arch: str) -> str:
        """Download binary and compute its SHA256 hash."""
        binary_path = self.download_binary(version, arch)
        sha256 = self.compute_sha256(binary_path)
        Logger.success(f"{arch.upper()} SHA256: {sha256}")
        return sha256
    
    def update_cask_file(self, version: str, arm64_sha: str, amd64_sha: str):
        """Update the cask file with new version and SHA256 hashes."""
        Logger.info(f"Updating cask file: {self.CASK_FILE}")
        
        cask_path = Path(self.CASK_FILE)
        if not cask_path.exists():
            Logger.error(f"Cask file not found: {self.CASK_FILE}")
            sys.exit(1)
        
        # Read the current cask file
        with open(cask_path, 'r') as f:
            content = f.read()
        
        # Create backup
        backup_path = cask_path.with_suffix('.rb.backup')
        with open(backup_path, 'w') as f:
            f.write(content)
        
        # Update version
        content = re.sub(r'version\s+"[^"]*"', f'version "{version}"', content)
        
        # Update SHA256 hashes
        sha256_pattern = r'sha256\s+arm:\s+"[^"]+",\s+intel:\s+"[^"]+"'
        sha256_replacement = f'sha256 arm:   "{arm64_sha}",\n         intel: "{amd64_sha}"'
        content = re.sub(sha256_pattern, sha256_replacement, content, flags=re.MULTILINE)
        
        # Write updated content
        with open(cask_path, 'w') as f:
            f.write(content)
        
        # Verify Ruby syntax
        try:
            subprocess.run(['ruby', '-c', str(cask_path)], 
                          check=True, 
                          capture_output=True, 
                          text=True)
            backup_path.unlink()
            Logger.success("Cask file updated successfully")
        except subprocess.CalledProcessError:
            Logger.error("Cask file has syntax errors. Restoring backup...")
            backup_path.rename(cask_path)
            sys.exit(1)
    
    def test_installation(self):
        """Test the cask installation locally."""
        Logger.info("Testing cask installation...")
        Logger.warning("This will uninstall and reinstall adk-code locally")
        
        try:
            # Untap if already tapped
            subprocess.run(['brew', 'untap', f'{self.REPO_OWNER}/{self.REPO_NAME}'], 
                          capture_output=True)
            
            # Tap the repository
            subprocess.run([
                'brew', 'tap', 
                f'{self.REPO_OWNER}/{self.REPO_NAME}',
                f'https://github.com/{self.REPO_OWNER}/homebrew-{self.REPO_NAME}'
            ], check=True)
            
            # Clear cache
            cache_path = subprocess.run(['brew', '--cache'], 
                                       capture_output=True, 
                                       text=True, 
                                       check=True).stdout.strip()
            cache_downloads = Path(cache_path) / 'downloads'
            if cache_downloads.exists():
                for item in cache_downloads.glob('*adk-code*'):
                    item.unlink()
            
            # Install
            subprocess.run([
                'brew', 'install', 
                f'{self.REPO_OWNER}/{self.REPO_NAME}/{self.REPO_NAME}'
            ], check=True)
            
            Logger.success("Installation test passed")
            
            # Verify binary works
            try:
                which_result = subprocess.run(['which', 'adk-code'], 
                                             capture_output=True, 
                                             text=True, 
                                             check=True)
                Logger.info(f"Binary location: {which_result.stdout.strip()}")
                
                # Test binary execution
                subprocess.run(['adk-code', '--help'], 
                              capture_output=True, 
                              check=True)
                Logger.success("Binary execution test passed")
            except subprocess.CalledProcessError:
                Logger.warning("Binary exists but execution test failed")
            
        except subprocess.CalledProcessError as e:
            Logger.error("Installation test failed")
            sys.exit(1)
    
    def commit_and_push(self, version: str):
        """Commit and push changes to the repository."""
        Logger.info("Committing changes...")
        
        try:
            # Check if there are changes
            result = subprocess.run(['git', 'diff', '--quiet', self.CASK_FILE], 
                                   capture_output=True)
            
            if result.returncode != 0:  # There are changes
                subprocess.run(['git', 'add', self.CASK_FILE], check=True)
                subprocess.run(['git', 'commit', '-m', 
                              f'chore(cask): update adk-code to v{version}'], 
                              check=True)
                
                Logger.info("Pushing to remote repository...")
                subprocess.run(['git', 'push', 'origin', 'main'], check=True)
                Logger.success("Changes pushed successfully")
            else:
                Logger.warning("No changes to commit")
        
        except subprocess.CalledProcessError:
            Logger.error("Failed to commit/push changes")
            sys.exit(1)
    
    def show_diff(self):
        """Display the changes made to the cask file."""
        Logger.info("Changes to be committed:")
        try:
            result = subprocess.run(['git', 'diff', self.CASK_FILE], 
                                   capture_output=True, 
                                   text=True, 
                                   check=True)
            print(result.stdout)
        except subprocess.CalledProcessError:
            pass
    
    def run(self):
        """Execute the update process."""
        Logger.info("Starting automated cask update process...")
        
        # Check if we're in the right directory
        if not Path(self.CASK_FILE).exists():
            Logger.error("Cask file not found. Please run this script from the repository root.")
            sys.exit(1)
        
        # Determine version
        if not self.version or self.version == "latest":
            self.version = self.get_latest_version()
        else:
            Logger.info(f"Using specified version: v{self.version}")
            if not self.check_version_exists(self.version):
                sys.exit(1)
        
        # Download and hash binaries
        Logger.info("Processing darwin-arm64...")
        arm64_sha = self.download_and_hash(self.version, "arm64")
        
        Logger.info("Processing darwin-amd64...")
        amd64_sha = self.download_and_hash(self.version, "amd64")
        
        # Update cask file
        self.update_cask_file(self.version, arm64_sha, amd64_sha)
        
        # Display changes
        self.show_diff()
        
        # Test installation
        if self.run_test:
            self.test_installation()
        else:
            Logger.warning("Skipping installation test (--no-test flag)")
        
        # Commit and push
        if self.run_commit:
            self.commit_and_push(self.version)
        else:
            Logger.warning("Skipping commit and push (--no-commit flag)")
            Logger.info("You can manually commit with:")
            Logger.info(f"  git add {self.CASK_FILE}")
            Logger.info(f"  git commit -m 'chore(cask): update adk-code to v{self.version}'")
            Logger.info("  git push origin main")
        
        # Summary
        Logger.success("Update process completed successfully!")
        Logger.info(f"Cask updated to version: v{self.version}")
        Logger.info(f"ARM64 SHA256: {arm64_sha}")
        Logger.info(f"AMD64 SHA256: {amd64_sha}")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Automated Cask Update Script for adk-code",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        'version',
        nargs='?',
        help='Specific version to update to (e.g., 0.3.1)'
    )
    
    parser.add_argument(
        '--latest',
        action='store_true',
        help='Fetch and use the latest release from GitHub'
    )
    
    parser.add_argument(
        '--no-test',
        action='store_true',
        help='Skip local installation test'
    )
    
    parser.add_argument(
        '--no-commit',
        action='store_true',
        help='Skip git commit and push'
    )
    
    args = parser.parse_args()
    
    # Determine version
    version = args.version
    if args.latest:
        version = "latest"
    
    # Run the updater
    with CaskUpdater(
        version=version,
        run_test=not args.no_test,
        run_commit=not args.no_commit
    ) as updater:
        updater.run()


if __name__ == "__main__":
    main()
