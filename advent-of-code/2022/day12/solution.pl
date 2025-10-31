#!/usr/bin/perl
# Day 12: Hill Climbing Algorithm
use strict;
use warnings;

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my @grid = map { [split //] } grep { /\S/ } map { chomp; $_ } <$in>;
my ($rows, $cols) = (scalar @grid, scalar @{ $grid[0] });

my ($start, $end);
for my $r (0 .. $rows - 1) {
    for my $c (0 .. $cols - 1) {
        if    ($grid[$r][$c] eq 'S') { $start = [$r, $c]; $grid[$r][$c] = 'a' }
        elsif ($grid[$r][$c] eq 'E') { $end   = [$r, $c]; $grid[$r][$c] = 'z' }
    }
}

# Breadth-first search downhill from E: a step back is allowed when it climbs
# at most one level going forwards. Returns the distance to every square.
my %dist = ("@$end" => 0);
my @queue = ($end);
while (my $p = shift @queue) {
    my ($r, $c) = @$p;
    for my $d ([-1, 0], [1, 0], [0, -1], [0, 1]) {
        my ($nr, $nc) = ($r + $d->[0], $c + $d->[1]);
        next if $nr < 0 || $nc < 0 || $nr >= $rows || $nc >= $cols;
        next if exists $dist{"$nr $nc"};
        next if ord($grid[$r][$c]) - ord($grid[$nr][$nc]) > 1;
        $dist{"$nr $nc"} = $dist{"$r $c"} + 1;
        push @queue, [$nr, $nc];
    }
}

my ($best) = sort { $a <=> $b } map { $dist{$_} }
             grep { my ($r, $c) = split; $grid[$r][$c] eq 'a' } keys %dist;
print $dist{"@$start"}, "\n$best\n";
