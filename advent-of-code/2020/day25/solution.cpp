// Day 25: Combo Breaker
#include <fstream>
#include <iostream>

const long modulus = 20201227;

int main(int argc, char **argv) {
    std::ifstream in(argc > 1 ? argv[1] : "");
    if (!in) {
        std::cerr << "usage: " << argv[0] << " INPUT\n";
        return 1;
    }
    long card, door;
    in >> card >> door;
    // The card's public key is 7^loop mod 20201227: find the loop size by
    // stepping through powers of 7, then raise the door's key to that power.
    long loop = 0;
    for (long value = 1; value != card; loop++) value = value * 7 % modulus;
    long key = 1;
    for (long i = 0; i < loop; i++) key = key * door % modulus;
    std::cout << key << '\n';
}
