# Automation Scripts

This directory contains automation scripts for maintaining the adk-code Homebrew tap.

## Scripts

### 1. `auto-update-cask.sh` (Bash)

Automated script to update the Homebrew cask when a new release is published.

#### Prerequisites
- `curl` - For downloading files
- `shasum` - For computing SHA256 hashes
- `git` - For committing changes
- `brew` - For testing installation (optional)

#### Usage

**Update to the latest release:**
```bash
./scripts/auto-update-cask.sh --latest
```

**Update to a specific version:**
```bash
./scripts/auto-update-cask.sh 0.3.1
```

**Update without testing locally:**
```bash
./scripts/auto-update-cask.sh --latest --no-test
```

**Update without committing/pushing:**
```bash
./scripts/auto-update-cask.sh 0.3.1 --no-commit
```

**Show help:**
```bash
./scripts/auto-update-cask.sh --help
```

#### Options
- `--latest` - Fetch and use the latest release from GitHub
- `--no-test` - Skip local installation test
- `--no-commit` - Skip git commit and push
- `--help`, `-h` - Show help message

---

### 2. `auto-update-cask.py` (Python)

Python version of the automated cask updater with the same functionality.

#### Prerequisites
- Python 3.6+
- `git` - For committing changes
- `brew` - For testing installation (optional)

#### Usage

**Update to the latest release:**
```bash
python3 scripts/auto-update-cask.py --latest
```

**Update to a specific version:**
```bash
python3 scripts/auto-update-cask.py 0.3.1
```

**Update without testing locally:**
```bash
python3 scripts/auto-update-cask.py --latest --no-test
```

**Update without committing/pushing:**
```bash
python3 scripts/auto-update-cask.py 0.3.1 --no-commit
```

**Show help:**
```bash
python3 scripts/auto-update-cask.py --help
```

#### Options
- `--latest` - Fetch and use the latest release from GitHub
- `--no-test` - Skip local installation test
- `--no-commit` - Skip git commit and push
- `-h`, `--help` - Show help message

---

### 3. `update-cask.sh` (Legacy)

Original manual update script. Use the automated scripts above instead.

---

## What the Automated Scripts Do

1. **Fetch Version**: Gets the latest release version from GitHub or uses the specified version
2. **Download Binaries**: Downloads both darwin-arm64 and darwin-amd64 binaries
3. **Compute Hashes**: Calculates SHA256 hashes for both binaries
4. **Update Cask**: Updates `Casks/adk-code.rb` with new version and hashes
5. **Validate Syntax**: Checks Ruby syntax is correct
6. **Test Installation** (optional): Tests the cask installation locally
7. **Commit & Push** (optional): Commits changes and pushes to GitHub

## Examples

### Quick update to latest version with full testing
```bash
./scripts/auto-update-cask.sh --latest
```

### Update to specific version without automatic commit
```bash
./scripts/auto-update-cask.py 0.3.2 --no-commit
# Review changes
git diff Casks/adk-code.rb
# Commit manually if satisfied
git add Casks/adk-code.rb
git commit -m "chore(cask): update adk-code to v0.3.2"
git push origin main
```

### Test update locally before committing
```bash
# Update without committing
./scripts/auto-update-cask.sh --latest --no-commit

# Test manually
brew untap raphaelmansuy/adk-code
brew tap raphaelmansuy/adk-code https://github.com/raphaelmansuy/homebrew-adk-code
brew install raphaelmansuy/adk-code/adk-code

# If tests pass, commit manually
git add Casks/adk-code.rb
git commit -m "chore(cask): update adk-code to vX.Y.Z"
git push origin main
```

## Troubleshooting

### Script fails to download binaries
- Check that the release exists on GitHub
- Verify the binary naming convention matches: `adk-code-vX.Y.Z-darwin-{arm64,amd64}`

### Ruby syntax errors
- The script validates Ruby syntax automatically
- If validation fails, the backup is restored
- Check the cask file manually with: `ruby -c Casks/adk-code.rb`

### Installation test fails
- Use `--no-test` flag to skip testing
- Test manually after the update
- Check Homebrew cache: `ls -la "$(brew --cache)/downloads"`

### Git push fails
- Ensure you have push permissions to the repository
- Check your git credentials: `git config --list | grep user`
- Use `--no-commit` to review changes before pushing

## Script Output

Both scripts provide colored output:
- 🔵 **INFO** - Information messages
- 🟢 **SUCCESS** - Successful operations
- 🟡 **WARNING** - Non-critical warnings
- 🔴 **ERROR** - Critical errors

## Contributing

When modifying these scripts:
1. Test with `--no-commit` flag first
2. Verify both bash and Python versions work
3. Update this README if adding new features
4. Test with both latest and specific version scenarios
