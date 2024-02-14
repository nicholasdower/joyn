#!/usr/bin/env bash

set -e
set -u
set -o pipefail

if [ $# -gt 1 ]; then
  echo "usage: $0 [<bin-path>]" >&2
  exit 1
fi

if [ $# -eq 1 ]; then
  binary="$1/joyn"
else
  binary="./target/debug/joyn"
fi

if [ ! -f "$binary" ]; then
  echo "error: $binary does not exist" >&2
  exit 1
fi

cat << EOF > README.md
# joyn

## Install

\`\`\`shell
brew install nicholasdower/tap/joyn
\`\`\`

## Uninstall

\`\`\`shell
brew uninstall joyn
\`\`\`

## Help

\`\`\`
$($binary -h)
\`\`\`
EOF
