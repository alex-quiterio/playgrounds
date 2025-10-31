/* Day 7: No Space Left On Device */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_DEPTH 256
#define MAX_DIRS 4096

static long sizes[MAX_DIRS]; /* total size of every directory once it is closed */
static int ndirs = 0;

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }

    /* Sizes of the directories from / down to the current one. */
    long stack[MAX_DEPTH];
    int depth = 0;
    char line[256];
    while (fgets(line, sizeof line, in)) {
        if (strncmp(line, "$ cd ", 5) == 0) {
            const char *name = line + 5;
            if (strncmp(name, "..", 2) == 0) {
                /* Leaving a directory: it is complete, and counts towards its parent. */
                sizes[ndirs++] = stack[--depth];
                stack[depth - 1] += stack[depth];
            } else if (name[0] == '/') {
                while (depth > 1) {
                    sizes[ndirs++] = stack[--depth];
                    stack[depth - 1] += stack[depth];
                }
                if (depth == 0) {
                    stack[depth++] = 0;
                }
            } else {
                stack[depth++] = 0;
            }
        } else if (line[0] >= '0' && line[0] <= '9') {
            stack[depth - 1] += strtol(line, NULL, 10);
        }
    }
    fclose(in);
    while (depth > 1) {
        sizes[ndirs++] = stack[--depth];
        stack[depth - 1] += stack[depth];
    }
    long used = stack[0];
    sizes[ndirs++] = used;

    long small = 0;
    long needed = 30000000 - (70000000 - used);
    long smallest = used;
    for (int i = 0; i < ndirs; i++) {
        if (sizes[i] <= 100000) {
            small += sizes[i];
        }
        if (sizes[i] >= needed && sizes[i] < smallest) {
            smallest = sizes[i];
        }
    }
    printf("%ld\n%ld\n", small, smallest);
    return 0;
}
