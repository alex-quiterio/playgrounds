/* Day 8: Treetop Tree House */
#include <stdio.h>
#include <string.h>

#define MAX 128

static char grid[MAX][MAX + 2];

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    int rows = 0, cols = 0;
    while (rows < MAX && fgets(grid[rows], sizeof grid[rows], in)) {
        int n = (int)strcspn(grid[rows], "\r\n");
        if (n > 0) {
            cols = n;
            rows++;
        }
    }
    fclose(in);

    static const int dr[] = {-1, 1, 0, 0}, dc[] = {0, 0, -1, 1};
    int visible = 0;
    long best = 0;
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            int outside = 0;
            long score = 1;
            for (int d = 0; d < 4; d++) {
                int rr = r + dr[d], cc = c + dc[d], trees = 0, blocked = 0;
                while (rr >= 0 && rr < rows && cc >= 0 && cc < cols) {
                    trees++;
                    if (grid[rr][cc] >= grid[r][c]) {
                        blocked = 1;
                        break;
                    }
                    rr += dr[d];
                    cc += dc[d];
                }
                outside |= !blocked;
                score *= trees;
            }
            visible += outside;
            if (score > best) {
                best = score;
            }
        }
    }
    printf("%d\n%ld\n", visible, best);
    return 0;
}
