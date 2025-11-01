// Day 17: Conway Cubes
#include <array>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <string>

using cube = std::array<int, 4>; // x, y, z, w

// Runs six cycles in 3 or 4 dimensions; returns how many cubes stay active.
size_t boot(std::set<cube> active, int dims) {
    for (int cycle = 0; cycle < 6; cycle++) {
        std::map<cube, int> neighbours;
        for (auto &c : active)
            for (int dx = -1; dx <= 1; dx++)
                for (int dy = -1; dy <= 1; dy++)
                    for (int dz = -1; dz <= 1; dz++)
                        for (int dw = (dims == 4 ? -1 : 0); dw <= (dims == 4 ? 1 : 0); dw++)
                            if (dx || dy || dz || dw) neighbours[{c[0] + dx, c[1] + dy, c[2] + dz, c[3] + dw}]++;
        std::set<cube> next;
        for (auto &[c, n] : neighbours)
            if (n == 3 || (n == 2 && active.count(c))) next.insert(c);
        active = std::move(next);
    }
    return active.size();
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::set<cube> active;
    int y = 0;
    for (std::string line; std::getline(in, line); y++)
        for (int x = 0; x < (int)line.size(); x++)
            if (line[x] == '#') active.insert({x, y, 0, 0});
    std::cout << boot(active, 3) << '\n' << boot(active, 4) << '\n';
}
