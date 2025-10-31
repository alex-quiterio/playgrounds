/* Day 15: Beacon Exclusion Zone */
#include <stdio.h>
#include <stdlib.h>

#define MAX 64

static long sx[MAX], sy[MAX], bx[MAX], by[MAX], radius[MAX];
static int n = 0;

typedef struct {
    long from, to;
} span;

static int by_start(const void *a, const void *b) {
    long d = ((const span *)a)->from - ((const span *)b)->from;
    return (d > 0) - (d < 0);
}

/* The x ranges row y is covered by, merged and sorted. Returns the count. */
static int covered(long y, span *out) {
    span spans[MAX];
    int count = 0;
    for (int i = 0; i < n; i++) {
        long reach = radius[i] - labs(sy[i] - y);
        if (reach >= 0) {
            spans[count++] = (span){sx[i] - reach, sx[i] + reach};
        }
    }
    qsort(spans, (size_t)count, sizeof spans[0], by_start);
    int merged = 0;
    for (int i = 0; i < count; i++) {
        if (merged && spans[i].from <= out[merged - 1].to + 1) {
            if (spans[i].to > out[merged - 1].to) {
                out[merged - 1].to = spans[i].to;
            }
        } else {
            out[merged++] = spans[i];
        }
    }
    return merged;
}

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    long biggest = 0;
    while (n < MAX && fscanf(in, " Sensor at x=%ld, y=%ld: closest beacon is at x=%ld, y=%ld",
                             &sx[n], &sy[n], &bx[n], &by[n]) == 4) {
        radius[n] = labs(sx[n] - bx[n]) + labs(sy[n] - by[n]);
        if (sy[n] > biggest) {
            biggest = sy[n];
        }
        n++;
    }
    fclose(in);

    /* The example checks row 10 in a 0..20 box; the real puzzle row 2000000 in 0..4000000. */
    long row = biggest < 100 ? 10 : 2000000;
    long box = biggest < 100 ? 20 : 4000000;

    span spans[MAX];
    int count = covered(row, spans);
    long part1 = 0;
    for (int i = 0; i < count; i++) {
        part1 += spans[i].to - spans[i].from + 1;
    }
    /* Positions holding a known beacon can hold a beacon. */
    for (int i = 0; i < n; i++) {
        int duplicate = 0;
        for (int j = 0; j < i; j++) {
            duplicate |= bx[j] == bx[i] && by[j] == by[i];
        }
        if (!duplicate && by[i] == row) {
            part1--;
        }
    }

    /* The distress beacon is the one uncovered position in the box. */
    long part2 = -1;
    for (long y = 0; y <= box && part2 < 0; y++) {
        count = covered(y, spans);
        long x = 0;
        for (int i = 0; i < count && x <= box; i++) {
            if (spans[i].from > x) {
                break;
            }
            if (spans[i].to >= x) {
                x = spans[i].to + 1;
            }
        }
        if (x <= box) {
            part2 = x * 4000000 + y;
        }
    }
    printf("%ld\n%ld\n", part1, part2);
    return 0;
}
