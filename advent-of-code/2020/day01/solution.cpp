// Day 1: Report Repair
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
    std::vector<long> entries;
    for (long x; in >> x;) entries.push_back(x);
    std::sort(entries.begin(), entries.end());
    auto present = [&](long x) { return std::binary_search(entries.begin(), entries.end(), x); };

    // Two entries: for each a, look up 2020 - a among the larger entries.
    for (size_t i = 0; i < entries.size(); i++) {
        long b = 2020 - entries[i];
        if (b > entries[i] && present(b)) {
            std::cout << entries[i] * b << '\n';
            break;
        }
    }
    // Three entries a < b < c: try each pair and look up the third.
    for (size_t i = 0; i < entries.size(); i++)
        for (size_t j = i + 1; j < entries.size(); j++) {
            long c = 2020 - entries[i] - entries[j];
            if (c > entries[j] && present(c)) {
                std::cout << entries[i] * entries[j] * c << '\n';
                return 0;
            }
        }
}
