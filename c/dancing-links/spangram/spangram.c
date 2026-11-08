/*
 * spangram.c: solve a Strands-style word grid (as in the NYT game Strands).
 * Cover every letter of the grid with words traced through neighbouring cells
 * (including diagonals), each cell used once and no two paths crossing.
 *
 * Author: Alex Quiterio
 *
 * Input: the grid, one row of letters per line.
 * Arguments, in any order:
 *   a number           the most words the solution may use
 *   a name with a dot  the word list to use (default words.txt)
 *   any other word     a word the solution must not use
 * Output: the words found, then the grid with each word's path drawn in and its
 * first letter in upper case.
 */

#include "../puzzle.h"

#include <ctype.h>
#include <string.h>

#define MIN_WORD_LENGTH 4
#define MAX_WORD 256 /* longest word or grid row read */

typedef struct {
    const char *word_list;
    int max_words; /* -1 for no limit */
    const char **forbidden;
    int forbidden_count;
} options;

/* A trie of the word list. Only the letters a-z are stored. */
typedef struct trie_node {
    struct trie_node *children[26];
    bool ends_word;
} trie_node;

/* The grid, row by row, in lower case. Cells are numbered row * cols + column. */
static char grid[MAX_WORD][MAX_WORD + 1];
static int rows, cols;

/* One way to trace a word through the grid: the cells it visits, in order. */
typedef struct {
    int length;
    int *cells;
} placement;

static placement *placements;
static int placement_count, placement_capacity;

/* ---- Reading the input ---- */

static options parse_arguments(int argc, char *argv[]) {
    options o = {"words.txt", -1, allocate(argc, sizeof(char *)), 0};
    for (int arg = 1; arg < argc; arg++) {
        if (isdigit((unsigned char)argv[arg][0]))
            o.max_words = atoi(argv[arg]);
        else if (strchr(argv[arg], '.'))
            o.word_list = argv[arg];
        else
            o.forbidden[o.forbidden_count++] = argv[arg];
    }
    return o;
}

static bool is_lowercase_word(const char *word) {
    for (; *word; word++)
        if (*word < 'a' || *word > 'z')
            return false;
    return true;
}

static bool is_forbidden(const options *o, const char *word) {
    for (int i = 0; i < o->forbidden_count; i++)
        if (strcmp(word, o->forbidden[i]) == 0)
            return true;
    return false;
}

static void trie_insert(trie_node *root, const char *word) {
    trie_node *node = root;
    for (const char *letter = word; *letter; letter++) {
        int index = *letter - 'a';
        if (!node->children[index])
            node->children[index] = allocate(1, sizeof *node);
        node = node->children[index];
    }
    node->ends_word = true;
}

static void trie_free(trie_node *node) {
    if (!node)
        return;
    for (int index = 0; index < 26; index++)
        trie_free(node->children[index]);
    free(node);
}

/* Every word of at least four lower-case letters that isn't forbidden. */
static trie_node *load_word_list(const options *o) {
    FILE *file = fopen(o->word_list, "r");
    if (!file) {
        fprintf(stderr, "Cannot open the word list %s\n", o->word_list);
        exit(1);
    }
    trie_node *trie = allocate(1, sizeof *trie);
    char word[MAX_WORD + 1];
    while (fscanf(file, "%256s", word) == 1)
        if (strlen(word) >= MIN_WORD_LENGTH && is_lowercase_word(word) && !is_forbidden(o, word))
            trie_insert(trie, word);
    fclose(file);
    return trie;
}

static void read_grid(void) {
    while (rows < MAX_WORD && scanf("%256s", grid[rows]) == 1) {
        int length = (int)strlen(grid[rows]);
        if (rows == 0)
            cols = length;
        for (int col = 0; col < length; col++)
            grid[rows][col] = (char)tolower((unsigned char)grid[rows][col]);
        if (length != cols || !is_lowercase_word(grid[rows]))
            fail("The grid must be rows of letters, all the same length");
        rows++;
    }
    if (rows == 0)
        fail("Empty grid");
}

/* ---- Finding every way to trace every word ---- */

/* The search state while tracing words. */
static bool *visited;
static int *path;
static int path_length;

