/*
 * dancing_links.c: Knuth's Algorithm X with Dancing Links.
 *
 * Author: Alex Quiterio
 */

#include "dancing_links.h"

#include <stdlib.h>

typedef struct column column;

/* A 1 in the matrix, linked to its neighbours in the same row and column. */
typedef struct node {
    struct node *left, *right, *up, *down;
    column *col;
    int row;
} node;

/* A column header. head is the dummy node at the top and bottom of the column. */
struct column {
    column *left, *right;
    node head;
    int size;       /* number of 1s still linked in the column */
    bool essential; /* primary: covered exactly once; secondary: at most once */
};

struct dancing_links {
    column root; /* dummy column before the first and after the last column */
    column *columns;
    node *nodes;
    int *solution; /* rows picked so far, as a stack */
    int depth;
    int max_rows;
    long found;
    bool stopped;
    dancing_links_visit visit;
    void *ctx;
};

dancing_links *dancing_links_new(int rows, int primary, int secondary, const char *matrix) {
    int cols = primary + secondary;
    long ones = 0;
    for (long k = 0; k < (long)rows * cols; k++)
        if (matrix[k])
            ones++;

    dancing_links *links = calloc(1, sizeof *links);
    if (!links)
        return NULL;
    links->columns = calloc(cols > 0 ? cols : 1, sizeof *links->columns);
    links->nodes = calloc(ones > 0 ? ones : 1, sizeof *links->nodes);
    links->solution = calloc(rows > 0 ? rows : 1, sizeof *links->solution);
    if (!links->columns || !links->nodes || !links->solution) {
        dancing_links_free(links);
        return NULL;
    }

    /* Columns in a ring through the root, primary ones first. */
    links->root.essential = false;
    links->root.left = links->root.right = &links->root;
    for (int j = 0; j < cols; j++) {
        column *c = &links->columns[j];
        c->essential = j < primary;
        c->head.up = c->head.down = &c->head;
        c->head.col = c;
        c->head.row = -1;
        c->left = links->root.left;
        c->right = &links->root;
        links->root.left->right = c;
        links->root.left = c;
    }

    /* One node per 1, appended to the bottom of its column and the end of its row. */
    node *next = links->nodes;
    for (int i = 0; i < rows; i++) {
        node *first = NULL;
        for (int j = 0; j < cols; j++) {
            if (!matrix[(long)i * cols + j])
                continue;
            column *c = &links->columns[j];
            node *n = next++;
            n->row = i;
            n->col = c;
            n->down = &c->head;
            n->up = c->head.up;
            c->head.up->down = n;
            c->head.up = n;
            c->size++;
            if (!first) {
                first = n->left = n->right = n;
            } else {
                n->right = first;
                n->left = first->left;
                first->left->right = n;
                first->left = n;
            }
        }
    }
    return links;
}

void dancing_links_free(dancing_links *links) {
    if (!links)
        return;
    free(links->columns);
    free(links->nodes);
    free(links->solution);
    free(links);
}

/* Takes a column out of the header list, and every row that has a 1 in it out of
 * the other columns. */
static void cover(column *c) {
    c->left->right = c->right;
    c->right->left = c->left;
    for (node *i = c->head.down; i != &c->head; i = i->down) {
        for (node *j = i->right; j != i; j = j->right) {
            j->up->down = j->down;
            j->down->up = j->up;
            j->col->size--;
        }
    }
}

/* Undoes cover, putting everything back in the reverse order it was taken out. */
static void uncover(column *c) {
    for (node *i = c->head.up; i != &c->head; i = i->up) {
        for (node *j = i->left; j != i; j = j->left) {
            j->col->size++;
            j->up->down = j;
            j->down->up = j;
        }
    }
    c->left->right = c;
    c->right->left = c;
}

static void search(dancing_links *links) {
    /* Primary columns come first, so if the first one left is secondary, every
     * primary column is covered. */
    if (!links->root.right->essential) {
        links->found++;
        if (links->visit && !links->visit(links->solution, links->depth, links->ctx))
            links->stopped = true;
        return;
    }
    if (links->max_rows != -1 && links->depth >= links->max_rows)
        return;

    /* Branch on the primary column with the fewest 1s left. */
    column *chosen = links->root.right;
    for (column *c = chosen->right; c->essential; c = c->right)
        if (c->size < chosen->size)
            chosen = c;
    if (chosen->size == 0)
        return;

    cover(chosen);
    for (node *r = chosen->head.down; r != &chosen->head && !links->stopped; r = r->down) {
        links->solution[links->depth++] = r->row;
        for (node *j = r->right; j != r; j = j->right)
            cover(j->col);
        search(links);
        for (node *j = r->left; j != r; j = j->left)
            uncover(j->col);
        links->depth--;
    }
    uncover(chosen);
}

long dancing_links_solve(dancing_links *links, int max_rows, dancing_links_visit visit, void *ctx) {
    links->depth = 0;
    links->found = 0;
    links->stopped = false;
    links->max_rows = max_rows;
    links->visit = visit;
    links->ctx = ctx;
    search(links);
    return links->found;
}

bool dancing_links_take_first(const int *rows, int count, void *ctx) {
    dancing_links_first *first = ctx;
    for (int i = 0; i < count; i++)
        first->rows[i] = rows[i];
    first->count = count;
    return false;
}
