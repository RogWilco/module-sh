#!/usr/bin/env bash

source ../test/test.sh

test::suite "module: <caller> is executed directly"

test "routes to the expected mock function" \
	--command "../test/mock_caller.sh foo" \
	--expect-stdout "mock_caller::foo"

test "routes to the expected mock function, with arguments" \
	--command "../test/mock_caller.sh foo bar baz" \
	--expect-stdout "mock_caller::foo bar baz"

test "maps to the expected mock main function" \
	--command "../test/mock_caller.sh" \
	--expect-stdout "mock_caller"

test "maps to the expected mock main function, with arguments" \
	--command "../test/mock_caller.sh baz bar foo" \
	--expect-stdout "mock_caller baz bar foo"

test "accepts any output by default" \
	--command "../test/mock_caller.sh foo bar baz"

test::suite "module: module is executed directly"

test "does not perform any routing" \
	--command "./module.sh" \
	--expect-stdout "" \
	--expect-exit 0
