CC ?= cc
CFLAGS ?= -std=c11 -Wall -Wextra -O2 -g -fsanitize=address,undefined
BUILD := build

# Each puzzle lives in <name>/<name>.c and is checked against <name>/example.in and .out.
PUZZLES := nqueens sudoku

# `make run PUZZLE=sudoku` solves that puzzle's example.
PUZZLE ?= $(firstword $(PUZZLES))

.PHONY: all run test clean

all: $(addprefix $(BUILD)/,$(PUZZLES))

.SECONDEXPANSION:
$(addprefix $(BUILD)/,$(PUZZLES)): $(BUILD)/%: $$*/$$*.c dancing_links.c dancing_links.h puzzle.h | $(BUILD)
	$(CC) $(CFLAGS) $*/$*.c dancing_links.c -o $@

$(BUILD)/test_dancing_links: tests/test_dancing_links.c dancing_links.c dancing_links.h | $(BUILD)
	$(CC) $(CFLAGS) tests/test_dancing_links.c dancing_links.c -o $@

$(BUILD):
	mkdir -p $@

run: $(BUILD)/$(PUZZLE)
	./$(BUILD)/$(PUZZLE) $$(cat $(PUZZLE)/example.args 2>/dev/null) < $(PUZZLE)/example.in

test: $(BUILD)/test_dancing_links all
	./$(BUILD)/test_dancing_links
	./tests/run.sh $(BUILD) $(PUZZLES)

clean:
	rm -rf $(BUILD)
