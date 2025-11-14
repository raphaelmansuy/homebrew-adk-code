cask "adk-code" do
  arch arm: "arm64", intel: "amd64"
  
    version "0.2.0"
    sha256 arm:   "ce07640021cc57e7bb38464e8828fbcce62fcdf3643fa166cbe34f3dcddb0f5b",
      intel: "b27cc241b7f90599736c33e25425d77822eedd29c4928b580e8c0eb5e792c9bc"

  url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-#{arch}"
  name "adk-code"
  desc "Command-line tool for adk-code"
  homepage "https://github.com/raphaelmansuy/adk-code"

  container type: :naked

  binary "adk-code-v#{version}-darwin-#{arch}", target: "adk-code"

  postflight do
    system_command "xattr",
                   args: ["-d", "com.apple.quarantine", "#{HOMEBREW_PREFIX}/bin/adk-code"],
                   sudo: false
  end

  # v0.2.0 removed the go.mod requirement — no project root is required.

  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
end
