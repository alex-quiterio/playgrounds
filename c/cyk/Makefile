CC ?= cc
CFLAGS ?= -std=c11 -Wall -Wextra -g -fsanitize=address,undefined
BUILD := build

.PHONY: all run test clean

all: $(BUILD)/cyk

$(BUILD)/cyk: CYK.c | $(BUILD)
	$(CC) $(CFLAGS) $< -o $@

$(BUILD):
	mkdir -p $@

run: $(BUILD)/cyk
	./$(BUILD)/cyk

test: $(BUILD)/cyk
	./tests/run.sh ./$(BUILD)/cyk

clean:
	rm -rf $(BUILD)
