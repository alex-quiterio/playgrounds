#!/usr/bin/perl
# Day 11: Monkey in the Middle
use strict;
use warnings;

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my @notes = split /\n\n/, do { local $/; <$in> };
my @monkeys = map {
    my %m;
    @{ $m{items} } = /Starting items: (.*)/ ? split(/, /, $1) : ();
    ($m{op}, $m{arg}) = /new = old (.) (\w+)/;
    ($m{test})  = /divisible by (\d+)/;
    ($m{true})  = /If true: throw to monkey (\d+)/;
    ($m{false}) = /If false: throw to monkey (\d+)/;
    \%m;
} @notes;

# Worry levels only matter modulo every monkey's test, so keep them small.
my $modulus = 1;
$modulus *= $_->{test} for @monkeys;

sub monkey_business {
    my ($rounds, $relief) = @_;
    my @items = map { [@{ $_->{items} }] } @monkeys;
    my @inspected = (0) x @monkeys;
    for (1 .. $rounds) {
        for my $i (0 .. $#monkeys) {
            my $m = $monkeys[$i];
            while (defined(my $worry = shift @{ $items[$i] })) {
                $inspected[$i]++;
                my $arg = $m->{arg} eq 'old' ? $worry : $m->{arg};
                $worry = $m->{op} eq '*' ? $worry * $arg : $worry + $arg;
                $worry = $relief ? int($worry / 3) : $worry % $modulus;
                push @{ $items[ $worry % $m->{test} == 0 ? $m->{true} : $m->{false} ] }, $worry;
            }
        }
    }
    my @top = sort { $b <=> $a } @inspected;
    return $top[0] * $top[1];
}

print monkey_business(20, 1), "\n", monkey_business(10_000, 0), "\n";
