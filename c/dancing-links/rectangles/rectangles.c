/*
 * rectangles.c: solve Rectangles (Shikaku), splitting a board into rectangles
 * that each hold exactly one number, equal to the rectangle's area. Play it at
 * https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/rect.html
 *
 * Author: Alex Quiterio
 *
 * Input: the height and width, then the board row by row, 0 for an empty cell.
 * Output: the board with every cell labelled by the rectangle it belongs to.
 */

#include "../puzzle.h"

typedef struct {
    int height, width;
    int *cells;    /* row by row, 0 for an empty cell */
    int *numbered; /* numbered[i*width+j]: numbered cells in rows 0..i, columns 0..j */
} board;

typedef struct {
    int top, bottom, left, right; /* inclusive */
} rectangle;

typedef struct {
    rectangle *items;
    int count, capacity;
} rectangle_list;

static int numbered_up_to(const board *b, int i, int j) {
    return (i < 0 || j < 0) ? 0 : b->numbered[i * b->width + j];
}

static int numbers_inside(const board *b, rectangle r) {
    return numbered_up_to(b, r.bottom, r.right) - numbered_up_to(b, r.top - 1, r.right) -
           numbered_up_to(b, r.bottom, r.left - 1) + numbered_up_to(b, r.top - 1, r.left - 1);
}

static board read_board(void) {
    board b;
    if (scanf("%d%d", &b.height, &b.width) != 2 || b.height < 1 || b.width < 1)
        fail("Invalid board size");
    b.cells = allocate((size_t)b.height * b.width, sizeof *b.cells);
    b.numbered = allocate((size_t)b.height * b.width, sizeof *b.numbered);
    for (int i = 0; i < b.height; i++) {
        for (int j = 0; j < b.width; j++) {
            int *cell = &b.cells[i * b.width + j];
            if (scanf("%d", cell) != 1 || *cell < 0)
                fail("Invalid board");
            b.numbered[i * b.width + j] = numbered_up_to(&b, i, j - 1) +
                                          numbered_up_to(&b, i - 1, j) -
                                          numbered_up_to(&b, i - 1, j - 1) + (*cell > 0);
        }
    }
    return b;
}

static void add(rectangle_list *list, rectangle r) {
    if (list->count == list->capacity) {
        list->capacity = list->capacity ? list->capacity * 2 : 64;
        list->items = reallocate(list->items, list->capacity, sizeof *list->items);
    }
    list->items[list->count++] = r;
}

/* Every rectangle around the number at (i, j) with that area and no other number inside. */
static void add_candidates(const board *b, int i, int j, rectangle_list *list) {
    int area = b->cells[i * b->width + j];
    for (int height = area / (b->width + 1) + 1; height <= b->height; height++) {
        if (area % height)
            continue;
        int width = area / height;
        for (int top = i - height + 1 > 0 ? i - height + 1 : 0;
             top <= i && top + height - 1 < b->height; top++) {
            for (int left = j - width + 1 > 0 ? j - width + 1 : 0;
                 left <= j && left + width - 1 < b->width; left++) {
                rectangle r = {top, top + height - 1, left, left + width - 1};
                if (numbers_inside(b, r) == 1)
                    add(list, r);
            }
        }
    }
}

/* Candidate rectangles are the rows; every cell must be covered exactly once. */
static char *build_matrix(const board *b, const rectangle_list *list) {
    int columns = b->height * b->width;
    char *matrix = allocate((size_t)list->count * columns, 1);
    for (int r = 0; r < list->count; r++) {
        rectangle rect = list->items[r];
        for (int i = rect.top; i <= rect.bottom; i++)
            for (int j = rect.left; j <= rect.right; j++)
                matrix[(size_t)r * columns + i * b->width + j] = 1;
    }
    return matrix;
}

/* Labels each cell with the index of the chosen rectangle covering it. */
static void print_solution(board *b, const rectangle_list *list, const int *chosen, int count) {
    for (int n = 0; n < count; n++) {
        rectangle rect = list->items[chosen[n]];
        for (int i = rect.top; i <= rect.bottom; i++)
            for (int j = rect.left; j <= rect.right; j++)
                b->cells[i * b->width + j] = n;
    }
    for (int i = 0; i < b->height; i++) {
        for (int j = 0; j < b->width; j++)
            printf("%d ", b->cells[i * b->width + j]);
        printf("\n");
    }
}

int main(void) {
    board b = read_board();

    rectangle_list candidates = {NULL, 0, 0};
    for (int i = 0; i < b.height; i++)
        for (int j = 0; j < b.width; j++)
            if (b.cells[i * b.width + j] > 0)
                add_candidates(&b, i, j, &candidates);

    char *matrix = build_matrix(&b, &candidates);
    int *chosen = allocate(candidates.count, sizeof *chosen);
    int count = solve_first(matrix, candidates.count, b.height * b.width, 0, -1, chosen);
    free(matrix);
    if (count < 0)
        fail("No solution found");

    print_solution(&b, &candidates, chosen, count);
    free(chosen);
    free(candidates.items);
    free(b.numbered);
    free(b.cells);
    return 0;
}
