class CurlImpersonate < Formula
  desc "Curl build that impersonates browser TLS/HTTP fingerprints"
  homepage "https://github.com/lexiforest/curl-impersonate"
  license "MIT"

  depends_on "ca-certificates"

  on_macos do
    on_arm do
      url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.3.2/curl-impersonate-v2.3.2.arm64-macos.tar.gz"
      sha256 "638ed43cc93cb5da91f794ff23fce1735fec3dc5c09ee87cc499d802c25d2d35"
    end
    on_intel do
      url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.3.2/curl-impersonate-v2.3.2.x86_64-macos.tar.gz"
      sha256 "4e9fe855a34d011de88bf216c196f6957624526678b99b4f2135acc9ffa8c156"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.3.2/curl-impersonate-v2.3.2.aarch64-linux-gnu.tar.gz"
      sha256 "35a351db883f5ce82945bd8280c727b08e27aa48594d4eb9e091d8c80e936d52"
    end
    on_intel do
      url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.3.2/curl-impersonate-v2.3.2.x86_64-linux-gnu.tar.gz"
      sha256 "bc9bd2522fe1850dd54c0fff189c8dd606df3f222ab2a905f2dd255123c3f495"
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
