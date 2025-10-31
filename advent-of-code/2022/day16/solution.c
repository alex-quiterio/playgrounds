/* Day 16: Proboscidea Volcanium */
#include <stdio.h>
#include <string.h>

#define MAXV 64
#define INF 1000

static char names[MAXV][3];
static int flow[MAXV], nvalves = 0;
static int dist[MAXV][MAXV];

static int id(const char *name) {
    for (int i = 0; i < nvalves; i++) {
        if (strncmp(names[i], name, 2) == 0) {
            return i;
        }
    }
    memcpy(names[nvalves], name, 2);
    return nvalves++;
}

/* Valves worth opening, as indexes into the valve list. */
static int useful[16], nuseful = 0;
/* best[mask] = most pressure released opening exactly the valves in mask. */
static int best[1 << 16];

static void search(int at, int time_left, int opened, int released) {
    if (released > best[opened]) {
        best[opened] = released;
    }
    for (int i = 0; i < nuseful; i++) {
        int v = useful[i], left = time_left - dist[at][v] - 1;
        if (!(opened & (1 << i)) && left > 0) {
            search(v, left, opened | (1 << i), released + left * flow[v]);
        }
    }
}

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    for (int i = 0; i < MAXV; i++) {
        for (int j = 0; j < MAXV; j++) {
            dist[i][j] = i == j ? 0 : INF;
        }
    }
    char line[256];
    while (fgets(line, sizeof line, in)) {
        char name[3];
        int rate;
        if (sscanf(line, "Valve %2s has flow rate=%d", name, &rate) != 2) {
            continue;
        }
        int v = id(name);
        flow[v] = rate;
        /* "tunnels lead to valves AA, BB" or "tunnel leads to valve AA" */
        char *list = strstr(line, "valve");
        list += strncmp(list, "valves", 6) == 0 ? 6 : 5;
        for (char *p = strtok(list, " ,\n"); p; p = strtok(NULL, " ,\n")) {
            dist[v][id(p)] = 1;
        }
    }
    fclose(in);

    /* Shortest distances between all valves (Floyd-Warshall). */
    for (int k = 0; k < nvalves; k++) {
        for (int i = 0; i < nvalves; i++) {
            for (int j = 0; j < nvalves; j++) {
                if (dist[i][k] + dist[k][j] < dist[i][j]) {
                    dist[i][j] = dist[i][k] + dist[k][j];
                }
            }
        }
    }
    for (int v = 0; v < nvalves; v++) {
        if (flow[v] > 0) {
            useful[nuseful++] = v;
        }
    }
    int start = id("AA");

    search(start, 30, 0, 0);
    int part1 = 0;
    for (int m = 0; m < (1 << nuseful); m++) {
        part1 = best[m] > part1 ? best[m] : part1;
    }

    /* Part 2: you and the elephant each get 26 minutes and open disjoint valves. */
    memset(best, 0, sizeof best);
    search(start, 26, 0, 0);
    int full = (1 << nuseful) - 1;
    /* Let best[mask] cover every subset of mask, then pair a mask with its complement. */
    for (int i = 0; i < nuseful; i++) {
        for (int m = 0; m <= full; m++) {
            if (m & (1 << i) && best[m ^ (1 << i)] > best[m]) {
                best[m] = best[m ^ (1 << i)];
            }
        }
    }
    int part2 = 0;
    for (int m = 0; m <= full; m++) {
        int total = best[m] + best[full ^ m];
        part2 = total > part2 ? total : part2;
    }
    printf("%d\n%d\n", part1, part2);
    return 0;
}
