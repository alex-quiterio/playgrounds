#!/usr/bin/perl
# Day 25: Full of Hot Air
use strict;
use warnings;

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my %digit = ('2' => 2, '1' => 1, '0' => 0, '-' => -1, '=' => -2);

my $total = 0;
while (<$in>) {
    chomp;
    next unless length;
    my $n = 0;
    $n = $n * 5 + $digit{$_} for split //;
    $total += $n;
}

# Base 5 with digits -2..2: a remainder of 3 or 4 becomes -2 or -1 and carries one.
my $snafu = '';
while ($total) {
    my $r = $total % 5;
    $snafu = ('0', '1', '2', '=', '-')[$r] . $snafu;
    $total = ($total - ($r > 2 ? $r - 5 : $r)) / 5;
}
print $snafu || '0', "\n";