/* Neighbours in all eight directions, in the order the search tries them. */
static const int neighbour_rows[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
static const int neighbour_cols[8] = {-1, 0, 1, -1, 1, -1, 0, 1};

/* Whether the path so far steps directly between cells a and b, in either direction. */
static bool path_steps_between(int a, int b) {
    for (int step = 1; step < path_length; step++)
        if ((path[step] == a && path[step - 1] == b) || (path[step] == b && path[step - 1] == a))
            return true;
    return false;
}

static void record_path(void) {
    if (placement_count == placement_capacity) {
        placement_capacity = placement_capacity ? placement_capacity * 2 : 256;
        placements = reallocate(placements, placement_capacity, sizeof *placements);
    }
    placement *added = &placements[placement_count++];
    added->length = path_length;
    added->cells = allocate(path_length, sizeof *added->cells);
    memcpy(added->cells, path, sizeof *path * path_length);
}

/* Extends the current path to (row, col) and records every word it spells. */
static void trace_words(const trie_node *node, int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols)
        return;
    int cell = row * cols + col;
    if (visited[cell])
        return;
    const trie_node *next = node->children[grid[row][col] - 'a'];
    if (!next)
        return;

    visited[cell] = true;
    path[path_length++] = cell;
    if (next->ends_word)
        record_path();

    for (int direction = 0; direction < 8; direction++) {
        int row_step = neighbour_rows[direction], col_step = neighbour_cols[direction];
        bool diagonal = row_step != 0 && col_step != 0;
        /* A diagonal step must not cross a diagonal step already in this path. */
        if (diagonal &&
            path_steps_between((row + row_step) * cols + col, row * cols + col + col_step))
            continue;
        trace_words(next, row + row_step, col + col_step);
    }

    path_length--;
    visited[cell] = false;
}

static void find_placements(const trie_node *trie) {
    visited = allocate((size_t)rows * cols, sizeof *visited);
    path = allocate((size_t)rows * cols, sizeof *path);
    for (int row = 0; row < rows; row++)
        for (int col = 0; col < cols; col++)
            trace_words(trie, row, col);
    free(path);
    free(visited);
}

/* ---- The exact cover matrix ---- */

/* Each 2x2 block of cells has one secondary column, for the diagonals through it. */
static int diagonal_column(int a, int b) {
    int top = a / cols < b / cols ? a / cols : b / cols;
    int left = a % cols < b % cols ? a % cols : b % cols;
    return rows * cols + top * (cols - 1) + left;
}

/*
 * Placements are the rows. Every cell must be covered exactly once (primary
 * columns). The two diagonals of each 2x2 block cross, so at most one path may
 * step through it diagonally (secondary columns).
 */
static char *build_matrix(int *primary, int *secondary) {
    *primary = rows * cols;
    *secondary = (rows - 1) * (cols - 1);
    int columns = *primary + *secondary;
    char *matrix = allocate((size_t)placement_count * columns, 1);
    for (int r = 0; r < placement_count; r++) {
        char *row = matrix + (size_t)r * columns;
        const placement *p = &placements[r];
        for (int step = 0; step < p->length; step++)
            row[p->cells[step]] = 1;
        for (int step = 1; step < p->length; step++) {
            int a = p->cells[step - 1], b = p->cells[step];
            if (a / cols != b / cols && a % cols != b % cols)
                row[diagonal_column(a, b)] = 1;
        }
    }
    return matrix;
}

/* ---- Printing ---- */

static char step_mark(int row_step, int col_step) {
    if (row_step == 0)
        return '-';
    if (col_step == 0)
        return '|';
    return row_step == col_step ? '\\' : '/';
}

static void print_solution(const int *chosen, int count) {
    int height = 2 * rows - 1, width = 2 * cols - 1;
    char *drawing = allocate((size_t)height * width, 1);
    memset(drawing, ' ', (size_t)height * width);
    for (int row = 0; row < rows; row++)
        for (int col = 0; col < cols; col++)
            drawing[2 * row * width + 2 * col] = grid[row][col];

    for (int word = 0; word < count; word++) {
        const placement *p = &placements[chosen[word]];
        for (int step = 0; step < p->length; step++)
            putchar(grid[p->cells[step] / cols][p->cells[step] % cols]);
        putchar(' ');

        int first = p->cells[0];
        char *start = &drawing[2 * (first / cols) * width + 2 * (first % cols)];
        *start = (char)toupper((unsigned char)*start);

        for (int step = 1; step < p->length; step++) {
            int from_row = p->cells[step - 1] / cols, from_col = p->cells[step - 1] % cols;
            int row_step = p->cells[step] / cols - from_row;
            int col_step = p->cells[step] % cols - from_col;
            drawing[(2 * from_row + row_step) * width + 2 * from_col + col_step] =
                step_mark(row_step, col_step);
        }
    }
    printf("\n");
    for (int row = 0; row < height; row++)
        printf("%.*s\n", width, drawing + row * width);
    printf("\n");
    free(drawing);
}

int main(int argc, char *argv[]) {
    options o = parse_arguments(argc, argv);
    trie_node *trie = load_word_list(&o);
    read_grid();
    find_placements(trie);
    trie_free(trie);

    int primary, secondary;
    char *matrix = build_matrix(&primary, &secondary);
    int *chosen = allocate(placement_count, sizeof *chosen);
    int count = solve_first(matrix, placement_count, primary, secondary, o.max_words, chosen);
    free(matrix);
    if (count < 0)
        fail("No solution found");

    print_solution(chosen, count);
    free(chosen);
    for (int r = 0; r < placement_count; r++)
        free(placements[r].cells);
    free(placements);
    free(o.forbidden);
    return 0;
}
