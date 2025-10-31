/* Day 10: Cathode-Ray Tube */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int x = 1, cycle = 0;
static long strength = 0;
static char screen[6][41];

/* Each cycle: sample the signal, then draw one pixel of the 40 x 6 CRT. */
static void tick(void) {
    cycle++;
    if ((cycle - 20) % 40 == 0) {
        strength += (long)cycle * x;
    }
    int pixel = cycle - 1, row = pixel / 40, column = pixel % 40;
    if (row < 6) {
        screen[row][column] = abs(column - x) <= 1 ? '#' : '.';
    }
}

/* Advent of Code's 4 x 6 capital letters, so part 2 can be submitted as text. */
static const struct {
    const char *shape;
    char letter;
} font[] = {
    {".##.#..##..######..##..#", 'A'}, {"###.#..####.#..##..####.", 'B'},
    {".##.#..##...#...#..#.##.", 'C'}, {"#####...###.#...#...####", 'E'},
    {"#####...###.#...#...#...", 'F'}, {".##.#..##...#.###..#.###", 'G'},
    {"#..##..######..##..##..#", 'H'}, {".###..#...#...#...#..###", 'I'},
    {"..##...#...#...##..#.##.", 'J'}, {"#..##.#.##..#.#.#.#.#..#", 'K'},
    {"#...#...#...#...#...####", 'L'}, {".##.#..##..##..##..#.##.", 'O'},
    {"###.#..##..####.#...#...", 'P'}, {"###.#..##..####.#.#.#..#", 'R'},
    {".####...#....##....####.", 'S'}, {"#..##..##..##..##..#.##.", 'U'},
    {"####...#..#..#..#...####", 'Z'},
};

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    char line[64];
    while (fgets(line, sizeof line, in)) {
        if (strncmp(line, "noop", 4) == 0) {
            tick();
        } else if (strncmp(line, "addx ", 5) == 0) {
            tick();
            tick();
            x += atoi(line + 5);
        }
    }
    fclose(in);

    char letters[9] = {0};
    int unknown = 0;
    for (int i = 0; i < 8; i++) {
        char shape[25] = {0};
        for (int r = 0; r < 6; r++) {
            memcpy(shape + 4 * r, &screen[r][5 * i], 4);
        }
        letters[i] = '?';
        for (size_t f = 0; f < sizeof font / sizeof font[0]; f++) {
            if (strcmp(shape, font[f].shape) == 0) {
                letters[i] = font[f].letter;
            }
        }
        unknown |= letters[i] == '?';
    }
    printf("%ld\n%s\n", strength, letters);
    if (unknown) { /* show the picture when it is not letters */
        for (int r = 0; r < 6; r++) {
            fprintf(stderr, "%s\n", screen[r]);
        }
    }
    return 0;
}
