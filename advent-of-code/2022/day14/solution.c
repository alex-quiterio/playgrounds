/* Day 14: Regolith Reservoir */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define W 1000
#define H 200

static char cave[H][W]; /* '#' rock, 'o' sand */
static int floor_y = 0;

/* Drops one unit of sand from (500, 0). Returns 0 once sand falls past the
 * lowest rock (part 1) or the source is blocked (part 2). */
static int drop(int with_floor) {
    int x = 500, y = 0;
    if (cave[0][500]) {
        return 0;
    }
    for (;;) {
        if (y + 1 == floor_y) {
            if (!with_floor) {
                return 0;
            }
            break; /* resting on the floor */
        }
        if (!cave[y + 1][x]) {
            y++;
        } else if (!cave[y + 1][x - 1]) {
            y++, x--;
        } else if (!cave[y + 1][x + 1]) {
            y++, x++;
        } else {
            break;
        }
    }
    cave[y][x] = 'o';
    return 1;
}

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    char line[4096];
    int lowest = 0;
    while (fgets(line, sizeof line, in)) {
        int px = -1, py = -1, x, y, n;
        for (char *p = line; sscanf(p, "%d,%d%n", &x, &y, &n) == 2;) {
            if (px >= 0) { /* draw the rock segment from the previous point */
                for (int i = abs(x - px), j = 0; j <= i; j++) {
                    cave[py][px + (x > px ? j : -j)] = '#';
                }
                for (int i = abs(y - py), j = 0; j <= i; j++) {
                    cave[py + (y > py ? j : -j)][x] = '#';
                }
            }
            px = x, py = y;
            if (y > lowest) {
                lowest = y;
            }
            p += n;
            char *arrow = strstr(p, "->");
            if (arrow == NULL) {
                break;
            }
            p = arrow + 2;
        }
    }
    fclose(in);

    /* The floor is two below the lowest rock; part 1 stops when sand reaches it. */
    floor_y = lowest + 2;
    int part1 = 0;
    while (drop(0)) {
        part1++;
    }
    int part2 = part1;
    while (drop(1)) {
        part2++;
    }
    printf("%d\n%d\n", part1, part2);
    return 0;
}
