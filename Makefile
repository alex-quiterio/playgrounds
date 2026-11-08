# Run every playground's tests with `make test`, or one language with `make test-<lang>`.

C_EXERCISES := c/cyk c/dancing-links c/doubled-linked-lists c/rod
RUBY_EXERCISES := ruby/backtracking-algos ruby/generational-algos

.PHONY: test test-c test-go test-ruby test-prolog test-lisp test-aoc format clean

test: test-c test-go test-ruby test-prolog test-lisp test-aoc

test-c:
	@for dir in $(C_EXERCISES); do echo "== $$dir"; $(MAKE) -s -C $$dir test || exit 1; done

test-go:
	cd go && go vet ./... && go test ./...

test-ruby:
	@for dir in $(RUBY_EXERCISES); do echo "== $$dir"; (cd $$dir && rake test) || exit 1; done

test-prolog:
	swipl -g run_tests -t halt prolog/tests/oscars_test.pl

test-lisp:
	sbcl --script lisp/y-game/tests/run-all.lisp

test-aoc:
	advent-of-code/bin/check

format:
	clang-format -i $$(find c -name '*.[ch]')
	gofmt -w go

clean:
	@for dir in $(C_EXERCISES); do $(MAKE) -s -C $$dir clean; done
