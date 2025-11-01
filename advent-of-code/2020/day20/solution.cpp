// Day 20: Jurassic Jigsaw
#include <fstream>
#include <iostream>
#include <map>
#include <string>
#include <vector>

using image = std::vector<std::string>;

image rotate(const image &g) { // a quarter turn clockwise
    size_t n = g.size();
    image r(g[0].size(), std::string(n, ' '));
    for (size_t y = 0; y < n; y++)
        for (size_t x = 0; x < g[y].size(); x++) r[x][n - 1 - y] = g[y][x];
    return r;
}

image flip(image g) {
    for (auto &row : g) row = std::string(row.rbegin(), row.rend());
    return g;
}

// All 8 ways a square can be laid down: 4 rotations, each also flipped.
std::vector<image> orientations(image g) {
    std::vector<image> all;
    for (int i = 0; i < 4; i++, g = rotate(g)) {
        all.push_back(g);
        all.push_back(flip(g));
    }
    return all;
}

std::string left(const image &g) {
    std::string s;
    for (auto &row : g) s += row.front();
    return s;
}
std::string right(const image &g) {
    std::string s;
    for (auto &row : g) s += row.back();
    return s;
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::map<long, image> tiles;
    long id = 0;
    for (std::string line; std::getline(in, line);) {
        if (line.rfind("Tile ", 0) == 0) id = std::stol(line.substr(5));
        else if (!line.empty()) tiles[id].push_back(line);
    }

    // How many tiles have each edge (read either way round). Edges in the
    // input are unique, so an edge seen once lies on the border of the picture.
    std::map<std::string, int> edge_count;
    for (auto &[_, t] : tiles)
        for (auto &o : orientations(t)) edge_count[o[0]]++;
    // Across a tile's 8 orientations each of its edges is the top edge once
    // each way round, so a border edge is counted once and a shared edge twice.
    auto outer = [&](const std::string &e) { return edge_count[e] == 1; };

    long corners = 1, corner = 0;
    for (auto &[tid, t] : tiles) {
        int border = 0;
        for (auto &o : {t[0], t.back(), left(t), right(t)}) border += outer(o);
        if (border == 2) corners *= tid, corner = tid;
    }
    std::cout << corners << '\n';

    // Part 2: lay out the picture row by row. Start from a corner turned so its
    // border edges face up and left; every next tile must fit its neighbours.
    size_t side = 0;
    while (side * side < tiles.size()) side++;
    std::vector<std::vector<image>> grid(side, std::vector<image>(side));
    std::map<long, bool> used;
    for (auto &o : orientations(tiles[corner]))
        if (outer(o[0]) && outer(left(o))) {
            grid[0][0] = o;
            break;
        }
    used[corner] = true;
    for (size_t r = 0; r < side; r++)
        for (size_t c = 0; c < side; c++) {
            if (r == 0 && c == 0) continue;
            bool placed = false;
            for (auto &[tid, t] : tiles) {
                if (used[tid]) continue;
                for (auto &o : orientations(t)) {
                    bool fits = c > 0 ? left(o) == right(grid[r][c - 1]) : outer(left(o));
                    fits = fits && (r > 0 ? o[0] == grid[r - 1][c].back() : outer(o[0]));
                    if (fits) {
                        grid[r][c] = o;
                        used[tid] = placed = true;
                        break;
                    }
                }
                if (placed) break;
            }
        }

    // Drop each tile's border and join the insides into one picture.
    image picture;
    for (size_t r = 0; r < side; r++) {
        size_t inner = grid[r][0].size() - 2;
        for (size_t y = 1; y <= inner; y++) {
            std::string row;
            for (size_t c = 0; c < side; c++) row += grid[r][c][y].substr(1, inner);
            picture.push_back(row);
        }
    }

    const image monster = {
        "                  # ",
        "#    ##    ##    ###",
        " #  #  #  #  #  #   ",
    };
    // Look for sea monsters in every orientation; the right one has some.
    for (auto &p : orientations(picture)) {
        image marked = p;
        bool found = false;
        for (size_t y = 0; y + monster.size() <= p.size(); y++)
            for (size_t x = 0; x + monster[0].size() <= p[y].size(); x++) {
                bool here = true;
                for (size_t my = 0; my < monster.size() && here; my++)
                    for (size_t mx = 0; mx < monster[my].size() && here; mx++)
                        here = monster[my][mx] != '#' || p[y + my][x + mx] == '#';
                if (!here) continue;
                found = true;
                for (size_t my = 0; my < monster.size(); my++)
                    for (size_t mx = 0; mx < monster[my].size(); mx++)
                        if (monster[my][mx] == '#') marked[y + my][x + mx] = 'O';
            }
        if (!found) continue;
        int rough = 0;
        for (auto &row : marked)
            for (char ch : row) rough += ch == '#';
        std::cout << rough << '\n';
        break;
    }
}
