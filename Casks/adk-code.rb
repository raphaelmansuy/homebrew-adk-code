cask "adk-code" do
  arch arm: "arm64", intel: "amd64"

  version "0.3.0"
  sha256 arm:   "ecd031e413bf958e8b6c01a39e1d577c23b5f1727b91cd726e5b6cfc30869ea9",
         intel: "e0bd729f61114a4e68780a6a21d7bb61c9931438a43232b14d2f4e7c87b913c9"

  url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-#{arch}"
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
                   sudo: false,
                   must_succeed: false
  end

  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
end