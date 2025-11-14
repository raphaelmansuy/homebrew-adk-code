cask "adk-code" do
  arch arm: "arm64", intel: "amd64"
  
  version "0.1.1"
  sha256 arm:   "b8639d0e6b7ea9e0d4f99ba768c32741f928b6730d990e991e585ba614287e6f",
         intel: "69958d07a90d0422ef3cb07e0096b6e7858ae075e2b3216cddc924968ea766b7"

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

  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
end
