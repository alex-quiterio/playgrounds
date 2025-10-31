#!/usr/bin/perl
# Day 6: Tuning Trouble
use strict;
use warnings;

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
chomp(my $signal = <$in>);

# Characters processed when the last `size` characters are all different.
sub marker {
    my ($size) = @_;
    for my $end ($size .. length $signal) {
        my %seen = map { $_ => 1 } split //, substr($signal, $end - $size, $size);
        return $end if keys %seen == $size;
    }
    return -1;
}

print marker(4), "\n", marker(14), "\n";
