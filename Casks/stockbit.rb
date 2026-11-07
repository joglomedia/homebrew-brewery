cask "stockbit" do
  version "2.8.1"
  sha256 "b28479c2df8ec28203d4348b7f2a3f29a545ce5c88dd6b3bcc8df10010bcc4db"

  url "https://sda-release-v2.stockbit.com/release/#{version}/macos/Stockbit.dmg",
      user_agent: :fake
  name "Stockbit"
  desc "Aplikasi untuk diskusi, analisis, dan investasi saham"
  homepage "https://stockbit.com/"

  livecheck do
    url :url
    strategy :extract_plist
  end

  auto_updates true
  depends_on :macos

  app "Stockbit.app"

  zap trash: [
    "~/Library/Application Support/Stockbit",
    "~/Library/Saved Application State/com.stockbit.desktop.savedState",
  ]
end
