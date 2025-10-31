#!/usr/bin/perl
# Day 13: Distress Signal
use strict;
use warnings;

# Parses a packet like [1,[2,[3]],4] into nested array references.
sub parse {
    my ($text) = @_;
    my @stack = ([]);
    while ($text =~ /(\[|\]|\d+)/g) {
        if    ($1 eq '[') { my $list = []; push @{ $stack[-1] }, $list; push @stack, $list }
        elsif ($1 eq ']') { pop @stack }
        else              { push @{ $stack[-1] }, $1 + 0 }
    }
    return $stack[0][0];
}

# Packet order: -1 if $a comes first, 1 if $b does, 0 if they are equal.
sub compare {
    my ($a, $b) = @_;
    return $a <=> $b if !ref $a && !ref $b;
    $a = [$a] unless ref $a;
    $b = [$b] unless ref $b;
    for my $i (0 .. ($#$a < $#$b ? $#$a : $#$b)) {
        my $order = compare($a->[$i], $b->[$i]);
        return $order if $order;
    }
    return @$a <=> @$b;
}

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my @packets = map { parse($_) } grep { /\S/ } <$in>;

my $right_order = 0;
for (my $i = 0; $i < @packets; $i += 2) {
    $right_order += $i / 2 + 1 if compare($packets[$i], $packets[$i + 1]) < 0;
}

my @dividers = (parse('[[2]]'), parse('[[6]]'));
my @sorted = sort { compare($a, $b) } @packets, @dividers;
my $key = 1;
for my $i (0 .. $#sorted) {
    $key *= $i + 1 if grep { $sorted[$i] == $_ } @dividers;
}
print "$right_order\n$key\n";
