// Day 15: Rambunctious Recitation
#include <cstdint>
#include <fstream>
#include <iostream>
#include <vector>

std::vector<uint32_t> start;

// The number spoken on turn `turns`. last[n] is the turn n was last spoken
// before the previous one (0 when never), so each turn is a single lookup.
uint32_t play(uint32_t turns) {
    std::vector<uint32_t> last(turns, 0);
    for (uint32_t i = 0; i + 1 < start.size(); i++) last[start[i]] = i + 1;
    uint32_t spoken = start.back();
    for (uint32_t turn = start.size(); turn < turns; turn++) {
        uint32_t seen = last[spoken];
        last[spoken] = turn;
        spoken = seen ? turn - seen : 0;
    }
    return spoken;
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    for (uint32_t n; in >> n;) {
        start.push_back(n);
        in.ignore(1); // the comma
    }
    std::cout << play(2020) << '\n' << play(30000000) << '\n';
}
