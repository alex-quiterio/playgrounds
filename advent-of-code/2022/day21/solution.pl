#!/usr/bin/perl
# Day 21: Monkey Math
use strict;
use warnings;
use bigint;

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my %job;
while (<$in>) {
    next unless /^(\w+): (.*)$/;
    my ($name, $rule) = ($1, $2);
    $job{$name} = $rule =~ /^(\w+) (.) (\w+)$/ ? [$1, $2, $3] : $rule;
}

sub value {
    my $name = shift;
    my $job = $job{$name};
    return $job unless ref $job;
    my ($l, $op, $r) = ($job->[0], $job->[1], $job->[2]);
    my ($a, $b) = (value($l), value($r));
    return $op eq '+' ? $a + $b : $op eq '-' ? $a - $b : $op eq '*' ? $a * $b : $a / $b;
}

# Does the human's number feed into this monkey?
my %has_humn;
sub uses_humn {
    my $name = shift;
    return $has_humn{$name} //= $name eq 'humn' ? 1
        : ref $job{$name} ? (uses_humn($job{$name}[0]) || uses_humn($job{$name}[2])) : 0;
}

# Part 2: walk down from root, undoing each operation on the side that holds humn.
sub solve {
    my ($name, $target) = @_;
    return $target if $name eq 'humn';
    my ($l, $op, $r) = @{ $job{$name} };
    if (uses_humn($l)) {
        my $b = value($r);
        my $want = $op eq '+' ? $target - $b : $op eq '-' ? $target + $b
                 : $op eq '*' ? $target / $b : $target * $b;
        return solve($l, $want);
    }
    my $a = value($l);
    my $want = $op eq '+' ? $target - $a : $op eq '-' ? $a - $target
             : $op eq '*' ? $target / $a : $a / $target;
    return solve($r, $want);
}

print value('root'), "\n";
my ($l, undef, $r) = @{ $job{root} };
print uses_humn($l) ? solve($l, value($r)) : solve($r, value($l)), "\n";
