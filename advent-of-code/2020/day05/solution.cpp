// Day 5: Binary Boarding
#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    // A boarding pass is the seat ID in binary: B and R are 1, F and L are 0.
    std::vector<int> ids;
    for (std::string pass; in >> pass;) {
        int id = 0;
        for (char c : pass) id = id * 2 + (c == 'B' || c == 'R');
        ids.push_back(id);
    }
    std::sort(ids.begin(), ids.end());
    std::cout << ids.back() << '\n';
    // Part 2: our seat is the one gap in the otherwise full run of IDs.
    for (size_t i = 1; i < ids.size(); i++) {
        if (ids[i] == ids[i - 1] + 2) {
            std::cout << ids[i] - 1 << '\n';
            break;
        }
    }
}
