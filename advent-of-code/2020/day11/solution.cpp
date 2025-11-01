// Day 11: Seating System
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

using grid = std::vector<std::string>;

// Occupied seats seen from (r, c): the next seat in each of the 8 directions,
// either right next to it (`far` false) or as far as the floor lets you see.
int occupied_around(const grid &g, int r, int c, bool far) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++)
        for (int dc = -1; dc <= 1; dc++) {
            if (!dr && !dc) continue;
            int y = r + dr, x = c + dc;
            while (far && y >= 0 && y < (int)g.size() && x >= 0 && x < (int)g[y].size() && g[y][x] == '.') {
                y += dr;
                x += dc;
            }
            count += y >= 0 && y < (int)g.size() && x >= 0 && x < (int)g[y].size() && g[y][x] == '#';
        }
    return count;
}

// Applies the seating rules until nothing changes; returns the occupied seats.
int settle(grid g, bool far, int tolerance) {
    for (bool changed = true; changed;) {
        changed = false;
        grid next = g;
        for (int r = 0; r < (int)g.size(); r++)
            for (int c = 0; c < (int)g[r].size(); c++) {
                if (g[r][c] == '.') continue;
                int n = occupied_around(g, r, c, far);
                if (g[r][c] == 'L' && n == 0) next[r][c] = '#';
                if (g[r][c] == '#' && n >= tolerance) next[r][c] = 'L';
                changed |= next[r][c] != g[r][c];
            }
        g = next;
    }
    int count = 0;
    for (auto &row : g)
        for (char c : row) count += c == '#';
    return count;
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    grid seats;
    for (std::string line; std::getline(in, line);)
        if (!line.empty()) seats.push_back(line);
    std::cout << settle(seats, false, 4) << '\n' << settle(seats, true, 5) << '\n';
}
