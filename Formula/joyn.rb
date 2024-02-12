class Joyn < Formula
  desc "Join lines"
  homepage "https://github.com/nicholasdower/joyn"
  url "https://github.com/nicholasdower/joyn/releases/download/v1.0.0/release.tar.gz"
  sha256 "TBD"
  license "MIT"

  def install
    bin.install "bin/joyn"
    man1.install "man/joyn.1"
  end

  test do
    assert_match "joyn", shell_output("#{bin}/joyn --version")
  end
end
