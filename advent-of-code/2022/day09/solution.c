/* Day 9: Rope Bridge */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SPAN 4096 /* the tail stays within +/- SPAN/2 of the start */

static int sign(int v) { return (v > 0) - (v < 0); }

/* Positions the tail of a `knots`-knot rope visits. */
static long tail_visits(const char *dirs, const int *counts, int nmoves, int knots) {
    uint8_t *visited = calloc((size_t)SPAN * SPAN / 8, 1);
    int x[10] = {0}, y[10] = {0};
    long total = 0;
    for (int m = 0; m < nmoves; m++) {
        for (int s = 0; s < counts[m]; s++) {
            x[0] += dirs[m] == 'R' ? 1 : dirs[m] == 'L' ? -1 : 0;
            y[0] += dirs[m] == 'U' ? 1 : dirs[m] == 'D' ? -1 : 0;
            for (int k = 1; k < knots; k++) {
                int dx = x[k - 1] - x[k], dy = y[k - 1] - y[k];
                /* A knot only moves once it is no longer touching the one ahead. */
                if (abs(dx) > 1 || abs(dy) > 1) {
                    x[k] += sign(dx);
                    y[k] += sign(dy);
                }
            }
            size_t cell = (size_t)(y[knots - 1] + SPAN / 2) * SPAN + (size_t)(x[knots - 1] + SPAN / 2);
            if (!(visited[cell / 8] & (1 << (cell % 8)))) {
                visited[cell / 8] |= (uint8_t)(1 << (cell % 8));
                total++;
            }
        }
    }
    free(visited);
    return total;
}

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    static char dirs[8192];
    static int counts[8192];
    int n = 0;
    while (n < 8192 && fscanf(in, " %c %d", &dirs[n], &counts[n]) == 2) {
        n++;
    }
    fclose(in);
    printf("%ld\n%ld\n", tail_visits(dirs, counts, n, 2), tail_visits(dirs, counts, n, 10));
    return 0;
}
