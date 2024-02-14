#!/usr/bin/env bash

if [[ -z "$RUNNER_TEMP" ]]; then
  dir="/tmp/joyn"
else
  dir="$RUNNER_TEMP/joyn"
fi

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

#script -q actual ./joyn > /dev/null
#printf "error: nothing to join\r\n" > expected
#test "no input"

printf "foo\n" | ./joyn -d , 2>&1 > actual
printf "foo\n" > expected
test "stdin: single line with newline"

printf "foo" | ./joyn -d , 2>&1 > actual
printf "foo" > expected
test "stdin: single line without newline"

printf "foo\nbar\n" | ./joyn -d , 2>&1 > actual
printf "foo,bar\n" > expected
test "stdin: muliline with newline"

printf "foo\nbar" | ./joyn -d , 2>&1 > actual
printf "foo,bar" > expected
test "stdin: muliline without newline"

printf "foo\n\nbar\n" | ./joyn -d , 2>&1 > actual
printf "foo,,bar\n" > expected
test "stdin: blank lines"

printf "foo\n\n" | ./joyn -d , 2>&1 > actual
printf "foo,\n" > expected
test "stdin: trailing blank lines"

printf "foo\n" > one
./joyn -d , one 2>&1 > actual
printf "foo\n" > expected
test "file: single line with newline"

printf "foo" > one
./joyn -d , one 2>&1 > actual
printf "foo" > expected
test "file: single line without newline"

printf "foo\nbar\n" > one
./joyn -d , one 2>&1 > actual
printf "foo,bar\n" > expected
test "file: multiline with newline"

printf "foo\nbar" > one
./joyn -d , one 2>&1 > actual
printf "foo,bar" > expected
test "file: multiline without newline"

printf "foo\n" > one
printf "bar\n" > two
./joyn -d , one two 2>&1 > actual
printf "foo,bar\n" > expected
test "files: with newline"

printf "foo" > one
printf "bar" > two
./joyn -d , one two 2>&1 > actual
printf "foo,bar" > expected
test "files: without newline"

printf "" > one
printf "" > two
printf "" > tre
./joyn -d , one two tre 2>&1 > actual
printf ",," > expected
test "files: all empty"

printf "foo" > one
printf "" > two
printf "bar" > tre
./joyn -d , one two tre 2>&1 > actual
printf "foo,,bar" > expected
test "files: some empty"

printf "foo\nbar\n" | ./joyn 2>&1 > actual
printf "foobar\n" > expected
test "delimiter: "

printf "foo\nbar\n" | ./joyn -d , 2>&1 > actual
printf "foo,bar\n" > expected
test "delimiter: ,"

printf "foo\nbar\n" | ./joyn -d ",\t" 2>&1 > actual
printf "foo,\tbar\n" > expected
test "delimiter: tab"

printf "foo\nbar\n" | ./joyn -d ",\n" 2>&1 > actual
printf "foo,\nbar\n" > expected
test "delimiter: newline"
