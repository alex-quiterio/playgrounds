// Day 7: Handy Haversacks
#include <fstream>
#include <iostream>
#include <map>
#include <regex>
#include <string>
#include <vector>

// rules["light red"] = {{1, "bright white"}, {2, "muted yellow"}}
std::map<std::string, std::vector<std::pair<long, std::string>>> rules;

bool holds_gold(const std::string &bag) {
    static std::map<std::string, bool> memo;
    if (auto it = memo.find(bag); it != memo.end()) return it->second;
    bool found = false;
    for (auto &[n, inner] : rules[bag]) {
        if (inner == "shiny gold" || holds_gold(inner)) found = true;
    }
    return memo[bag] = found;
}

// How many bags are inside one `bag`.
long inside(const std::string &bag) {
    long total = 0;
    for (auto &[n, inner] : rules[bag]) total += n * (1 + inside(inner));
    return total;
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    static const std::regex outer("^(\\w+ \\w+) bags contain"), content("(\\d+) (\\w+ \\w+) bags?");
    for (std::string line; std::getline(in, line);) {
        std::smatch m;
        if (!std::regex_search(line, m, outer)) continue;
        auto &list = rules[m[1]];
        for (std::sregex_iterator it(line.begin(), line.end(), content), end; it != end; ++it) {
            list.emplace_back(std::stol((*it)[1]), (*it)[2]);
        }
    }
    int count = 0;
    for (auto &[bag, _] : rules) count += holds_gold(bag);
    std::cout << count << '\n' << inside("shiny gold") << '\n';
}
