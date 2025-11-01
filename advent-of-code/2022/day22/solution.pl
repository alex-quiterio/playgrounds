#!/usr/bin/perl
# Day 22: Monkey Map
use strict;
use warnings;

open my $in, '<', $ARGV[0] or die "usage: $0 INPUT\n";
my @lines = <$in>;
chomp @lines;
my @path;
while (@lines && $lines[-1] !~ /\S/) { pop @lines }
my $moves = pop @lines;
pop @lines while @lines && $lines[-1] !~ /\S/;
@path = $moves =~ /(\d+|[LR])/g;

my @map = map { [split //] } @lines;
sub at { my ($x, $y) = @_; return $y >= 0 && $y < @map && $x >= 0 && defined $map[$y][$x] ? $map[$y][$x] : ' ' }

my @dx = (1, 0, -1, 0);   # facing: 0 right, 1 down, 2 left, 3 up
my @dy = (0, 1, 0, -1);
my $start_x = 0;
$start_x++ while at($start_x, 0) ne '.';

sub walk {
    my $wrap = shift;
    my ($x, $y, $f) = ($start_x, 0, 0);
    for my $step (@path) {
        if ($step eq 'R') { $f = ($f + 1) % 4; next }
        if ($step eq 'L') { $f = ($f + 3) % 4; next }
        for (1 .. $step) {
            my ($nx, $ny, $nf) = ($x + $dx[$f], $y + $dy[$f], $f);
            ($nx, $ny, $nf) = $wrap->($x, $y, $f) if at($nx, $ny) eq ' ';
            last if at($nx, $ny) eq '#';
            ($x, $y, $f) = ($nx, $ny, $nf);
        }
    }
    return 1000 * ($y + 1) + 4 * ($x + 1) + $f;
}

# Part 1: come back in from the far side of the same row or column.
sub flat_wrap {
    my ($x, $y, $f) = @_;
    my ($bx, $by) = ($x, $y);
    ($bx, $by) = ($bx - $dx[$f], $by - $dy[$f]) while at($bx - $dx[$f], $by - $dy[$f]) ne ' ';
    return ($bx, $by, $f);
}

# Part 2: fold the net into a cube. Each face gets its outward normal and the
# 3D directions of its local right and down. Points use doubled coordinates so
# cell centres are integers; the cube spans [-n, n] on each axis.
my $cells = 0;
$cells += grep { $_ ne ' ' } @$_ for @map;
my $n = sqrt($cells / 6);
sub neg { [map { -$_ } @{ $_[0] }] }
sub dot { my ($a, $b) = @_; $a->[0] * $b->[0] + $a->[1] * $b->[1] + $a->[2] * $b->[2] }
sub add { my @v = (0, 0, 0); for my $w (@_) { $v[$_] += $w->[$_] for 0 .. 2 } \@v }
sub scale { my ($v, $k) = @_; [map { $_ * $k } @$v] }
sub same { dot($_[0], $_[1]) == 1 }

my %face;   # "fx,fy" (face grid position) => {normal, right, down}
my ($fx0, $fy0) = (int($start_x / $n), 0);
$face{"$fx0,$fy0"} = { normal => [0, 0, 1], right => [1, 0, 0], down => [0, 1, 0] };
my @queue = ([$fx0, $fy0]);
while (my $cur = shift @queue) {
    my ($fx, $fy) = @$cur;
    my $f = $face{"$fx,$fy"};
    my %next = (
        "1,0"  => { normal => $f->{right},     right => neg($f->{normal}), down => $f->{down} },
        "-1,0" => { normal => neg($f->{right}), right => $f->{normal},     down => $f->{down} },
        "0,1"  => { normal => $f->{down},      right => $f->{right},      down => neg($f->{normal}) },
        "0,-1" => { normal => neg($f->{down}), right => $f->{right},      down => $f->{normal} },
    );
    for my $d (keys %next) {
        my ($ddx, $ddy) = split /,/, $d;
        my ($gx, $gy) = ($fx + $ddx, $fy + $ddy);
        next if exists $face{"$gx,$gy"} || at($gx * $n, $gy * $n) eq ' ';
        $face{"$gx,$gy"} = $next{$d};
        push @queue, [$gx, $gy];
    }
}

sub cube_wrap {
    my ($x, $y, $f) = @_;
    my ($fx, $fy) = (int($x / $n), int($y / $n));
    my $a = $face{"$fx,$fy"};
    my ($i, $j) = ($x - $fx * $n, $y - $fy * $n);
    my $p = add(scale($a->{normal}, $n), scale($a->{right}, 2 * $i + 1 - $n), scale($a->{down}, 2 * $j + 1 - $n));
    my $out = ($a->{right}, $a->{down}, neg($a->{right}), neg($a->{down}))[$f];
    # Step over the edge: onto the face whose normal is the direction of travel.
    my $q = add($p, $out, neg($a->{normal}));
    my $heading = neg($a->{normal});
    my ($key) = grep { same($face{$_}{normal}, $out) } keys %face;
    my $b = $face{$key};
    my ($gx, $gy) = split /,/, $key;
    my $nx = $gx * $n + (dot($b->{right}, $q) + $n - 1) / 2;
    my $ny = $gy * $n + (dot($b->{down}, $q) + $n - 1) / 2;
    my ($nf) = grep { same(($b->{right}, $b->{down}, neg($b->{right}), neg($b->{down}))[$_], $heading) } 0 .. 3;
    return ($nx, $ny, $nf);
}

print walk(\&flat_wrap), "\n";
print walk(\&cube_wrap), "\n";
