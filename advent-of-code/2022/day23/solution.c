/* Day 23: Unstable Diffusion */
#include <stdio.h>
#include <string.h>

#define SIZE 512   /* the grid the elves spread over */
#define OFFSET 200 /* where the input's top-left corner goes */
#define MAX_ELVES 4096

static unsigned char grid[SIZE][SIZE];
static unsigned char claims[SIZE][SIZE];
static int ex[MAX_ELVES], ey[MAX_ELVES], tx[MAX_ELVES], ty[MAX_ELVES];
static int elves;

/* The three cells to check for each direction, in the order N, S, W, E. */
static const int look[4][3][2] = {
    {{-1, -1}, {0, -1}, {1, -1}},
    {{-1, 1}, {0, 1}, {1, 1}},
    {{-1, -1}, {-1, 0}, {-1, 1}},
    {{1, -1}, {1, 0}, {1, 1}},
};
static const int step[4][2] = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}};

/* Plays one round starting with direction `first`; returns how many elves moved. */
static int round_of(int first) {
    for (int e = 0; e < elves; e++) {
        int x = ex[e], y = ey[e], alone = 1;
        tx[e] = x;
        ty[e] = y;
        for (int dy = -1; dy <= 1; dy++)
            for (int dx = -1; dx <= 1; dx++)
                if ((dx || dy) && grid[y + dy][x + dx]) alone = 0;
        if (alone) continue;
        for (int k = 0; k < 4; k++) {
            int d = (first + k) % 4, free = 1;
            for (int c = 0; c < 3; c++)
                if (grid[y + look[d][c][1]][x + look[d][c][0]]) free = 0;
            if (free) {
                tx[e] = x + step[d][0];
                ty[e] = y + step[d][1];
                if (claims[ty[e]][tx[e]] < 2) claims[ty[e]][tx[e]]++;
                break;
            }
        }
    }
    int moved = 0;
    for (int e = 0; e < elves; e++) {
        if (tx[e] == ex[e] && ty[e] == ey[e]) continue;
        if (claims[ty[e]][tx[e]] == 1) {
            grid[ey[e]][ex[e]] = 0;
            grid[ty[e]][tx[e]] = 1;
            ex[e] = tx[e];
            ey[e] = ty[e];
            moved++;
        }
    }
    for (int e = 0; e < elves; e++) claims[ty[e]][tx[e]] = 0;
    return moved;
}

static int empty_ground(void) {
    int minx = SIZE, maxx = 0, miny = SIZE, maxy = 0;
    for (int e = 0; e < elves; e++) {
        if (ex[e] < minx) minx = ex[e];
        if (ex[e] > maxx) maxx = ex[e];
        if (ey[e] < miny) miny = ey[e];
        if (ey[e] > maxy) maxy = ey[e];
    }
    return (maxx - minx + 1) * (maxy - miny + 1) - elves;
}

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (!in) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    char line[256];
    for (int y = 0; fgets(line, sizeof line, in); y++)
        for (int x = 0; line[x] && line[x] != '\n'; x++)
            if (line[x] == '#') {
                ex[elves] = x + OFFSET;
                ey[elves] = y + OFFSET;
                grid[y + OFFSET][x + OFFSET] = 1;
                elves++;
            }
    fclose(in);

    int round = 0;
    while (round < 10) round_of(round++ % 4);
    printf("%d\n", empty_ground());
    while (round_of(round % 4)) round++;
    printf("%d\n", round + 1);
    return 0;
}
