#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../src/module.sh"

mock_caller::foo() {
    echo "mock_caller::foo $*"
}

mock_caller() {
    echo "mock_caller $*"
}
