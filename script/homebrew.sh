#!/usr/bin/env bash

set -e
set -u
set -o pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <version>" >&2
  exit 1
fi

version="$1"

x86_64_apple_darwin_file="join-$version-x86_64-apple-darwin.tar.gz"
aarch64_apple_darwin_file="join-$version-aarch64-apple-darwin.tar.gz"

if [ ! -f "$x86_64_apple_darwin_file" ]; then
  echo "error: $x86_64_apple_darwin_file not found" >&2
  exit 1
fi

if [ ! -f "$aarch64_apple_darwin_file" ]; then
  echo "error: $aarch64_apple_darwin_file not found" >&2
  exit 1
fi

x86_64_apple_darwin_url="https://github.com/nicholasdower/join/releases/download/v$version/$x86_64_apple_darwin_file"
x86_64_apple_darwin_sha=`shasum -a 256 "$x86_64_apple_darwin_file" | cut -d' ' -f1`

aarch64_apple_darwin_url="https://github.com/nicholasdower/join/releases/download/v$version/$aarch64_apple_darwin_file"
aarch64_apple_darwin_sha=`shasum -a 256 "$aarch64_apple_darwin_file" | cut -d' ' -f1`

cat << EOF > Formula/join.rb
class Join < Formula
  desc "Join lines"
  homepage "https://github.com/nicholasdower/join"
  license "MIT"
  version "$version"
  if Hardware::CPU.arm?
    url "$aarch64_apple_darwin_url"
    sha256 "$aarch64_apple_darwin_sha"
  elsif Hardware::CPU.intel?
    url "$x86_64_apple_darwin_url"
    sha256 "$x86_64_apple_darwin_sha"
  end

  def install
    bin.install "bin/join"
    man1.install "man/join.1"
  end

  test do
    assert_match "join", shell_output("#{bin}/join --version")
  end
end
EOF
