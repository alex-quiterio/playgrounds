// Day 6: Custom Customs
#include <bitset>
#include <fstream>
#include <iostream>
#include <string>

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    // Each person's answers as a set of 26 bits; a group is the union (anyone)
    // or the intersection (everyone) of its people.
    size_t anyone_total = 0, everyone_total = 0;
    std::bitset<26> anyone, everyone;
    bool in_group = false;
    auto finish = [&] {
        if (!in_group) return;
        anyone_total += anyone.count();
        everyone_total += everyone.count();
        anyone.reset();
        in_group = false;
    };
    for (std::string line; std::getline(in, line);) {
        if (line.empty()) {
            finish();
            continue;
        }
        std::bitset<26> person;
        for (char c : line) person.set(c - 'a');
        everyone = in_group ? everyone & person : person;
        anyone |= person;
        in_group = true;
    }
    finish();
    std::cout << anyone_total << '\n' << everyone_total << '\n';
}
