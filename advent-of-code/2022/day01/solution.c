/* Day 1: Calorie Counting */
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }

    long top[3] = {0, 0, 0}; /* the three largest totals, largest first */
    long elf = 0;
    char line[64];
    int more = 1;
    while (more) {
        more = fgets(line, sizeof line, in) != NULL;
        if (more && line[0] != '\n') {
            elf += strtol(line, NULL, 10);
            continue;
        }
        /* A blank line (or the end of the file) closes this elf's list. */
        for (int i = 0; i < 3; i++) {
            if (elf > top[i]) {
                long swap = top[i];
                top[i] = elf;
                elf = swap;
            }
        }
        elf = 0;
    }
    fclose(in);

    printf("%ld\n%ld\n", top[0], top[0] + top[1] + top[2]);
    return 0;
}
