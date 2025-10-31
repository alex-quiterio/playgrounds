/* Day 2: Rock Paper Scissors */
#include <stdio.h>

/* Shapes are 0 = rock, 1 = paper, 2 = scissors; shape s beats (s + 2) % 3. */
static int score(int theirs, int mine) {
    int outcome = (mine - theirs + 4) % 3; /* 0 = loss, 1 = draw, 2 = win */
    return mine + 1 + 3 * outcome;
}

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }

    long part1 = 0, part2 = 0;
    char a, b;
    while (fscanf(in, " %c %c", &a, &b) == 2) {
        int theirs = a - 'A', column = b - 'X';
        part1 += score(theirs, column);                   /* X Y Z is my shape */
        part2 += score(theirs, (theirs + column + 2) % 3); /* X Y Z is the outcome */
    }
    fclose(in);

    printf("%ld\n%ld\n", part1, part2);
    return 0;
}
