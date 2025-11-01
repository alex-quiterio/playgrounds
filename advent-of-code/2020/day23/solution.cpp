// Day 23: Crab Cups
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

// The circle as a linked list: next[c] is the cup clockwise of cup c.
std::vector<int> play(const std::string &labels, int cups, int moves) {
    std::vector<int> order;
    for (char c : labels) order.push_back(c - '0');
    for (int c = (int)order.size() + 1; c <= cups; c++) order.push_back(c);
    std::vector<int> next(cups + 1);
    for (int i = 0; i < cups; i++) next[order[i]] = order[(i + 1) % cups];

    int current = order[0];
    for (int m = 0; m < moves; m++) {
        int a = next[current], b = next[a], c = next[b];
        int dest = current;
        do dest = dest == 1 ? cups : dest - 1;
        while (dest == a || dest == b || dest == c);
        // Lift out a..c and splice them in right after the destination cup.
        next[current] = next[c];
        next[c] = next[dest];
        next[dest] = a;
        current = next[current];
    }
    return next;
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::string labels;
    in >> labels;

    auto small = play(labels, labels.size(), 100);
    for (int c = small[1]; c != 1; c = small[c]) std::cout << c;
    std::cout << '\n';

    auto big = play(labels, 1000000, 10000000);
    std::cout << (long)big[1] * big[big[1]] << '\n';
}
