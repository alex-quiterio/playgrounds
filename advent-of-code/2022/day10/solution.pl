#!/usr/bin/perl
# Day 10: Cathode-Ray Tube
use strict;
use warnings;

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my ($x, $cycle, $strength, $screen) = (1, 0, 0, '');

# Each cycle: sample the signal, then draw one pixel of the 40-wide CRT.
sub tick {
    $cycle++;
    $strength += $cycle * $x if ($cycle - 20) % 40 == 0;
    my $column = ($cycle - 1) % 40;
    $screen .= abs($column - $x) <= 1 ? '#' : '.';
    $screen .= "\n" if $column == 39;
}

while (<$in>) {
    if (/^noop/)            { tick() }
    elsif (/^addx (-?\d+)/) { tick(); tick(); $x += $1 }
}

# Advent of Code's 4x6 capital letters, so part 2 can be submitted as text.
my %font = (
    '.##.#..##..######..##..#' => 'A', '###.#..####.#..##..####.' => 'B',
    '.##.#..##...#...#..#.##.' => 'C', '#####...###.#...#...####' => 'E',
    '#####...###.#...#...#...' => 'F', '.##.#..##...#.###..#.###' => 'G',
    '#..##..######..##..##..#' => 'H', '.###..#...#...#...#..###' => 'I',
    '..##...#...#...##..#.##.' => 'J', '#..##.#.##..#.#.#.#.#..#' => 'K',
    '#...#...#...#...#...####' => 'L', '.##.#..##..##..##..#.##.' => 'O',
    '###.#..##..####.#...#...' => 'P', '###.#..##..####.#.#.#..#' => 'R',
    '.####...#....##....####.' => 'S', '#..##..##..##..##..#.##.' => 'U',
    '####...#..#..#..#...####' => 'Z',
);
my @rows = split /\n/, $screen;
my $letters = join '', map {
    my $i = $_;
    $font{ join '', map { substr($_, 5 * $i, 4) } @rows[0 .. 5] } // '?';
} 0 .. 7;

print "$strength\n$letters\n";
print STDERR $screen if $letters =~ /\?/; # show the picture when it is not letters
