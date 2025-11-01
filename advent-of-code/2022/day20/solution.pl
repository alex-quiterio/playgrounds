#!/usr/bin/perl
# Day 20: Grove Positioning System
use strict;
use warnings;

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my @numbers = map { chomp; $_ } grep { /\S/ } <$in>;

# Mix a list of indexes into @numbers, so equal values stay distinct.
sub decrypt {
    my ($key, $rounds) = @_;
    my @values = map { $_ * $key } @numbers;
    my $n = @values;
    my @order = (0 .. $n - 1);
    for (1 .. $rounds) {
        for my $i (0 .. $n - 1) {
            my ($at) = grep { $order[$_] == $i } 0 .. $n - 1;
            splice @order, $at, 1;
            # Moving past the other n - 1 numbers wraps every n - 1 steps.
            my $to = ($at + $values[$i]) % ($n - 1);
            splice @order, $to, 0, $i;
        }
    }
    my @mixed = map { $values[$_] } @order;
    my ($zero) = grep { $mixed[$_] == 0 } 0 .. $n - 1;
    my $sum = 0;
    $sum += $mixed[($zero + $_) % $n] for 1000, 2000, 3000;
    return $sum;
}

print decrypt(1, 1), "\n";
print decrypt(811589153, 10), "\n";
