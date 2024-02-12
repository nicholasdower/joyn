#!/usr/bin/env bash

set -e
set -u
set -o pipefail

if [ $# -ne 2 ]; then
  echo "usage: $0 <version> <file>" >&2
  exit 1
fi

version="$1"
file="$2"

url="https://github.com/nicholasdower/joyn/releases/download/v$version/$file"
sha=`shasum -a 256 "$file" | cut -d' ' -f1`
cat << EOF > Formula/joyn.rb
class Joyn < Formula
  desc "Join lines"
  homepage "https://github.com/nicholasdower/joyn"
  url "$url"
  sha256 "$sha"
  license "MIT"

  def install
    bin.install "bin/joyn"
    man1.install "man/joyn.1"
  end

  test do
    assert_match "joyn", shell_output("#{bin}/joyn --version")
  end
end
EOF
