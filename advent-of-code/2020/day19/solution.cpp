// Day 19: Monster Messages
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <vector>

struct rule {
    char letter = 0;                     // set for a rule like 4: "a"
    std::vector<std::vector<int>> options; // otherwise: alternatives of sequences
};
std::map<int, rule> rules;

// Every position where rule `id` can finish matching `msg` when it starts at
// `from`. Returning all of them handles alternatives and loops without backtracking.
std::set<size_t> match(const std::string &msg, int id, size_t from) {
    const rule &r = rules[id];
    if (r.letter) {
        if (from < msg.size() && msg[from] == r.letter) return {from + 1};
        return {};
    }
    std::set<size_t> ends;
    for (auto &seq : r.options) {
        std::set<size_t> at = {from};
        for (int sub : seq) {
            std::set<size_t> next;
            for (size_t p : at) {
                auto found = match(msg, sub, p);
                next.insert(found.begin(), found.end());
            }
            at = std::move(next);
            if (at.empty()) break;
        }
        ends.insert(at.begin(), at.end());
    }
    return ends;
}

int count_matches(const std::vector<std::string> &messages) {
    int count = 0;
    for (auto &msg : messages) count += match(msg, 0, 0).count(msg.size());
    return count;
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::vector<std::string> messages;
    for (std::string line; std::getline(in, line);) {
        if (line.empty()) continue;
        auto colon = line.find(':');
        if (colon == std::string::npos) {
            messages.push_back(line);
            continue;
        }
        rule &r = rules[std::stoi(line.substr(0, colon))];
        auto quote = line.find('"');
        if (quote != std::string::npos) {
            r.letter = line[quote + 1];
            continue;
        }
        std::istringstream body(line.substr(colon + 1));
        r.options.emplace_back();
        for (std::string token; body >> token;) {
            if (token == "|") r.options.emplace_back();
            else r.options.back().push_back(std::stoi(token));
        }
    }
    std::cout << count_matches(messages) << '\n';
    // Part 2: rules 8 and 11 loop. Neither loop is left-recursive, so the
    // same matcher handles them.
    if (rules.count(42) && rules.count(31)) {
        rules[8].options = {{42}, {42, 8}};
        rules[11].options = {{42, 31}, {42, 11, 31}};
        std::cout << count_matches(messages) << '\n';
    }
}
