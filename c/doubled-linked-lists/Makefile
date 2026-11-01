CC ?= cc
CFLAGS ?= -std=c11 -Wall -Wextra -g -fsanitize=address,undefined
BUILD := build

.PHONY: all run test clean

all: $(BUILD)/TestList

$(BUILD)/TestList: main.c List.c List.h | $(BUILD)
	$(CC) $(CFLAGS) main.c List.c -o $@

$(BUILD)/test_list: tests/test_list.c List.c List.h | $(BUILD)
	$(CC) $(CFLAGS) -D_POSIX_C_SOURCE=200809L tests/test_list.c List.c -o $@

$(BUILD):
	mkdir -p $@

run: $(BUILD)/TestList
	./$(BUILD)/TestList

test: $(BUILD)/test_list
	./$(BUILD)/test_list

clean:
	rm -rf $(BUILD)
