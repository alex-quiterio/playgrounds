CC ?= cc
CFLAGS ?= -std=c11 -Wall -Wextra -g -fsanitize=address,undefined
BUILD := build

.PHONY: all run test clean

all: $(BUILD)/rod

$(BUILD)/rod: rod.c | $(BUILD)
	$(CC) $(CFLAGS) $< -o $@

$(BUILD)/test_rod: tests/test_rod.c rod.c | $(BUILD)
	$(CC) $(CFLAGS) $< -o $@

$(BUILD):
	mkdir -p $@

run: $(BUILD)/rod
	./$(BUILD)/rod

test: $(BUILD)/test_rod
	./$(BUILD)/test_rod

clean:
	rm -rf $(BUILD)
