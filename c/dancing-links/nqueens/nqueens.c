/*
 * nqueens.c: count (and optionally list) the ways to place N queens on an NxN
 * board so that no two attack each other.
 *
 * Author: Alex Quiterio
 *
 * Input: N, then T. T = 0 prints only the count; otherwise every solution is
 * listed as "row column" pairs.
 */

#include "../puzzle.h"

/*
 * A queen on (i, j) is row i*N+j of the matrix. Each board row and column needs
 * exactly one queen: 2N primary columns. Each of the 4N-2 diagonals can hold at
 * most one: secondary columns.
 */
static char *build_matrix(int n, int *rows, int *primary, int *secondary) {
    *rows = n * n;
    *primary = 2 * n;
    *secondary = 4 * n - 2;
    int columns = *primary + *secondary;
    char *matrix = allocate((size_t)*rows * columns, 1);
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            char *row = matrix + (size_t)(i * n + j) * columns;
            row[i] = 1;                 /* board row i */
            row[n + j] = 1;             /* board column j */
            row[2 * n + i + j] = 1;     /* diagonal going up */
            row[5 * n - 2 + i - j] = 1; /* diagonal going down */
        }
    }
    return matrix;
}

typedef struct {
    int n;
    long printed;
} board;

static bool print_solution(const int *rows, int count, void *context) {
    board *queens = context;
    printf("%ld:\n", queens->printed++);
    for (int i = 0; i < count; i++)
        printf("%d %d\n", rows[i] / queens->n, rows[i] % queens->n);
    return true;
}

int main(void) {
    int n, list;
    if (scanf("%d%d", &n, &list) != 2 || n < 1)
        fail("Invalid board size");

    int rows, primary, secondary;
    char *matrix = build_matrix(n, &rows, &primary, &secondary);
    dancing_links *links = dancing_links_new(rows, primary, secondary, matrix);
    free(matrix);
    if (!links)
        fail("Memory allocation error");

    /* The count is printed first, so search once to count and again to list. */
    printf("%ld\n", dancing_links_solve(links, -1, NULL, NULL));
    if (list) {
        board queens = {n, 0};
        dancing_links_solve(links, -1, print_solution, &queens);
    }
    dancing_links_free(links);
    return 0;
}
