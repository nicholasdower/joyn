class Join < Formula
  desc "Join lines"
  homepage "https://github.com/nicholasdower/join"
  license "MIT"
  version "1.1.0"
  if Hardware::CPU.arm?
    url "https://github.com/nicholasdower/join/releases/download/v1.1.0/join-1.1.0-aarch64-apple-darwin.tar.gz"
    sha256 "2872a3708157fc60bb6f2765626abe6d6f1ffeede242e5d73d3c3478a1bdc3fc"
  elsif Hardware::CPU.intel?
    url "https://github.com/nicholasdower/join/releases/download/v1.1.0/join-1.1.0-x86_64-apple-darwin.tar.gz"
    sha256 "b1d34c12612bbced58ed515891d44025402776f45d03a525b4791f591cae1293"
  end

  def install
    bin.install "bin/join"
    man1.install "man/join.1"
  end

  test do
    assert_match "join", shell_output("#{bin}/join --version")
  end
end
