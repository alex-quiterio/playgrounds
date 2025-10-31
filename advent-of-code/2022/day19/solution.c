/* Day 19: Not Enough Minerals */
#include <stdio.h>

enum { ORE, CLAY, OBSIDIAN, GEODE };

typedef struct {
    int id;
    int cost[4][3]; /* cost[robot][ore, clay, obsidian] */
    int max_spend[3];
} blueprint;

static int best;

/* Depth-first search over "which robot do I build next", skipping ahead to
 * the minute it can be afforded instead of simulating every minute. */
static void search(const blueprint *b, int time, int robots[4], int stock[4]) {
    /* Geodes if nothing else is built. */
    int floor = stock[GEODE] + robots[GEODE] * time;
    if (floor > best) {
        best = floor;
    }
    /* Even building a geode robot every remaining minute cannot beat the best. */
    if (floor + time * (time - 1) / 2 <= best) {
        return;
    }
    for (int r = GEODE; r >= ORE; r--) {
        if (r != GEODE && robots[r] >= b->max_spend[r]) {
            continue; /* enough of this robot: we can never spend more per minute */
        }
        int wait = 0, possible = 1;
        for (int m = ORE; m <= OBSIDIAN; m++) {
            int need = b->cost[r][m] - stock[m];
            if (need <= 0) {
                continue;
            }
            if (robots[m] == 0) {
                possible = 0;
                break;
            }
            int w = (need + robots[m] - 1) / robots[m];
            wait = w > wait ? w : wait;
        }
        if (!possible || wait + 1 >= time) {
            continue;
        }
        int next_stock[4], next_robots[4];
        for (int m = 0; m < 4; m++) {
            next_stock[m] = stock[m] + robots[m] * (wait + 1) - (m < 3 ? b->cost[r][m] : 0);
            next_robots[m] = robots[m] + (m == r);
        }
        search(b, time - wait - 1, next_robots, next_stock);
    }
}

static int most_geodes(const blueprint *b, int minutes) {
    int robots[4] = {1, 0, 0, 0}, stock[4] = {0, 0, 0, 0};
    best = 0;
    search(b, minutes, robots, stock);
    return best;
}

int main(int argc, char **argv) {
    FILE *in = argc > 1 ? fopen(argv[1], "r") : NULL;
    if (in == NULL) {
        fprintf(stderr, "usage: %s INPUT\n", argv[0]);
        return 1;
    }
    /* Every blueprint is seven numbers: id, ore, ore, ore + clay, ore + obsidian. */
    blueprint bps[64];
    int n = 0;
    int v[7];
    while (n < 64 && fscanf(in, " Blueprint %d: Each ore robot costs %d ore. Each clay robot costs %d ore. "
                                "Each obsidian robot costs %d ore and %d clay. "
                                "Each geode robot costs %d ore and %d obsidian.",
                            &v[0], &v[1], &v[2], &v[3], &v[4], &v[5], &v[6]) == 7) {
        blueprint b = {.id = v[0]};
        b.cost[ORE][ORE] = v[1];
        b.cost[CLAY][ORE] = v[2];
        b.cost[OBSIDIAN][ORE] = v[3];
        b.cost[OBSIDIAN][CLAY] = v[4];
        b.cost[GEODE][ORE] = v[5];
        b.cost[GEODE][OBSIDIAN] = v[6];
        for (int m = 0; m < 3; m++) {
            for (int r = 0; r < 4; r++) {
                if (b.cost[r][m] > b.max_spend[m]) {
                    b.max_spend[m] = b.cost[r][m];
                }
            }
        }
        bps[n++] = b;
    }
    fclose(in);

    long quality = 0, product = 1;
    for (int i = 0; i < n; i++) {
        quality += (long)bps[i].id * most_geodes(&bps[i], 24);
    }
    for (int i = 0; i < n && i < 3; i++) {
        product *= most_geodes(&bps[i], 32);
    }
    printf("%ld\n%ld\n", quality, product);
    return 0;
}
