#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use 5.016;

use integer;
use bytes;

my $MOD = 1_000_000_000;

sub exp_mod
{
    my ( $b, $e ) = @_;

    if ( $e == 0 )
    {
        return 1;
    }

    my $rec_p = exp_mod( $b, ( $e >> 1 ) );

    my $ret = $rec_p * $rec_p;

    if ( $e & 0x1 )
    {
        $ret *= $b;
    }

    return ( $ret % $MOD );
}

sub calc_f
{
    my ($n) = @_;

    if ( $n % 10 == 0 )
    {
        return 0;
    }

    my $cache = '';

    my $e     = 0;
    my $power = 1;

    # Find the first cycle len.
    while ( !vec( $cache, $power, 1 ) )
    {
        vec( $cache, $power, 1 ) = 1;
    }
    continue
    {
        $e++;
        ( $power *= $n ) %= $MOD;
    }

    my $found_power = $power;
    my $found_e     = $e;

    $power = 1;
    $e     = 0;
    while ( $power != $found_power )
    {
        $e++;
        ( $power *= $n ) %= $MOD;
    }

    my $cycle_len = $found_e - $e;

    $power = 1;
    my $x = 0;
    for my $e2 ( 0 .. $found_e )
    {
        if ( ( $power - $e2 ) % $cycle_len == 0
            and $power > $x )
        {
            $x = $power;
        }
    }
    continue
    {
        ( $power *= $n ) %= $MOD;
    }

    print "f($n) == $x\n";

    return $x;
}

my $MAX = 1_000_000;
my $sum = 0;

my ( $START, $END ) = @ARGV;

STDOUT->autoflush(1);

foreach my $n ( $START .. $END )
{
    $sum += calc_f($n);
}

say "Sum == $sum";
