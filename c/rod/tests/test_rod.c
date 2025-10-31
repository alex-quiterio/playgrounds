#include <assert.h>
#include <stdio.h>

#define ROD_NO_MAIN
#include "../rod.c"

/* Exhaustive reference: try every first cut. */
static int bruteForce(int price[], int n) {
    if (n == 0) {
        return 0;
    }
    int best = 0;
    for (int first = 1; first <= n; first++) {
        best = max(best, price[first - 1] + bruteForce(price, n - first));
    }
    return best;
}

static void testExampleFromStatement(void) {
    int price[] = {1, 5, 8, 9, 10, 17, 17, 20};
    assert(cutRod(price, 8) == 22); /* cut into 2 + 6 */
}

static void testProgramInput(void) {
    int price[] = {3, 5, 8, 9, 10, 17, 17, 20};
    assert(cutRod(price, 8) == 24); /* eight pieces of length 1 */
}

static void testWholeRodIsBest(void) {
    int price[] = {1, 1, 1, 100};
    assert(cutRod(price, 4) == 100);
}

static void testEmptyRod(void) {
    int price[] = {5};
    assert(cutRod(price, 0) == 0);
}

static void testSinglePiece(void) {
    int price[] = {7};
    assert(cutRod(price, 1) == 7);
}

static void testMatchesBruteForce(void) {
    unsigned seed = 42;
    for (int round = 0; round < 200; round++) {
        int price[12];
        int n = round % 12 + 1;
        for (int i = 0; i < n; i++) {
            seed = seed * 1103515245u + 12345u;
            price[i] = (int)((seed >> 16) % 50);
        }
        assert(cutRod(price, n) == bruteForce(price, n));
    }
}

int main(void) {
    testExampleFromStatement();
    testProgramInput();
    testWholeRodIsBest();
    testEmptyRod();
    testSinglePiece();
    testMatchesBruteForce();
    printf("rod: all tests passed\n");
    return 0;
}
