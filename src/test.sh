#!/usr/bin/env bash

test::foo() {
    echo "test::foo $*"
}

test() {
    echo "test $*"
}

source "$(dirname "${BASH_SOURCE[0]}")/module.sh"
