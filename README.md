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

## Verification

To verify the integrity of the installed binary:

```bash
# Check the binary location
which adk-code

# Verify it works
adk-code --version

# Check SHA256 (optional)
shasum -a 256 /usr/local/bin/adk-code
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
chmod +x /usr/local/bin/adk-code
```

### Remove old versions

```bash
# Clean up old installations
brew cleanup adk-code

# Or remove all old bottles
brew cleanup --dry-run
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

This tap uses **automatic version detection** from GitHub releases:

- The cask dynamically fetches the latest version from the [adk-code repository](https://github.com/raphaelmansuy/adk-code)
- No manual version updates required—always points to the latest stable release
- `brew upgrade adk-code` automatically downloads and installs the newest version
- Version detection uses GitHub's atom feed for reliable release tracking

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

---

**Note**: This is an unofficial tap maintained for convenience. For the most up-to-date information about adk-code, always refer to the [main adk-code repository](https://github.com/raphaelmansuy/adk-code).
