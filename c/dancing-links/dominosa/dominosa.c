/*
 * dominosa.c: solve Dominosa, tiling a board of numbers with dominoes so that
 * no domino appears twice. Play it at http://www.puzzle-dominosa.com/
 *
 * Author: Alex Quiterio
 *
 * Input: the height H, then the (H+1)-wide board row by row, using the numbers
 * 0 to H-1. Output: the board with each cell marked '-' or '|' for its domino.
 */

#include "../puzzle.h"

/* Classic Dominosa: an H x (H+1) board of the numbers 0 to H-1. */
typedef struct {
    int height, width, values;
    int *cells; /* row by row */
} board;

static board read_board(void) {
    board b;
    if (scanf("%d", &b.height) != 1 || b.height < 1)
        fail("Invalid board size");
    b.width = b.height + 1;
    b.values = b.height;
    b.cells = allocate((size_t)b.height * b.width, sizeof *b.cells);
    for (int k = 0; k < b.height * b.width; k++)
        if (scanf("%d", &b.cells[k]) != 1 || b.cells[k] < 0 || b.cells[k] >= b.values)
            fail("Invalid entry found in the board");
    return b;
}

/* Matrix rows are the domino positions: every horizontal one, then every vertical one. */
static int horizontal_count(const board *b) {
    return b->height * (b->width - 1);
}

static int domino_count(const board *b) {
    return horizontal_count(b) + b->width * (b->height - 1);
}

/* The two cells domino position r covers, and the mark it leaves on them. */
static char domino_cells(const board *b, int r, int *first, int *second) {
    if (r < horizontal_count(b)) {
        *first = (r / (b->width - 1)) * b->width + r % (b->width - 1);
        *second = *first + 1;
        return '-';
    }
    *first = r - horizontal_count(b);
    *second = *first + b->width;
    return '|';
}

/*
 * Every cell must be covered once, and every pair of numbers (d, e) used once.
 * A d-e domino marks both the (d, e) and (e, d) columns.
 */
static char *build_matrix(const board *b, int *columns) {
    int cells = b->height * b->width;
    *columns = cells + b->values * b->values;
    char *matrix = allocate((size_t)domino_count(b) * *columns, 1);
    for (int r = 0; r < domino_count(b); r++) {
        int first, second;
        domino_cells(b, r, &first, &second);
        int d = b->cells[first], e = b->cells[second];
        char *row = matrix + (size_t)r * *columns;
        row[first] = row[second] = 1;
        row[cells + d * b->values + e] = 1;
        row[cells + e * b->values + d] = 1;
    }
    return matrix;
}

static void print_tiling(const board *b, const int *chosen, int count) {
    char *marks = allocate((size_t)b->height * b->width, 1);
    for (int i = 0; i < count; i++) {
        int first, second;
        char mark = domino_cells(b, chosen[i], &first, &second);
        marks[first] = marks[second] = mark;
    }
    for (int row = 0; row < b->height; row++)
        printf("%.*s\n", b->width, marks + row * b->width);
    free(marks);
}

int main(void) {
    board b = read_board();

    int columns;
    char *matrix = build_matrix(&b, &columns);
    int *chosen = allocate(domino_count(&b), sizeof *chosen);
    int count = solve_first(matrix, domino_count(&b), columns, 0, -1, chosen);
    free(matrix);
    if (count < 0)
        fail("No solution found");

    print_tiling(&b, chosen, count);
    free(chosen);
    free(b.cells);
    return 0;
}
