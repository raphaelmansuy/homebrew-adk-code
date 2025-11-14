cask "adk-code" do
  version "0.0.1"
  sha256 :no_check
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-arm64"
    elsif Hardware::CPU.intel?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-amd64"
    end
  end

  name "adk-code"
  desc "Command-line tool for adk-code"
  homepage "https://github.com/raphaelmansuy/adk-code"

  binary "adk-code"

  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
end
