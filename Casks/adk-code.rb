cask "adk-code" do
  arch arm: "arm64", intel: "amd64"

  version "0.3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-arm64"
      sha256 "91309bf50709de94a2bb7cba5f3f1df0abcf4e3097e5614f4d77ce7aa601e460"
    elsif Hardware::CPU.intel?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-amd64"
      sha256 "e0bd729f61114a4e68780a6a21d7bb61c9931438a43232b14d2f4e7c87b913c9"
    end
  end

  name "adk-code"
  desc "Multi-model AI coding assistant CLI powered by Google ADK"
  homepage "https://github.com/raphaelmansuy/adk-code"

  livecheck do
    url "https://github.com/raphaelmansuy/adk-code/releases.atom"
    regex(%r{/releases/tag/v?(\d+(?:\.\d+)*)}i)
    strategy :github_latest
  end

  binary "adk-code"

  postflight do
    system_command "xattr",
                   args: ["-d", "com.apple.quarantine", "#{HOMEBREW_PREFIX}/bin/adk-code"],
                   sudo: false
  end

  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
end