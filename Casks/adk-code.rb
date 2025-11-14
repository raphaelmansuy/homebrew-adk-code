cask "adk-code" do
  version "0.1.1"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-arm64"
      sha256 "b8639d0e6b7ea9e0d4f99ba768c32741f928b6730d990e991e585ba614287e6f"
    elsif Hardware::CPU.intel?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-amd64"
      sha256 "69958d07a90d0422ef3cb07e0096b6e7858ae075e2b3216cddc924968ea766b7"
    end
  end

  name "adk-code"
  desc "Command-line tool for adk-code"
  homepage "https://github.com/raphaelmansuy/adk-code"

  artifact "adk-code", target: "#{HOMEBREW_PREFIX}/bin/adk-code"

  postflight do
    system "chmod", "+x", "#{HOMEBREW_PREFIX}/bin/adk-code"
  end

  uninstall manual: "adk-code"

  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
end
