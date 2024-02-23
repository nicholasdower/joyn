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

#script -q actual ./join > /dev/null
#printf "error: nothing to join\r\n" > expected
#test "no input"

printf "foo\n" | ./join -d , 2>&1 > actual
printf "foo\n" > expected
test "stdin: single line with newline"

printf "foo" | ./join -d , 2>&1 > actual
printf "foo" > expected
test "stdin: single line without newline"

printf "foo\nbar\n" | ./join -d , 2>&1 > actual
printf "foo,bar\n" > expected
test "stdin: muliline with newline"

printf "foo\nbar" | ./join -d , 2>&1 > actual
printf "foo,bar" > expected
test "stdin: muliline without newline"

printf "foo\n\nbar\n" | ./join -d , 2>&1 > actual
printf "foo,,bar\n" > expected
test "stdin: blank lines"

printf "foo\n\n" | ./join -d , 2>&1 > actual
printf "foo,\n" > expected
test "stdin: trailing blank lines"

printf "foo\n" > one
./join -d , one 2>&1 > actual
printf "foo\n" > expected
test "file: single line with newline"

printf "foo" > one
./join -d , one 2>&1 > actual
printf "foo" > expected
test "file: single line without newline"

printf "foo\nbar\n" > one
./join -d , one 2>&1 > actual
printf "foo,bar\n" > expected
test "file: multiline with newline"

printf "foo\nbar" > one
./join -d , one 2>&1 > actual
printf "foo,bar" > expected
test "file: multiline without newline"

printf "foo\n" > one
printf "bar\n" > two
./join -d , one two 2>&1 > actual
printf "foo,bar\n" > expected
test "files: with newline"

printf "foo" > one
printf "bar" > two
./join -d , one two 2>&1 > actual
printf "foo,bar" > expected
test "files: without newline"

printf "" > one
printf "" > two
printf "" > tre
./join -d , one two tre 2>&1 > actual
printf ",," > expected
test "files: all empty"

printf "foo" > one
printf "" > two
printf "bar" > tre
./join -d , one two tre 2>&1 > actual
printf "foo,,bar" > expected
test "files: some empty"

printf "foo\nbar\n" | ./join 2>&1 > actual
printf "foobar\n" > expected
test "delimiter: "

printf "foo\nbar\n" | ./join -d , 2>&1 > actual
printf "foo,bar\n" > expected
test "delimiter: ,"

printf "foo\nbar\n" | ./join -d ",\t" 2>&1 > actual
printf "foo,\tbar\n" > expected
test "delimiter: tab"

printf "foo\nbar\n" | ./join -d ",\n" 2>&1 > actual
printf "foo,\nbar\n" > expected
test "delimiter: newline"
