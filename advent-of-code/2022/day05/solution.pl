#!/usr/bin/perl
# Day 5: Supply Stacks
use strict;
use warnings;

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my ($drawing, $procedure) = split /\n\n/, do { local $/; <$in> };

# Read the drawing bottom-up: the crate letters sit every 4 columns.
my @rows = split /\n/, $drawing;
pop @rows; # the stack numbers
my @stacks;
for my $row (reverse @rows) {
    for (my $i = 1; $i < length $row; $i += 4) {
        my $crate = substr $row, $i, 1;
        push @{ $stacks[($i - 1) / 4] }, $crate if $crate =~ /[A-Z]/;
    }
}

# CrateMover 9000 moves one crate at a time; 9001 moves them all at once.
sub rearrange {
    my ($all_at_once, @stacks) = @_;
    @stacks = map { [@$_] } @stacks; # copy
    for my $step (split /\n/, $procedure) {
        my ($count, $from, $to) = $step =~ /move (\d+) from (\d+) to (\d+)/ or next;
        my @moved = splice @{ $stacks[$from - 1] }, -$count;
        @moved = reverse @moved unless $all_at_once;
        push @{ $stacks[$to - 1] }, @moved;
    }
    return join '', map { $_->[-1] // '' } @stacks;
}

print rearrange(0, @stacks), "\n", rearrange(1, @stacks), "\n";
