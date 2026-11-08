/*
 * dancing_links.h: Knuth's Algorithm X with Dancing Links, for exact cover problems.
 *
 * Author: Alex Quiterio
 *
 * An exact cover problem is a 0/1 matrix. Pick a set of rows so that every
 * primary column has exactly one 1 in the chosen rows, and every secondary
 * column has at most one.
 */

#ifndef DANCING_LINKS_H
#define DANCING_LINKS_H

#include <stdbool.h>

typedef struct dancing_links dancing_links;

/*
 * Called once per solution with the chosen row indexes, in the order they were
 * picked. Return true to keep searching, false to stop.
 */
typedef bool (*dancing_links_visit)(const int *rows, int count, void *ctx);

/*
 * Builds the links for a rows x (primary + secondary) matrix, stored row by row.
 * Any non-zero byte is a 1. Columns [0, primary) are primary and the rest are
 * secondary. Returns NULL if memory runs out.
 */
dancing_links *dancing_links_new(int rows, int primary, int secondary, const char *matrix);

void dancing_links_free(dancing_links *links);

/*
 * Searches for exact covers, calling visit for each one until it returns false.
 * max_rows caps how many rows a solution may use (-1 for no cap). visit may be
 * NULL to just count every solution. Returns the number of solutions visited.
 */
long dancing_links_solve(dancing_links *links, int max_rows, dancing_links_visit visit, void *ctx);

/* A dancing_links_visit that stops at the first solution and copies it into a dancing_links_first.
 */
typedef struct {
    int *rows; /* caller-provided buffer with room for every row of the matrix */
    int count;
} dancing_links_first;

bool dancing_links_take_first(const int *rows, int count, void *ctx);

#endif
