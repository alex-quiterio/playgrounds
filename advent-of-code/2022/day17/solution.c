/* Day 17: Pyroclastic Flow */
#include <stdio.h>
#include <string.h>

#define MAX_HEIGHT 100000

/* Each rock is a list of rows (bottom first), as bits of a 7-wide row; bit 6 is the left wall. */
static const unsigned char rocks[5][4] = {
    {0x1E},                   /* ####       */
    {0x08, 0x1C, 0x08},       /* plus       */
    {0x1C, 0x04, 0x04},       /* reversed L */
    {0x10, 0x10, 0x10, 0x10}, /* I          */
    {0x18, 0x18},             /* square     */
};
static const int rock_rows[5] = {1, 3, 3, 4, 2};

static unsigned char chamber[MAX_HEIGHT];
static char jets[16384];
static int njets, height, jet;

static int fits(const unsigned char *shape, int rows, int y) {
    for (int r = 0; r < rows; r++) {
        if (y + r < 0 || (chamber[y + r] & shape[r])) {
            return 0;
        }
    }
    return 1;
}

/* Drops rock number n. */
static void drop(long n) {
    int kind = (int)(n % 5), rows = rock_rows[kind];
    unsigned char shape[4];
    memcpy(shape, rocks[kind], sizeof shape);
    int y = height + 3;
    for (;;) {
        /* Pushed by a jet, unless that hits a wall or another rock. */
        unsigned char pushed[4];
        int ok = 1;
        for (int r = 0; r < rows; r++) {
            if (jets[jet] == '<') {
                ok &= !(shape[r] & 0x40);
                pushed[r] = (unsigned char)(shape[r] << 1);
            } else {
                ok &= !(shape[r] & 0x01);
                pushed[r] = shape[r] >> 1;
            }
        }
        jet = (jet + 1) % njets;
        if (ok && fits(pushed, rows, y)) {
            memcpy(shape, pushed, sizeof shape);
        }
        if (!fits(shape, rows, y - 1)) {
            break;
        }
        y--;
    }
    for (int r = 0; r < rows; r++) {
        chamber[y + r] |= shape[r];
    }
    if (y + rows > height) {
        height = y + rows;
    }
}

/* Height after `total` rocks, skipping ahead once the pattern repeats. */
static long tower(long total) {
    memset(chamber, 0, sizeof chamber);
    height = jet = 0;
    /* Remember (rock, jet, top rows) -> (rock count, height) to spot the cycle. */
    static long seen_rock[5][16384], seen_height[5][16384];
    static unsigned long long seen_top[5][16384];
    memset(seen_rock, -1, sizeof seen_rock);
    long skipped = 0;
    for (long n = 0; n < total; n++) {
        if (!skipped && height >= 8) {
            unsigned long long top = 0;
            for (int r = 1; r <= 8; r++) {
                top = top << 8 | chamber[height - r];
            }
            int kind = (int)(n % 5);
            if (seen_rock[kind][jet] >= 0 && seen_top[kind][jet] == top) {
                long period = n - seen_rock[kind][jet];
                long gain = height - seen_height[kind][jet];
                long cycles = (total - n) / period;
                skipped = cycles * gain;
                n += cycles * period;
                if (n >= total) {
                    break;
                }
            } else {
                seen_rock[kind][jet] = n;
                seen_height[kind][jet] = height;
                seen_top[kind][jet] = top;
            }
        }
        drop(n);
    }
    return height + skipped;
}

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL || !fgets(jets, sizeof jets, in)) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    fclose(in);
    njets = (int)strcspn(jets, "\r\n");
    printf("%ld\n%ld\n", tower(2022), tower(1000000000000L));
    return 0;
}
