// Day 2: Password Philosophy
#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    int lo, hi, by_count = 0, by_position = 0;
    char dash, letter, colon;
    std::string password;
    while (in >> lo >> dash >> hi >> letter >> colon >> password) {
        // Part 1: the letter appears between lo and hi times.
        auto n = std::count(password.begin(), password.end(), letter);
        by_count += lo <= n && n <= hi;
        // Part 2: exactly one of positions lo and hi (1-based) holds the letter.
        by_position += (password[lo - 1] == letter) != (password[hi - 1] == letter);
    }
    std::cout << by_count << '\n' << by_position << '\n';
}
