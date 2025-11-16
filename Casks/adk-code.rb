cask "adk-code" do
  arch arm: "arm64", intel: "amd64"

  version :latest
  sha256 :no_check

  url do |version|
    "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-#{arch}"
  end

  name "adk-code"
  desc "Multi-model AI coding assistant CLI powered by Google ADK"
  homepage "https://github.com/raphaelmansuy/adk-code"

  livecheck do
    url "https://github.com/raphaelmansuy/adk-code/releases.atom"
    regex(%r{/releases/tag/v?(\d+(?:\.\d+)*)}i)
    strategy :github_latest
  end

  container type: :naked

  binary "adk-code-v#{version}-darwin-#{arch}", target: "adk-code"

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
