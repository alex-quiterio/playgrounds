/* Unit tests for dancing_links.c, starting from the example matrix in Knuth's paper. */

#include "../dancing_links.h"

#include <stdio.h>
#include <string.h>

static int failures = 0;

#define CHECK(cond)                                                                                \
    do {                                                                                           \
        if (!(cond)) {                                                                             \
            printf("FAIL %s:%d: %s\n", __FILE__, __LINE__, #cond);                                 \
            failures++;                                                                            \
        }                                                                                          \
    } while (0)

/* Columns A-G; the only exact cover is rows 3 (A D), 0 (C E F) and 4 (B G). */
static const char knuth[6 * 7] = {
    0, 0, 1, 0, 1, 1, 0, /* C E F */
    1, 0, 0, 1, 0, 0, 1, /* A D G */
    0, 1, 1, 0, 0, 1, 0, /* B C F */
    1, 0, 0, 1, 0, 0, 0, /* A D */
    0, 1, 0, 0, 0, 0, 1, /* B G */
    0, 0, 0, 1, 1, 0, 1, /* D E G */
};

static void test_knuth_example(void) {
    dancing_links *links = dancing_links_new(6, 7, 0, knuth);
    int rows[6];
    dancing_links_first first = {rows, 0};
    CHECK(dancing_links_solve(links, -1, dancing_links_take_first, &first) == 1);
    CHECK(first.count == 3);
    CHECK(rows[0] == 3 && rows[1] == 0 && rows[2] == 4);
    CHECK(dancing_links_solve(links, -1, NULL, NULL) == 1);
    dancing_links_free(links);
}

static void test_max_rows(void) {
    dancing_links *links = dancing_links_new(6, 7, 0, knuth);
    CHECK(dancing_links_solve(links, 2, NULL, NULL) == 0);
    CHECK(dancing_links_solve(links, 3, NULL, NULL) == 1);
    dancing_links_free(links);
}

/* Two primary columns and one secondary column that both full rows touch. */
static void test_secondary_columns(void) {
    static const char matrix[4 * 3] = {
        1, 1, 1, /* both, using the secondary column */
        1, 0, 1, /* first, using the secondary column */
        0, 1, 0, /* second only */
        1, 0, 0, /* first only */
    };
    dancing_links *links = dancing_links_new(4, 2, 1, matrix);
    /* {0}, {1, 2} and {3, 2}; {0} with anything else would cover a column twice. */
    CHECK(dancing_links_solve(links, -1, NULL, NULL) == 3);
    dancing_links_free(links);

    /* As primary, the third column must be covered, so {3, 2} no longer works. */
    links = dancing_links_new(4, 3, 0, matrix);
    CHECK(dancing_links_solve(links, -1, NULL, NULL) == 2);
    dancing_links_free(links);
}

static void test_no_solution(void) {
    static const char matrix[2 * 2] = {1, 0, 1, 0}; /* nothing covers the second column */
    dancing_links *links = dancing_links_new(2, 2, 0, matrix);
    CHECK(dancing_links_solve(links, -1, NULL, NULL) == 0);
    dancing_links_free(links);
}

static void test_empty_matrix(void) {
    dancing_links *links = dancing_links_new(0, 0, 0, NULL);
    int rows[1];
    dancing_links_first first = {rows, -1};
    CHECK(dancing_links_solve(links, -1, dancing_links_take_first, &first) == 1);
    CHECK(first.count == 0);
    dancing_links_free(links);
}

/* Searching twice gives the same answer, so the links are restored afterwards. */
static void test_links_restored(void) {
    char matrix[5 * 5];
    memset(matrix, 0, sizeof matrix);
    for (int i = 0; i < 5; i++) {
        matrix[i * 5 + i] = 1;
        if (i < 4)
            matrix[i * 5 + i + 1] = 1;
    }
    dancing_links *links = dancing_links_new(5, 5, 0, matrix);
    long once = dancing_links_solve(links, -1, NULL, NULL);
    CHECK(once == 1); /* only row 4 covers the last column, then rows 2 and 0 */
    CHECK(dancing_links_solve(links, -1, NULL, NULL) == once);
    dancing_links_free(links);
}

int main(void) {
    test_knuth_example();
    test_max_rows();
    test_secondary_columns();
    test_no_solution();
    test_empty_matrix();
    test_links_restored();
    printf(failures ? "%d failed\n" : "dancing_links: all tests passed\n", failures);
    return failures != 0;
}
