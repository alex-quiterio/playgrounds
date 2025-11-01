// Day 12: Rain Risk
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <utility>
#include <vector>

std::vector<std::pair<char, int>> steps;

// Positions are (east, north). Without a waypoint the "waypoint" is the ship's
// heading (1, 0), and N/S/E/W move the ship instead of it.
long navigate(long wx, long wy, bool waypoint) {
    long x = 0, y = 0;
    for (auto [action, n] : steps) {
        long &mx = waypoint ? wx : x, &my = waypoint ? wy : y;
        switch (action) {
        case 'N': my += n; break;
        case 'S': my -= n; break;
        case 'E': mx += n; break;
        case 'W': mx -= n; break;
        case 'F': x += wx * n; y += wy * n; break;
        case 'L':
        case 'R':
            // Turn in steps of 90 degrees; a right turn maps (x, y) to (y, -x).
            for (int turns = (action == 'R' ? n : 360 - n) / 90; turns > 0; turns--) {
                std::swap(wx, wy);
                wy = -wy;
            }
            break;
        }
    }
    return std::labs(x) + std::labs(y);
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    char action;
    int n;
    while (in >> action >> n) steps.emplace_back(action, n);
    std::cout << navigate(1, 0, false) << '\n' << navigate(10, 1, true) << '\n';
}
