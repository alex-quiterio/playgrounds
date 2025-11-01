// Day 4: Passport Processing
#include <fstream>
#include <iostream>
#include <map>
#include <regex>
#include <sstream>
#include <string>

using passport = std::map<std::string, std::string>;

const char *required[] = {"byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"};

bool complete(const passport &p) {
    for (auto field : required) {
        if (!p.count(field)) return false;
    }
    return true;
}

bool between(const std::string &s, int lo, int hi) {
    int n = std::stoi(s);
    return lo <= n && n <= hi;
}

// Part 2: every required field is present and its value is well formed.
bool valid(const passport &p) {
    static const std::regex year("\\d{4}"), height("(\\d+)(cm|in)"), hair("#[0-9a-f]{6}"),
        eye("amb|blu|brn|gry|grn|hzl|oth"), pid("\\d{9}");
    if (!complete(p)) return false;
    std::smatch m;
    const auto &hgt = p.at("hgt");
    return std::regex_match(p.at("byr"), year) && between(p.at("byr"), 1920, 2002) &&
           std::regex_match(p.at("iyr"), year) && between(p.at("iyr"), 2010, 2020) &&
           std::regex_match(p.at("eyr"), year) && between(p.at("eyr"), 2020, 2030) &&
           std::regex_match(hgt, m, height) &&
           (m[2] == "cm" ? between(m[1], 150, 193) : between(m[1], 59, 76)) &&
           std::regex_match(p.at("hcl"), hair) && std::regex_match(p.at("ecl"), eye) &&
           std::regex_match(p.at("pid"), pid);
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    int complete_count = 0, valid_count = 0;
    passport current;
    auto finish = [&] {
        if (current.empty()) return;
        complete_count += complete(current);
        valid_count += valid(current);
        current.clear();
    };
    // Passports are separated by blank lines; fields are key:value pairs.
    for (std::string line; std::getline(in, line);) {
        if (line.empty()) {
            finish();
            continue;
        }
        std::istringstream fields(line);
        for (std::string field; fields >> field;) {
            auto colon = field.find(':');
            current[field.substr(0, colon)] = field.substr(colon + 1);
        }
    }
    finish();
    std::cout << complete_count << '\n' << valid_count << '\n';
}
