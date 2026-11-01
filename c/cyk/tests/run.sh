#!/bin/sh
# Feeds every tests/cases/*.in to the CYK binary and diffs against the matching .out file.
set -u
bin="$1"
dir="$(cd "$(dirname "$0")" && pwd)/cases"
pass=0
fail=0
for input in "$dir"/*.in; do
    name="$(basename "$input" .in)"
    expected="$dir/$name.out"
    if actual="$("$bin" < "$input")" && [ "$actual" = "$(cat "$expected")" ]; then
        pass=$((pass + 1))
        echo "ok   $name"
    else
        fail=$((fail + 1))
        echo "FAIL $name"
        echo "$actual" | diff "$expected" - | sed 's/^/     /'
    fi
done
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
