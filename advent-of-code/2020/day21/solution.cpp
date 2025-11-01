// Day 21: Allergen Assessment
#include <algorithm>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <vector>

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::vector<std::vector<std::string>> foods;
    // An allergen's ingredient must appear in every food that lists the allergen.
    std::map<std::string, std::set<std::string>> could_be;
    for (std::string line; std::getline(in, line);) {
        if (line.empty()) continue;
        auto paren = line.find(" (contains ");
        std::istringstream words(line.substr(0, paren));
        std::set<std::string> ingredients;
        foods.emplace_back();
        for (std::string w; words >> w;) ingredients.insert(w), foods.back().push_back(w);
        std::istringstream allergens(line.substr(paren + 11, line.size() - paren - 12));
        for (std::string a; std::getline(allergens >> std::ws, a, ',');) {
            if (!could_be.count(a)) {
                could_be[a] = ingredients;
                continue;
            }
            std::set<std::string> both;
            std::set_intersection(could_be[a].begin(), could_be[a].end(), ingredients.begin(),
                                  ingredients.end(), std::inserter(both, both.begin()));
            could_be[a] = both;
        }
    }

    // Part 1: ingredients no allergen could be in, counted every time they appear.
    std::set<std::string> suspect;
    for (auto &[_, set] : could_be) suspect.insert(set.begin(), set.end());
    int safe = 0;
    for (auto &food : foods)
        for (auto &w : food) safe += !suspect.count(w);
    std::cout << safe << '\n';

    // Part 2: settle allergens one at a time, starting with one that has a
    // single candidate, and remove that ingredient from the others.
    std::map<std::string, std::string> dangerous; // allergen -> ingredient (sorted by allergen)
    while (dangerous.size() < could_be.size()) {
        for (auto &[a, set] : could_be) {
            if (dangerous.count(a) || set.size() != 1) continue;
            std::string ingredient = *set.begin();
            dangerous[a] = ingredient;
            for (auto &[_, other] : could_be) other.erase(ingredient);
        }
    }
    std::string list;
    for (auto &[_, ingredient] : dangerous) list += (list.empty() ? "" : ",") + ingredient;
    std::cout << list << '\n';
}
