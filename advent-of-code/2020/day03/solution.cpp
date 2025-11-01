// Day 3: Toboggan Trajectory
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

std::vector<std::string> map;

// Trees hit going right `dx`, down `dy` each step; the map repeats to the right.
long trees(int dx, int dy) {
    long hit = 0;
    for (size_t y = 0, x = 0; y < map.size(); y += dy, x += dx) {
        hit += map[y][x % map[y].size()] == '#';
    }
    return hit;
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    for (std::string line; std::getline(in, line);) {
        if (!line.empty()) map.push_back(line);
    }
    std::cout << trees(3, 1) << '\n';
    std::cout << trees(1, 1) * trees(3, 1) * trees(5, 1) * trees(7, 1) * trees(1, 2) << '\n';
}
