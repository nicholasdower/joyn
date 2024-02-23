#!/usr/bin/env bash

if [[ -z "$RUNNER_TEMP" ]]; then
  dir="/tmp/join"
else
  dir="$RUNNER_TEMP/join"
fi

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

rm -rf "$dir"
mkdir -p "$dir"
cp "$binary" "$dir"
cd "$dir"

function test() {
  name="$1"
  if diff expected actual > /dev/null; then
    printf "\033[0;32m"
    echo "test passed: $name"
    printf "\033[0m"
  else
    printf "\033[0;31m"
    echo "test failed: $name"
    printf "\033[0m"
    diff expected actual
    exit 1
  fi
}

printf "foo\n" | ./join , 2>&1 > actual
printf "foo\n" > expected
test "single line with newline"

printf "foo" | ./join , 2>&1 > actual
printf "foo" > expected
test "single line without newline"

printf "foo\nbar\n" | ./join , 2>&1 > actual
printf "foo,bar\n" > expected
test "muliline with newline"

printf "foo\nbar" | ./join , 2>&1 > actual
printf "foo,bar" > expected
test "muliline without newline"

printf "foo\n\nbar\n" | ./join , 2>&1 > actual
printf "foo,,bar\n" > expected
test "blank lines"

printf "foo\n\n" | ./join , 2>&1 > actual
printf "foo,\n" > expected
test "trailing blank lines"

printf "foo\nbar\n" | ./join 2>&1 > actual
printf "foobar\n" > expected
test "delimiter: "

printf "foo\nbar\n" | ./join , 2>&1 > actual
printf "foo,bar\n" > expected
test "delimiter: ,"

printf "foo\nbar\n" | ./join ",\t" 2>&1 > actual
printf "foo,\tbar\n" > expected
test "delimiter: tab"

printf "foo\nbar\n" | ./join ",\n" 2>&1 > actual
printf "foo,\nbar\n" > expected
test "delimiter: newline"
