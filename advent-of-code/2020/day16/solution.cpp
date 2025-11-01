// Day 16: Ticket Translation
#include <fstream>
#include <iostream>
#include <regex>
#include <sstream>
#include <string>
#include <vector>

struct field {
    std::string name;
    int lo1, hi1, lo2, hi2;
    bool allows(int v) const { return (lo1 <= v && v <= hi1) || (lo2 <= v && v <= hi2); }
};

std::vector<int> numbers(const std::string &line) {
    std::vector<int> out;
    std::istringstream in(line);
    for (std::string n; std::getline(in, n, ',');) out.push_back(std::stoi(n));
    return out;
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    static const std::regex rule("^([^:]+): (\\d+)-(\\d+) or (\\d+)-(\\d+)$");
    std::vector<field> fields;
    std::vector<int> mine;
    std::vector<std::vector<int>> nearby;
    int section = 0; // 0 rules, 1 your ticket, 2 nearby tickets
    for (std::string line; std::getline(in, line);) {
        std::smatch m;
        if (line.empty()) continue;
        if (line == "your ticket:") section = 1;
        else if (line == "nearby tickets:") section = 2;
        else if (section == 0 && std::regex_match(line, m, rule))
            fields.push_back({m[1], std::stoi(m[2]), std::stoi(m[3]), std::stoi(m[4]), std::stoi(m[5])});
        else if (section == 1) mine = numbers(line);
        else if (section == 2) nearby.push_back(numbers(line));
    }

    // Part 1: values no field allows; tickets with one are thrown away.
    long error_rate = 0;
    std::vector<std::vector<int>> valid;
    for (auto &ticket : nearby) {
        bool ok = true;
        for (int v : ticket) {
            bool any = false;
            for (auto &f : fields) any |= f.allows(v);
            if (!any) error_rate += v, ok = false;
        }
        if (ok) valid.push_back(ticket);
    }
    std::cout << error_rate << '\n';

    // Part 2: possible[f][p] while every valid ticket's value at p fits field f.
    // Then repeatedly settle a field that has only one position left.
    size_t n = fields.size();
    std::vector<std::vector<bool>> possible(n, std::vector<bool>(n, true));
    for (auto &ticket : valid)
        for (size_t f = 0; f < n; f++)
            for (size_t p = 0; p < n; p++)
                if (!fields[f].allows(ticket[p])) possible[f][p] = false;
    std::vector<int> position(n, -1);
    for (size_t settled = 0; settled < n; settled++) {
        for (size_t f = 0; f < n; f++) {
            if (position[f] >= 0) continue;
            int count = 0, last = -1;
            for (size_t p = 0; p < n; p++)
                if (possible[f][p]) count++, last = p;
            if (count != 1) continue;
            position[f] = last;
            for (size_t g = 0; g < n; g++) possible[g][last] = false;
            break;
        }
    }
    long product = 1;
    for (size_t f = 0; f < n; f++)
        if (fields[f].name.rfind("departure", 0) == 0) product *= mine[position[f]];
    std::cout << product << '\n';
}
