# AI Coding Agent Instructions for homebrew-adk-code

## Project Overview

**homebrew-adk-code** is a Homebrew tap (package repository) that distributes pre-compiled macOS binaries of [adk-code](https://github.com/raphaelmansuy/adk-code), a multi-model AI coding assistant. This is NOT the main application repository—it only handles packaging and distribution.

### Key Architectural Constraint
- **Single Cask Definition**: All logic lives in `Casks/adk-code.rb`
- **No Build Process**: Binaries come pre-compiled from upstream adk-code releases; this tap only packages them
- **macOS-Only**: Homebrew Cask is macOS-specific; Formula (in `Formula/`) remains unused
- **Architecture Variants**: Must support both arm64 (Apple Silicon) and amd64 (Intel) with separate SHA256 checksums

## Critical Workflows

### 1. Version Update Workflow (Most Common)
When adk-code releases a new version:

1. **Fetch Release Artifacts**: Download darwin-arm64 and darwin-amd64 binaries from https://github.com/raphaelmansuy/adk-code/releases/tag/v{VERSION}
2. **Compute SHA256**: Use `shasum -a 256 filename` for each binary (critical—incorrect hashes block installation)
3. **Update Cask**: Modify `Casks/adk-code.rb`:
   - Change `version "X.Y.Z"` 
   - Update `sha256 arm: "..."` and `intel: "..."` with exact hashes
   - Update comment if notable fixes included (e.g., "v0.2.1 includes CGO support")
4. **Test Installation**: 
   ```bash
   brew untap raphaelmansuy/adk-code || true
   brew tap raphaelmansuy/adk-code https://github.com/raphaelmansuy/homebrew-adk-code
   brew install raphaelmansuy/adk-code/adk-code
   ```
5. **Commit & Push**: `git commit -m "chore(cask): update to vX.Y.Z"` → `git push`

**Helper Script**: `./scripts/update-cask.sh v0.2.0` automates steps 1-3 (note: it has placeholder SHA logic for testing, verify hashes manually)

### 2. Testing Workflow
Run `./test-integration.sh` to:
- Validate cask Ruby syntax
- Check script permissions
- Verify required files exist
- Test cask update script with dummy version
- Show git commit history

### 3. Automatic Updates (CI/CD)
`.github/workflows/update-cask.yml` monitors upstream adk-code releases and auto-creates PRs (currently not implemented—requires GitHub Actions setup).

## Cask DSL Essentials

**File**: `Casks/adk-code.rb`

### Architecture Handling
```ruby
arch arm: "arm64", intel: "amd64"  # Maps Homebrew arch names to release names
```
Used in URL and binary path: `adk-code-v#{version}-darwin-#{arch}`

### Critical DSL Blocks
- **`livecheck`**: Auto-detects new releases from GitHub; users can run `brew livecheck adk-code`
- **`container type: :naked`**: Tells Homebrew the downloaded file IS the binary (not a tar/zip)
- **`postflight`**: Removes macOS quarantine attribute (`com.apple.quarantine`) so binary runs without "can't be verified" dialogs
- **`zap trash`**: Cleans config dirs on uninstall; paths MUST start with `~/` (tilde expansion)

### Why Each Part Matters
- **SHA256 mismatch** → Homebrew halts install ("SHA256 does not match")
- **Missing `container type: :naked`** → Homebrew tries to extract the binary as an archive
- **Missing postflight xattr** → Users get "macOS cannot verify this app" errors
- **Wrong arch names in URL** → 404 on download (must be "arm64" and "amd64", not "m1"/"intel")

## Common Pitfalls & Solutions

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| "SHA256 does not match" | Typo in hash or wrong binary version | Recompute: `shasum -a 256 binary`, verify against release page |
| Binary not found | Upstream release URL changed or missing | Check https://github.com/raphaelmansuy/adk-code/releases for exact URL format |
| Cask parse error | Invalid Ruby syntax | Run `ruby -c Casks/adk-code.rb` to identify syntax errors |
| "Can't be verified" on run | Postflight xattr block missing or wrong path | Verify `#{HOMEBREW_PREFIX}/bin/adk-code` matches actual installed location |
| Stale version detected | Livecheck broken | Test with `brew livecheck adk-code` |

## File Reference

| File | Purpose | Edit When? |
|------|---------|-----------|
| `Casks/adk-code.rb` | **Main cask definition** | Every upstream version release |
| `scripts/update-cask.sh` | Helper to download + compute SHA256 | Only if upstream binary naming changes |
| `test-integration.sh` | Validation script | Only if tap structure changes |
| `.github/workflows/update-cask.yml` | Auto-update CI/CD (unused) | If implementing automatic PR creation |
| `README.md` | User-facing docs | When adding troubleshooting or new features |

## Development Patterns

### Adding New Features (Examples)

**Want to add automatic SHA256 verification?**
- Add postflight block that validates installed binary matches expected SHA256
- Use `system_command "shasum"` in postflight

**Want to support Linux?**
- Create `Formula/adk-code.rb` (Homebrew formula for compiled binaries)
- Current cask is macOS-only due to upstream binary availability

**Want to pin to specific version?**
- Replace `livecheck` block with fixed version string (remove dynamic version detection)
- Users would use `brew "adk-code@0.2.1"` syntax

## External Dependencies

- **Upstream**: [raphaelmansuy/adk-code](https://github.com/raphaelmansuy/adk-code) releases must include darwin-arm64 and darwin-amd64 binaries
- **Homebrew**: Requires Homebrew 3.4+ (for cask livecheck strategy support)
- **macOS**: Requires 10.13+ (High Sierra); arm64 only works on Apple Silicon Macs

## Important Notes for AI Agents

1. **When in doubt, test locally**: Always run the full install test before committing version changes
2. **SHA256 is not negotiable**: Any hash typo breaks installation; verify twice
3. **GitHub API rate limits apply** if implementing automated checks; use conditional logic
4. **This repo mirrors upstream releases**—never add adk-code features here; suggest PRs upstream
5. **Homebrew syntax evolves**: Comments in cask should explain "why", not "what" (code speaks for itself)
6. **No version lock**: Using `livecheck` means users always see latest; if they want pinning, they use direct repo checkout

## Useful Commands

```bash
# Validate cask syntax
ruby -c Casks/adk-code.rb

# Test livecheck detection
brew livecheck adk-code

# Dry-run cask audit
brew audit --cask --online adk-code

# Check what's installed
brew list adk-code

# Full reinstall (hard reset)
brew untap raphaelmansuy/adk-code
brew tap raphaelmansuy/adk-code https://github.com/raphaelmansuy/homebrew-adk-code
brew install raphaelmansuy/adk-code/adk-code
```
