/* Day 24: Blizzard Basin */
#include <stdio.h>
#include <string.h>

#define MAX 160

static char map[MAX][MAX];
static int rows, cols; /* the full map, walls included */
static int h, w;       /* the inner area the blizzards loop around */
static unsigned char now[MAX][MAX], next[MAX][MAX];

static int mod(int a, int m) { return ((a % m) + m) % m; }

/* Is cell (r, c) free of blizzards at minute t? Each blizzard moves in a
 * straight line and wraps, so look back along its row or column. */
static int clear(int r, int c, int t) {
    if (r < 0 || r >= rows || map[r][c] == '#') return 0;
    if (r == 0 || r == rows - 1) return 1; /* the start and goal gaps */
    int ir = r - 1, ic = c - 1;
    if (map[1 + ir][1 + mod(ic - t, w)] == '>') return 0;
    if (map[1 + ir][1 + mod(ic + t, w)] == '<') return 0;
    if (map[1 + mod(ir - t, h)][1 + ic] == 'v') return 0;
    if (map[1 + mod(ir + t, h)][1 + ic] == '^') return 0;
    return 1;
}

/* Breadth-first over minutes: every cell we could be standing in at minute t. */
static int cross(int sr, int sc, int gr, int gc, int t) {
    static const int dr[5] = {0, 1, -1, 0, 0}, dc[5] = {0, 0, 0, 1, -1};
    memset(now, 0, sizeof now);
    now[sr][sc] = 1;
    for (;; t++) {
        memset(next, 0, sizeof next);
        for (int r = 0; r < rows; r++)
            for (int c = 0; c < cols; c++) {
                if (!now[r][c]) continue;
                for (int k = 0; k < 5; k++) {
                    int nr = r + dr[k], nc = c + dc[k];
                    if (nc < 0 || nc >= cols || !clear(nr, nc, t + 1)) continue;
                    if (nr == gr && nc == gc) return t + 1;
                    next[nr][nc] = 1;
                }
            }
        memcpy(now, next, sizeof now);
    }
}

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (!in) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    while (rows < MAX && fgets(map[rows], MAX, in)) {
        map[rows][strcspn(map[rows], "\n")] = 0;
        if (map[rows][0]) rows++;
    }
    fclose(in);
    cols = (int)strlen(map[0]);
    h = rows - 2;
    w = cols - 2;
    int start = (int)(strchr(map[0], '.') - map[0]);
    int goal = (int)(strchr(map[rows - 1], '.') - map[rows - 1]);

    int there = cross(0, start, rows - 1, goal, 0);
    printf("%d\n", there);
    int back = cross(rows - 1, goal, 0, start, there);
    printf("%d\n", cross(0, start, rows - 1, goal, back));
    return 0;
}
