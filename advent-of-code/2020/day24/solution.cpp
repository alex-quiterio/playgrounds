// Day 24: Lobby Layout
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <utility>

// Hex tiles in axial coordinates (q, r): e/w change q, ne/sw change r,
// and nw/se change both.
using tile = std::pair<int, int>;
const tile directions[6] = {{1, 0}, {-1, 0}, {1, -1}, {0, -1}, {0, 1}, {-1, 1}};

tile walk(const std::string &path) {
    int q = 0, r = 0;
    for (size_t i = 0; i < path.size(); i++) {
        char c = path[i];
        if (c == 'e') q++;
        else if (c == 'w') q--;
        else {
            char d = path[++i];
            if (c == 'n' && d == 'e') q++, r--;
            else if (c == 'n') r--;
            else if (d == 'w') q--, r++;
            else r++;
        }
    }
    return {q, r};
}

// One day: black tiles with 1 or 2 black neighbours stay black, and white
// tiles with exactly 2 black neighbours turn black.
std::set<tile> day(const std::set<tile> &black) {
    std::map<tile, int> neighbours;
    for (auto [q, r] : black)
        for (auto [dq, dr] : directions) neighbours[{q + dq, r + dr}]++;
    std::set<tile> next;
    for (auto [t, n] : neighbours)
        if (n == 2 || (n == 1 && black.count(t))) next.insert(t);
    return next;
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::set<tile> black;
    for (std::string line; in >> line;) {
        auto t = walk(line);
        if (!black.erase(t)) black.insert(t);
    }
    std::cout << black.size() << '\n';
    for (int d = 0; d < 100; d++) black = day(black);
    std::cout << black.size() << '\n';
}
