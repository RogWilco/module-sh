#!/usr/bin/env bash

PWD="$(dirname "${BASH_SOURCE[0]}")"

source "$PWD/../test/test.sh"

test::suite "module: <caller> is executed directly"

test "routes to the expected mock function" \
	--command "$PWD/../test/mock_caller.sh foo" \
	--expect-stdout "mock_caller::foo"

test "routes to the expected mock function, with arguments" \
	--command "$PWD/../test/mock_caller.sh foo bar baz" \
	--expect-stdout "mock_caller::foo bar baz"

test "maps to the expected mock main function" \
	--command "$PWD/../test/mock_caller.sh" \
	--expect-stdout "mock_caller"

test "maps to the expected mock main function, with arguments" \
	--command "$PWD/../test/mock_caller.sh baz bar foo" \
	--expect-stdout "mock_caller baz bar foo"

test "accepts any output by default" \
	--command "$PWD/../test/mock_caller.sh foo bar baz" \
	--expect-stdout "*"

test::suite "module: module is executed directly"

test "does not perform any routing" \
	--command "$PWD/module.sh" \
	--expect-stdout "" \
	--expect-exit 0
