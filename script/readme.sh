#!/usr/bin/env bash

set -e
set -u
set -o pipefail

if [ $# -gt 1 ]; then
  echo "usage: $0 [<bin-path>]" >&2
  exit 1
fi

if [ $# -eq 1 ]; then
  binary="$1/join"
else
  binary="./target/debug/join"
fi

if [ ! -f "$binary" ]; then
  echo "error: $binary does not exist" >&2
  exit 1
fi

cat << EOF > README.md
# join

## Install

\`\`\`shell
brew install nicholasdower/tap/join
\`\`\`

## Uninstall

\`\`\`shell
brew uninstall join
\`\`\`

## Help

\`\`\`
$($binary -h)
\`\`\`
EOF
