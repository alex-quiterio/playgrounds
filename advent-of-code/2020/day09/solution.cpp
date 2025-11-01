// Day 9: Encoding Error
#include <algorithm>
#include <fstream>
#include <iostream>
#include <vector>

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::vector<long> xs;
    for (long x; in >> x;) xs.push_back(x);
    // The puzzle's example uses a preamble of 5; real inputs use 25.
    size_t preamble = xs.size() < 100 ? 5 : 25;

    // Part 1: the first number that is not the sum of two of the previous ones.
    long invalid = 0;
    for (size_t i = preamble; i < xs.size() && !invalid; i++) {
        bool found = false;
        for (size_t a = i - preamble; a < i && !found; a++)
            for (size_t b = a + 1; b < i && !found; b++)
                found = xs[a] != xs[b] && xs[a] + xs[b] == xs[i];
        if (!found) invalid = xs[i];
    }
    std::cout << invalid << '\n';

    // Part 2: a contiguous run of at least two numbers adding up to it.
    // All numbers are positive, so a sliding window finds it.
    size_t lo = 0, hi = 0;
    long sum = 0;
    while (sum != invalid || hi - lo < 2) {
        if (sum < invalid || hi - lo < 2) sum += xs[hi++];
        else sum -= xs[lo++];
    }
    auto [min, max] = std::minmax_element(xs.begin() + lo, xs.begin() + hi);
    std::cout << *min + *max << '\n';
}
