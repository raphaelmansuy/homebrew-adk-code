cask "adk-code" do
  version "0.0.1"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-arm64"
      sha256 "6528e5f4c7b5e6e5e8e6e5e6e5e6e5e6e5e6e5e6e5e6e5e6e5e6e5e6e5e6e5" # Placeholder - will be updated
    elsif Hardware::CPU.intel?
      url "https://github.com/raphaelmansuy/adk-code/releases/download/v#{version}/adk-code-v#{version}-darwin-amd64"
      sha256 "5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e" # Placeholder - will be updated
    end
  end
  
  homepage "https://github.com/raphaelmansuy/adk-code"
  license "Apache-2.0"
  
  binary "adk-code"
  
  post_install do
    chmod 0755, staged_path/"adk-code"
  end
  
  zap trash: [
    "~/.adk-code",
    "~/.config/adk-code",
  ]
  
  test do
    system "#{staged_path}/adk-code", "--version"
  end
end
