/* Day 3: Rucksack Reorganization */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

/* Priority: a-z are 1-26, A-Z are 27-52. */
static int priority(char c) { return c >= 'a' ? c - 'a' + 1 : c - 'A' + 27; }

/* The set of item types in s[0..n), one bit per priority. */
static uint64_t items(const char *s, size_t n) {
    uint64_t set = 0;
    for (size_t i = 0; i < n; i++) {
        set |= (uint64_t)1 << priority(s[i]);
    }
    return set;
}

/* The priority of the single item type in a set. */
static int only(uint64_t set) { return set ? __builtin_ctzll(set) : 0; }

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }

    long part1 = 0, part2 = 0;
    uint64_t group = ~(uint64_t)0;
    int member = 0;
    char line[256];
    while (fgets(line, sizeof line, in)) {
        size_t n = strcspn(line, "\r\n");
        if (n == 0) {
            continue;
        }
        /* Part 1: the item in both halves. */
        part1 += only(items(line, n / 2) & items(line + n / 2, n / 2));
        /* Part 2: the badge carried by all three elves of a group. */
        group &= items(line, n);
        if (++member == 3) {
            part2 += only(group);
            group = ~(uint64_t)0;
            member = 0;
        }
    }
    fclose(in);

    printf("%ld\n%ld\n", part1, part2);
    return 0;
}
