#!/usr/bin/perl
# Day 9: Rope Bridge
use strict;
use warnings;

my %step = (R => [1, 0], L => [-1, 0], U => [0, 1], D => [0, -1]);
open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my @moves = map { [/(\w) (\d+)/] } grep { /\S/ } <$in>;

sub sign { $_[0] <=> 0 }

# Positions the tail visits for a rope of `knots` knots.
sub tail_visits {
    my ($knots) = @_;
    my @rope = map { [0, 0] } 1 .. $knots;
    my %visited = ('0,0' => 1);
    for my $move (@moves) {
        my ($dir, $count) = @$move;
        for (1 .. $count) {
            $rope[0][$_] += $step{$dir}[$_] for 0, 1;
            for my $k (1 .. $#rope) {
                my ($dx, $dy) = map { $rope[$k - 1][$_] - $rope[$k][$_] } 0, 1;
                # A knot only moves once it is no longer touching the one ahead.
                next if abs($dx) <= 1 && abs($dy) <= 1;
                $rope[$k][0] += sign($dx);
                $rope[$k][1] += sign($dy);
            }
            $visited{ join ',', @{ $rope[-1] } } = 1;
        }
    }
    return scalar keys %visited;
}

print tail_visits(2), "\n", tail_visits(10), "\n";
