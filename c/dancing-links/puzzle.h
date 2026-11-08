/*
 * puzzle.h: helpers shared by the puzzles, which all give up on bad input or
 * when memory runs out.
 *
 * Author: Alex Quiterio
 */

#ifndef PUZZLE_H
#define PUZZLE_H

#include "dancing_links.h"

#include <stdio.h>
#include <stdlib.h>

/* Prints the message and exits with status 1. */
static inline void fail(const char *message) {
    fprintf(stderr, "%s\n", message);
    exit(1);
}

/* Zeroed memory for count items of size bytes; never NULL. Always room for one item. */
static inline void *allocate(size_t count, size_t size) {
    void *memory = calloc(count > 0 ? count : 1, size);
    if (!memory)
        fail("Memory allocation error");
    return memory;
}

/* Resizes memory to count items of size bytes; never NULL. */
static inline void *reallocate(void *memory, size_t count, size_t size) {
    void *grown = realloc(memory, (count > 0 ? count : 1) * size);
    if (!grown)
        fail("Memory allocation error");
    return grown;
}

/*
 * Finds the first exact cover of the matrix, using at most max_rows rows (-1 for
 * no cap), and stores its row indexes in chosen, which needs room for every row.
 * Returns how many rows it used, or -1 if there is no solution.
 */
static inline int solve_first(const char *matrix, int rows, int primary, int secondary,
                              int max_rows, int *chosen) {
    dancing_links *links = dancing_links_new(rows, primary, secondary, matrix);
    if (!links)
        fail("Memory allocation error");
    dancing_links_first first = {chosen, 0};
    long found = dancing_links_solve(links, max_rows, dancing_links_take_first, &first);
    dancing_links_free(links);
    return found ? first.count : -1;
}

#endif
