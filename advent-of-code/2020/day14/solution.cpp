// Day 14: Docking Data
#include <cstdint>
#include <fstream>
#include <iostream>
#include <map>
#include <string>
#include <vector>

struct write {
    std::string mask; // 36 characters, most significant bit first
    uint64_t address, value;
};

// Calls `store` with every address an X in the mask can float to.
template <typename F> void floating(const std::string &mask, uint64_t address, int bit, F store) {
    if (bit == 36) {
        store(address);
        return;
    }
    uint64_t one = 1ULL << (35 - bit);
    switch (mask[bit]) {
    case '0': floating(mask, address, bit + 1, store); break;
    case '1': floating(mask, address | one, bit + 1, store); break;
    case 'X':
        floating(mask, address & ~one, bit + 1, store);
        floating(mask, address | one, bit + 1, store);
        break;
    }
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::vector<write> writes;
    std::string mask;
    for (std::string line; std::getline(in, line);) {
        if (line.rfind("mask = ", 0) == 0) {
            mask = line.substr(7);
        } else if (line.rfind("mem[", 0) == 0) {
            auto close = line.find(']');
            writes.push_back({mask, std::stoull(line.substr(4, close - 4)), std::stoull(line.substr(close + 4))});
        }
    }

    // Part 1: the mask overwrites bits of the value.
    std::map<uint64_t, uint64_t> memory;
    for (auto &w : writes) {
        uint64_t value = w.value;
        for (int bit = 0; bit < 36; bit++) {
            uint64_t one = 1ULL << (35 - bit);
            if (w.mask[bit] == '0') value &= ~one;
            if (w.mask[bit] == '1') value |= one;
        }
        memory[w.address] = value;
    }
    uint64_t sum = 0;
    for (auto &[_, v] : memory) sum += v;
    std::cout << sum << '\n';

    // Part 2: the mask decodes the address instead, and X bits take both values.
    // (The part 1 example has too many X bits for this, so skip it there.)
    memory.clear();
    for (auto &w : writes) {
        int xs = 0;
        for (char c : w.mask) xs += c == 'X';
        if (xs > 12) return 0;
        floating(w.mask, w.address, 0, [&](uint64_t a) { memory[a] = w.value; });
    }
    sum = 0;
    for (auto &[_, v] : memory) sum += v;
    std::cout << sum << '\n';
}
