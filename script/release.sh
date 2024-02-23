#!/usr/bin/env bash

set -e
set -u
set -o pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <version>" >&2
  exit 1
fi

if [ -z "${HOMEBREW_PAT}" ]; then
  echo "HOMEBREW_PAT not set" >&2
  exit 1
fi

if [ -z "${GH_TOKEN}" ]; then
  echo "GH_TOKEN not set" >&2
  exit 1
fi

version="$1"

echo "Set version to $version"
./script/version.sh "$version"

echo "Create man page"
./script/manpage.sh "$version" "$(date '+%Y-%m-%d')"

x86_64_apple_darwin_file="join-$version-x86_64-apple-darwin.tar.gz"
aarch64_apple_darwin_file="join-$version-aarch64-apple-darwin.tar.gz"

echo "Create $x86_64_apple_darwin_file"
rm -rf bin
mkdir -p bin
mv join-x86_64-apple-darwin bin/join
rm -f "$x86_64_apple_darwin_file"
tar -czf "$x86_64_apple_darwin_file" ./man/ ./bin/

echo "Create $aarch64_apple_darwin_file"
rm -rf bin
mkdir -p bin
mv join-aarch64-apple-darwin bin/join
rm -f "$aarch64_apple_darwin_file"
tar -czf "$aarch64_apple_darwin_file" ./man/ ./bin/

echo "Create Homebrew formula"
./script/homebrew.sh "$version"

echo "Update CHANGELOG.md"
./script/changelog.sh "$version"

echo "Update README.md"
./script/readme.sh target/release

git config user.email "nicholasdower@gmail.com"
git config user.name "join-ci"

echo "Commit changes"
git add CHANGELOG.md
git add Cargo.lock
git add Cargo.toml
git add Formula/join.rb
git add README.md
git add man/join.1
echo -e "v$version Release\n\n$(cat .release-notes)" | git commit -F -

echo "Add tag v$version"
git tag "v$version"

mkdir -p tmp
cp .release-notes tmp/
echo "- No changes" > .release-notes

if ! `git diff --exit-code .release-notes > /dev/null 2>&1`; then
  echo "Reset .release-notes"
  git add .release-notes
  git commit -m 'Post release'
fi

echo "Push changes"
git push origin master
git push origin "v$version"

echo "Create release"
gh release create "v$version" \
  "$x86_64_apple_darwin_file" \
  "$aarch64_apple_darwin_file" \
  -R nicholasdower/join \
  --notes-file tmp/.release-notes

echo "Trigger Homebrew update"
GH_TOKEN=$HOMEBREW_PAT gh workflow run update.yml --ref master -R nicholasdower/homebrew-tap
