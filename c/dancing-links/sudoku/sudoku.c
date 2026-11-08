/*
 * sudoku.c: solve a 9x9 Sudoku.
 *
 * Author: Alex Quiterio
 *
 * Input: the 81 cells row by row, 0 for an empty cell.
 */

#include "../puzzle.h"

#include <string.h>

/* Placing digit k+1 in cell (i, j) is choice i*81 + j*9 + k. */
#define CHOICES (9 * 9 * 9)

/*
 * Four kinds of constraint, 81 of each: every cell holds one digit, and every
 * row, column and box holds each digit once.
 */
#define CONSTRAINTS (9 * 9 * 4)

typedef int sudoku[9][9];

static void read_board(sudoku board) {
    for (int i = 0; i < 9; i++)
        for (int j = 0; j < 9; j++)
            if (scanf("%d", &board[i][j]) != 1 || board[i][j] < 0 || board[i][j] > 9)
                fail("Invalid input board");
}

/* The four constraints that placing digit k+1 in cell (i, j) satisfies. */
static void constraints_of(int i, int j, int k, int out[4]) {
    out[0] = i * 9 + j;
    out[1] = 81 + i * 9 + k;
    out[2] = 162 + j * 9 + k;
    out[3] = 243 + (i / 3) * 27 + (j / 3) * 9 + k;
}

/*
 * A given digit rules out every choice that clashes with it, and already
 * satisfies its four constraints, so neither needs to go in the matrix.
 */
static void rule_out_givens(const sudoku board, bool choice_open[CHOICES],
                            bool constraint_open[CONSTRAINTS]) {
    memset(choice_open, true, CHOICES);
    memset(constraint_open, true, CONSTRAINTS);
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            int k = board[i][j] - 1;
            if (k < 0)
                continue;
            for (int x = 0; x < 9; x++) {
                int box_i = (i / 3) * 3 + x / 3, box_j = (j / 3) * 3 + x % 3;
                choice_open[i * 81 + j * 9 + x] = false;         /* same cell */
                choice_open[i * 81 + x * 9 + k] = false;         /* same row */
                choice_open[x * 81 + j * 9 + k] = false;         /* same column */
                choice_open[box_i * 81 + box_j * 9 + k] = false; /* same box */
            }
            int satisfied[4];
            constraints_of(i, j, k, satisfied);
            for (int c = 0; c < 4; c++)
                constraint_open[satisfied[c]] = false;
        }
    }
}

/*
 * Builds the matrix from the open choices (rows) and open constraints (columns).
 * choice_at[r] is the choice behind matrix row r.
 */
static char *build_matrix(const sudoku board, int choice_at[CHOICES], int *rows, int *columns) {
    bool choice_open[CHOICES], constraint_open[CONSTRAINTS];
    rule_out_givens(board, choice_open, constraint_open);

    int row_of[CHOICES], column_of[CONSTRAINTS];
    *rows = *columns = 0;
    for (int c = 0; c < CHOICES; c++) {
        row_of[c] = choice_open[c] ? *rows : -1;
        if (choice_open[c])
            choice_at[(*rows)++] = c;
    }
    for (int c = 0; c < CONSTRAINTS; c++)
        column_of[c] = constraint_open[c] ? (*columns)++ : -1;

    char *matrix = allocate((size_t)*rows * *columns, 1);
    for (int r = 0; r < *rows; r++) {
        int c = choice_at[r], constraints[4];
        constraints_of(c / 81, (c / 9) % 9, c % 9, constraints);
        for (int x = 0; x < 4; x++)
            if (column_of[constraints[x]] >= 0)
                matrix[(size_t)r * *columns + column_of[constraints[x]]] = 1;
    }
    return matrix;
}

static void print_board(const sudoku board) {
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++)
            printf("%d ", board[i][j]);
        printf("\n");
    }
}

int main(void) {
    sudoku board;
    read_board(board);

    int choice_at[CHOICES], rows, columns;
    char *matrix = build_matrix(board, choice_at, &rows, &columns);
    int chosen[CHOICES];
    int count = solve_first(matrix, rows, columns, 0, -1, chosen);
    free(matrix);
    if (count < 0)
        fail("No solution found");

    for (int r = 0; r < count; r++) {
        int c = choice_at[chosen[r]];
        board[c / 81][(c / 9) % 9] = c % 9 + 1;
    }
    print_board(board);
    return 0;
}
