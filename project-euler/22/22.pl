#!/usr/bin/perl

use strict;
use warnings;

use IO::All qw(io);
use List::Util qw(sum);

my $text = io("names.txt")->slurp();

my @names = sort { $a cmp $b } ( lc($text) =~ m{"([a-z]+)"}g );

my $sum = 0;
while ( my ( $i, $s ) = each @names )
{
    $sum += ( $i + 1 ) * sum( map { ord($_) - ord("a") + 1 } split //, $s );
}

print "$sum\n";
