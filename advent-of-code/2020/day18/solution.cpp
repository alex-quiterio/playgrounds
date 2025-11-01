// Day 18: Operation Order
#include <fstream>
#include <iostream>
#include <string>

// A small recursive-descent parser. `plus_first` decides precedence: part 1
// gives + and * the same precedence, part 2 makes + bind tighter than *.
struct parser {
    const std::string &s;
    size_t at = 0;
    bool plus_first;

    void skip() {
        while (at < s.size() && s[at] == ' ') at++;
    }

    long term() {
        skip();
        if (s[at] == '(') {
            at++;
            long v = expr();
            skip();
            at++; // ')'
            return v;
        }
        long v = 0;
        while (at < s.size() && isdigit(s[at])) v = v * 10 + (s[at++] - '0');
        return v;
    }

    // Part 2 only: a run of additions, which binds tighter than *.
    long sum() {
        long v = term();
        for (skip(); at < s.size() && s[at] == '+'; skip()) {
            at++;
            v += term();
        }
        return v;
    }

    long expr() {
        long v = plus_first ? sum() : term();
        for (skip(); at < s.size() && (s[at] == '+' || s[at] == '*'); skip()) {
            char op = s[at++];
            long rhs = plus_first ? sum() : term();
            v = op == '+' ? v + rhs : v * rhs;
        }
        return v;
    }
};

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    long same = 0, plus_first = 0;
    for (std::string line; std::getline(in, line);) {
        if (line.empty()) continue;
        same += parser{line, 0, false}.expr();
        plus_first += parser{line, 0, true}.expr();
    }
    std::cout << same << '\n' << plus_first << '\n';
}
