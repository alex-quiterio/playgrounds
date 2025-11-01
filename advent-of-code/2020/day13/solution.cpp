// Day 13: Shuttle Search
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    long earliest;
    std::string schedule;
    in >> earliest >> schedule;
    std::vector<std::pair<long, long>> buses; // (offset in the list, bus ID)
    std::istringstream list(schedule);
    long offset = 0;
    for (std::string field; std::getline(list, field, ','); offset++)
        if (field != "x") buses.emplace_back(offset, std::stol(field));

    // Part 1: the bus that leaves soonest after we arrive.
    long best_wait = -1, best_bus = 0;
    for (auto [_, id] : buses) {
        long wait = (id - earliest % id) % id;
        if (best_wait < 0 || wait < best_wait) best_wait = wait, best_bus = id;
    }
    std::cout << best_wait * best_bus << '\n';

    // Part 2: the bus IDs are coprime, so match them one at a time: once t fits
    // the buses so far, stepping by their product keeps them fitting.
    long t = 0, step = 1;
    for (auto [i, id] : buses) {
        while ((t + i) % id != 0) t += step;
        step *= id;
    }
    std::cout << t << '\n';
}
