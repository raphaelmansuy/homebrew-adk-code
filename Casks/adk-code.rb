cask "adk-code" do
  arch arm: "arm64", intel: "amd64"
  
      version "0.2.0"
      sha256 arm:   "b27cc241b7f90599736c33e25425d77822eedd29c4928b580e8c0eb5e792c9bc",
        intel: "0529194a50217a9457bc887bb96662f755717db874e7bf17b0b38b84cebd1e48"

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

  # v0.2.0 removed the go.mod requirement — no project root is required.

  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
end
