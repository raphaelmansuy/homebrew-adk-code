cask "adk-code" do
  version "0.0.1"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-arm64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    elsif Hardware::CPU.intel?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-amd64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end
  
  homepage "https://github.com/raphaelmansuy/adk-code"
  license :mit
  
  binary "adk-code"
  
  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
  
  test do
    system "#{staged_path}/adk-code", "--version"
  end
end
