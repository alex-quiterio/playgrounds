// Day 22: Crab Combat
#include <deque>
#include <fstream>
#include <iostream>
#include <set>
#include <string>
#include <vector>

using deck = std::deque<int>;

long score(const deck &d) {
    long total = 0;
    for (size_t i = 0; i < d.size(); i++) total += d[i] * (long)(d.size() - i);
    return total;
}

// Plays a game and returns the winner (0 or 1), leaving the final decks in `d`.
// Recursive Combat ends a game in player 1's favour when a position repeats, and
// settles a round by a sub-game when both players hold enough cards.
int play(deck d[2], bool recursive) {
    std::set<std::pair<deck, deck>> seen;
    while (!d[0].empty() && !d[1].empty()) {
        if (recursive && !seen.insert({d[0], d[1]}).second) return 0;
        int a = d[0].front(), b = d[1].front();
        d[0].pop_front();
        d[1].pop_front();
        int winner;
        if (recursive && (int)d[0].size() >= a && (int)d[1].size() >= b) {
            deck sub[2] = {deck(d[0].begin(), d[0].begin() + a), deck(d[1].begin(), d[1].begin() + b)};
            winner = play(sub, true);
        } else {
            winner = b > a;
        }
        d[winner].push_back(winner == 0 ? a : b);
        d[winner].push_back(winner == 0 ? b : a);
    }
    return d[0].empty();
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    deck start[2];
    int player = -1;
    for (std::string line; std::getline(in, line);) {
        if (line.rfind("Player", 0) == 0) player++;
        else if (!line.empty()) start[player].push_back(std::stoi(line));
    }
    for (bool recursive : {false, true}) {
        deck d[2] = {start[0], start[1]};
        std::cout << score(d[play(d, recursive)]) << '\n';
    }
}
