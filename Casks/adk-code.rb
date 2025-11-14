cask "adk-code" do
  arch arm: "arm64", intel: "amd64"
  
      version "0.2.1"
      sha256 arm:   "ff75da3afba2030751a1dc8202956db1530827545673786ff2ffc48fa1f5faad",
        intel: "f2bb99340062d344385b5bd71569ea0c7a1957b251d32f83ab5d6c1a7537de89"

  url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-#{arch}"
  name "adk-code"
  desc "Command-line tool for adk-code"
  homepage "https://github.com/raphaelmansuy/adk-code"

  livecheck do
    url :url
    strategy :github_latest
  end

  container type: :naked

  binary "adk-code-v#{version}-darwin-#{arch}", target: "adk-code"

  postflight do
    system_command "xattr",
                   args: ["-d", "com.apple.quarantine", "#{HOMEBREW_PREFIX}/bin/adk-code"],
                   sudo: false
  end

  # v0.2.1 includes CGO support for SQLite (PR #9)

  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
end
