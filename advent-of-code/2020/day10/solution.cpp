// Day 10: Adapter Array
#include <algorithm>
#include <fstream>
#include <iostream>
#include <vector>

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::vector<int> joltage = {0}; // the charging outlet
    for (int j; in >> j;) joltage.push_back(j);
    std::sort(joltage.begin(), joltage.end());
    joltage.push_back(joltage.back() + 3); // the device's built-in adapter

    int diff[4] = {0};
    for (size_t i = 1; i < joltage.size(); i++) diff[joltage[i] - joltage[i - 1]]++;
    std::cout << diff[1] * diff[3] << '\n';

    // Part 2: ways[i] counts the chains from the outlet to adapter i.
    std::vector<long> ways(joltage.size());
    ways[0] = 1;
    for (size_t i = 1; i < joltage.size(); i++)
        for (size_t k = i; k-- > 0 && joltage[i] - joltage[k] <= 3;) ways[i] += ways[k];
    std::cout << ways.back() << '\n';
}
