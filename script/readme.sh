#!/usr/bin/env bash

set -e
set -u
set -o pipefail

cat << EOF > README.md
# joyn

\`\`\`
$(./target/release/joyn -h)
\`\`\`
EOF
