# Homebrew Tap for adk-code

This is the official Homebrew tap for [adk-code](https://github.com/raphaelmansuy/adk-code), a multi-model AI coding assistant CLI powered by Google ADK.

## Installation

### Add the tap

```bash
brew tap raphaelmansuy/adk-code
```

### Install adk-code

```bash
brew install adk-code
```

### Update to latest version

```bash
brew upgrade adk-code
```

### Uninstall

```bash
brew uninstall adk-code
```

## Usage

After installation, you can use `adk-code` directly from the command line:

```bash
adk-code --help
```

For detailed usage information, see the [main adk-code repository](https://github.com/raphaelmansuy/adk-code).

## What's Included

This tap provides:

- **Cask**: Pre-compiled binary packages for macOS (both Intel and Apple Silicon)
- **Automatic Updates**: Keep up-to-date with Homebrew's built-in update mechanisms
- **Dependency Management**: Automatic resolution of any system dependencies

## Supported Platforms

- **macOS 10.13+** (High Sierra and later)
- **Intel (x86_64)** - amd64 architecture
- **Apple Silicon (arm64)** - Apple Silicon/M-series chips

## Features

- ✅ Pre-compiled binaries (no compilation required)
- ✅ Fast installation (~5-10 seconds)
- ✅ **Automatic version detection** from GitHub releases
- ✅ One-command installation and updates
- ✅ Integration with standard macOS installer tools
- ✅ Always installs the latest stable release
- ✅ Cross-platform support (macOS Intel + Apple Silicon)
- ✅ Automatic quarantine removal for seamless execution

## Verification

To verify the integrity of the installed binary:

```bash
# Check the binary location
which adk-code

# Verify it works (note: use without --version flag)
adk-code --help

# Check installed version
brew list --versions adk-code

# Check SHA256 (optional, path may vary by architecture)
shasum -a 256 $(brew --prefix)/bin/adk-code
```

## Troubleshooting

### Cask not found

```bash
# Make sure the tap is added
brew tap raphaelmansuy/adk-code

# Update Homebrew
brew update
```

### Permission denied when running adk-code

```bash
# Fix permissions
chmod +x $(brew --prefix)/bin/adk-code
```

### SHA256 mismatch errors

```bash
# Clear Homebrew cache and reinstall
brew uninstall adk-code
rm -rf "$(brew --cache)/downloads/*adk-code*"
brew install adk-code
```

### Remove old versions

```bash
# Clean up old installations
brew cleanup adk-code

# Or check what would be removed
brew cleanup --dry-run adk-code
```

## Reporting Issues

If you encounter any issues with the Homebrew installation:

1. Check the [adk-code repository issues](https://github.com/raphaelmansuy/adk-code/issues)
2. Run `brew doctor` to check your Homebrew installation
3. Provide the output of `brew install -v adk-code` (verbose install)

## Related Documentation

- [adk-code Repository](https://github.com/raphaelmansuy/adk-code)
- [Homebrew Documentation](https://docs.brew.sh/)
- [Homebrew Tap Concepts](https://docs.brew.sh/Taps)
- [Homebrew Cask Documentation](https://docs.brew.sh/Cask-Cookbook)

## Cask Contents

### Included Files

- `adk-code` - Main executable binary

### Configuration Directories (created on first run)

- `~/.adk-code/` - Configuration files (if needed)
- `~/.config/adk-code/` - XDG config directory (on Linux-compatible shells)

### Removal

When uninstalling with `brew uninstall adk-code`, Homebrew will offer to remove the configuration directory:

```bash
brew uninstall adk-code
```

## Maintenance

This tap uses **livecheck** to automatically detect new versions from GitHub releases:

- The cask is manually updated with specific version numbers and SHA256 checksums
- `livecheck` monitors the [adk-code GitHub releases](https://github.com/raphaelmansuy/adk-code/releases) for new versions
- Users get notified of updates via `brew outdated` and can upgrade with `brew upgrade adk-code`

## License

adk-code is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file in this repository.

## Support

For support, issues, and feature requests:

- 🐛 [Report bugs](https://github.com/raphaelmansuy/adk-code/issues)
- 💡 [Request features](https://github.com/raphaelmansuy/adk-code/discussions)
- 📖 [Read documentation](https://github.com/raphaelmansuy/adk-code/docs)

## How Version Detection Works

The cask uses Homebrew's `livecheck` feature to:

1. Monitor the [adk-code GitHub releases](https://github.com/raphaelmansuy/adk-code/releases)
2. Automatically detect new releases via the GitHub atom feed
3. Extract version numbers using regex pattern matching
4. Dynamically construct download URLs for the latest version

You can manually check for updates with:

```bash
brew livecheck adk-code
```

### Manual Update Process

When a new release is published in the upstream [adk-code repository](https://github.com/raphaelmansuy/adk-code):

1. Download both darwin-arm64 and darwin-amd64 binaries from the release
2. Compute SHA256 hashes using `shasum -a 256`
3. Update `Casks/adk-code.rb` with new version and hashes
4. Test installation locally with `brew install --cask adk-code`
5. Commit and push changes to the repository

Users can check for new versions with:

```bash
brew livecheck adk-code
brew outdated --cask
```

**Note**: This is the official tap for adk-code. For usage documentation and feature requests, refer to the [main adk-code repository](https://github.com/raphaelmansuy/adk-code).
