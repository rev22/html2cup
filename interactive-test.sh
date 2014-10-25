#!/bin/sh

println() {
    printf "%s\n" "$*"
}

warn() {
    println "$0: $*" >&2
}

die() {
    warn "$*"
    exit 1
}


git diff --quiet -- test-cases/ || die "There are unstaged changes in test-cases/; please stage or discard them before running $0 again!"
coffeemake --rebuild test-cases/*
git diff test-cases/

