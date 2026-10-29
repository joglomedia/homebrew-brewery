class CurlImpersonate < Formula
  desc "Curl build that impersonates browser TLS/HTTP fingerprints"
  homepage "https://github.com/lexiforest/curl-impersonate"
  version "2.3.1"
  license "MIT"

  depends_on "ca-certificates"

  on_macos do
    on_arm do
      url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.3.1/curl-impersonate-v2.3.1.arm64-macos.tar.gz"
      sha256 "0c7224fe24f576c7617ec177630ccfd09adf0278a22b21f0ff07d48db77d9b58"
    end
    on_intel do
      url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.3.1/curl-impersonate-v2.3.1.x86_64-macos.tar.gz"
      sha256 "3a13ed40f7fb65b5d40aa037102a565fc0f38d32277d602e8f3d1a10774423f6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.3.1/curl-impersonate-v2.3.1.aarch64-linux-gnu.tar.gz"
      sha256 "9a8009cc87d950374a85645b771e422e855fc070f3ab099ba7ab944755cd54c3"
    end
    on_intel do
      url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.3.1/curl-impersonate-v2.3.1.x86_64-linux-gnu.tar.gz"
      sha256 "0d8551cc1620be3c40c6f42d0b46c7077e0fe2a1a28a69d659e49e4f412cd0a0"
    end
  end

  def install
    bin.install Dir["curl*"]
  end

  test do
    version = shell_output("#{bin}/curl-impersonate --version")

    assert_match "curl", version
    assert_match "BoringSSL", version
    assert_match "brotli", version
    assert_match "nghttp2", version
  end
end
