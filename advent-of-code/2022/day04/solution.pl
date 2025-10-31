#!/usr/bin/perl
# Day 4: Camp Cleanup
use strict;
use warnings;

my ($contained, $overlapping) = (0, 0);
open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
while (<$in>) {
    my ($a1, $a2, $b1, $b2) = /(\d+)-(\d+),(\d+)-(\d+)/ or next;
    # One range fully contains the other.
    $contained++ if ($a1 <= $b1 && $b2 <= $a2) || ($b1 <= $a1 && $a2 <= $b2);
    # The ranges share at least one section.
    $overlapping++ if $a1 <= $b2 && $b1 <= $a2;
}
print "$contained\n$overlapping\n";
