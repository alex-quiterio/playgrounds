// Day 8: Handheld Halting
#include <fstream>
#include <iostream>
#include <string>
#include <utility>
#include <vector>

struct instruction {
    std::string op;
    int arg;
};
std::vector<instruction> program;

// Runs the program; returns whether it ran off the end, and the accumulator
// when it either ends or is about to run an instruction a second time.
std::pair<bool, int> run() {
    std::vector<bool> seen(program.size());
    int acc = 0;
    size_t pc = 0;
    while (pc < program.size() && !seen[pc]) {
        seen[pc] = true;
        auto &[op, arg] = program[pc];
        if (op == "acc") acc += arg;
        pc += op == "jmp" ? arg : 1;
    }
    return {pc == program.size(), acc};
}

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    std::string op;
    int arg;
    while (in >> op >> arg) program.push_back({op, arg});

    std::cout << run().second << '\n';
    // Part 2: exactly one jmp should be a nop (or the other way round).
    for (auto &ins : program) {
        if (ins.op == "acc") continue;
        auto original = ins.op;
        ins.op = original == "jmp" ? "nop" : "jmp";
        auto [ends, acc] = run();
        ins.op = original;
        if (ends) {
            std::cout << acc << '\n';
            break;
        }
    }
}
