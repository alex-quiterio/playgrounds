#!/bin/sh
# Runs each puzzle on <puzzle>/example.in and diffs against <puzzle>/example.out.
# If <puzzle>/example.args exists, its words are passed as command-line arguments.
set -u
cd "$(dirname "$0")/.."
build="$1"
shift
pass=0
fail=0
for puzzle in "$@"; do
    args=""
    [ -f "$puzzle/example.args" ] && args="$(cat "$puzzle/example.args")"
    # shellcheck disable=SC2086 # args is a list of words on purpose
    if actual="$("$build/$puzzle" $args < "$puzzle/example.in")" &&
        [ "$actual" = "$(cat "$puzzle/example.out")" ]; then
        pass=$((pass + 1))
        echo "ok   $puzzle"
    else
        fail=$((fail + 1))
        echo "FAIL $puzzle"
        echo "$actual" | diff "$puzzle/example.out" - | sed 's/^/     /'
    fi
done
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
