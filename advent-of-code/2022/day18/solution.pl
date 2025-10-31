#!/usr/bin/perl
# Day 18: Boiling Boulders
use strict;
use warnings;
use List::Util qw(min max);

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my %lava = map { chomp; $_ => 1 } grep { /\d/ } <$in>;
my @sides = ([1, 0, 0], [-1, 0, 0], [0, 1, 0], [0, -1, 0], [0, 0, 1], [0, 0, -1]);
sub neighbours { my @c = split /,/, shift; map { my $d = $_; join ',', map { $c[$_] + $d->[$_] } 0 .. 2 } @sides }

# Part 1: every cube face that does not touch another cube.
my $surface = 0;
for my $cube (keys %lava) {
    $surface += grep { !$lava{$_} } neighbours($cube);
}

# Part 2: only faces the outside water can reach. Flood the box around the droplet.
my @all = map { [split /,/] } keys %lava;
my @low  = map { my $i = $_; min(map { $_->[$i] } @all) - 1 } 0 .. 2;
my @high = map { my $i = $_; max(map { $_->[$i] } @all) + 1 } 0 .. 2;
my $start = join ',', @low;
my %water = ($start => 1);
my @queue = ($start);
my $exterior = 0;
while (defined(my $cell = shift @queue)) {
    for my $next (neighbours($cell)) {
        my @c = split /,/, $next;
        next if grep { $c[$_] < $low[$_] || $c[$_] > $high[$_] } 0 .. 2;
        if ($lava{$next}) { $exterior++; next }
        next if $water{$next}++;
        push @queue, $next;
    }
}
print "$surface\n$exterior\n";
