#!/usr/bin/perl

use strict;
use warnings;

no warnings 'recursion';

use Math::GMP;

use integer;
use bytes;

use List::Util qw(sum);
use List::MoreUtils qw();

STDOUT->autoflush(1);

# The cache.
my %c;

sub A
{
    my ($m, $n) = @_;

    my $ret = sub {
        if ($m == 0)
        {
            return Math::GMP->new("$n")+1;
        }
        elsif ($m == 1)
        {
            return Math::GMP->new("$n")+2;
        }
        elsif ($m == 2)
        {
            return ((Math::GMP->new("$n")<<1)+3);
        }
        elsif ($m == 3)
        {
            return ((Math::GMP->new('1') << (Math::GMP->new("$n") + 3)) - 3);
        }
        elsif ($n == 0)
        {
            return A($m-1,1);
        }
        else
        {
            return $c{"$m"}{"$n"} //= A($m-1, A($m,$n-1));
        }
    }->();

    if ($ret <= 0)
    {
        die "A($m,$n)!";
    }

    # print "A($m,$n) = $ret\n";

    return $ret;
}

my $ULTIMATE_MOD = 14 ** 8;

my @m_cache;

sub get__m__cache
{
    my ($m, $MOD, $PREFIX) = @_;

    return @{ $m_cache[$m]{$MOD}{$PREFIX} //= sub {
        my $m_ = $m - 2;
        my @f = ($MOD, $PREFIX);
        my $next = sub {
            return A_mod($m_, scalar(shift(@_)),@f);
        };

        my $x = $next->(1);
        my @seq = ($x);
        my %cache = ($x => $#seq);

        $x = $next->($x);

        while (!exists($cache{$x}))
        {
            push @seq, $x;
            $cache{$x} = $#seq;
        }
        continue
        {
            $x = $next->($x);
        }

        my $NEW_PREFIX = $cache{$x};
        return [ (@seq - $NEW_PREFIX), $NEW_PREFIX, \@seq ];
    }->() };
}

sub A_mod
{
    my ($m, $n, $MOD, $PREFIX) = @_;

    my $ret = sub {
        if ($m == 0)
        {
            return (($n+1)%$MOD);
        }
        elsif ($m == 1)
        {
            return (($n+2)%$MOD);
        }
        elsif ($m == 2)
        {
            return ((($n<<1)+3)%$MOD);
        }
        # elsif (0)
        elsif ($m == 3)
        {
            return ((((Math::GMP->new('1') << (Math::GMP->new("$n") + 3)) - 3)%$MOD) . '');
        }
        elsif ($n == 0)
        {
            return A_mod($m-1, 1, $MOD, $PREFIX);
        }
        elsif ($m <= 6)
        {
            my ($NEW_MOD, $NEW_PREFIX, $seq) = get__m__cache($m, $MOD, $PREFIX);

            if (($NEW_PREFIX == 0) and ($NEW_MOD == 1))
            {
                print "Seq  = [@$seq]\n";
                return $seq->[0];
            }
            my $ret = A_mod($m, ($n-1), $NEW_MOD, $NEW_PREFIX);

            # my $r = $cache{$ret};
            my $r = $seq->[$ret];

            if ($r < $PREFIX)
            {
                return $r;
            }
            else
            {
                return (($r - $PREFIX) % $MOD + $PREFIX);
            }
        }
        else
        {
            return $c{"$m"}{"$n"} //= A($m-1, A($m,$n-1));
        }
    }->();

    if ($ret < 0 or (!defined $ret))
    {
        die "A_mod($m,$n)!";
    }

    # print "A($m,$n) = $ret\n";

    return $ret;
}

for my $m (0 .. 3)
{
    for my $n (0 .. 100)
    {
        print "A($m,$n) = ", A($m,$n), "\n";
    }
}

sub exp_mod
{
    my ($base, $exp, $mod) = @_;

    if ($exp == 0)
    {
        return 1;
    }
    my $rec = exp_mod($base, $exp >> 1, $mod);
    my $ret = ($rec * $rec) % $mod;
    if ($exp & 1)
    {
        $ret = (($ret * $base) % $mod);
    }
    return $ret;
}

sub hyperexp_modulo
{
    my ($base, $exp, $mod, $prefix, $DEFAULT_RET) = @_;

    if ($exp == 1)
    {
        return ($base % $mod);
    }
    if (($mod == 1) and ($prefix == 0))
    {
        return $DEFAULT_RET;
    }

    my $mod1 = $base;
    my $e = -1;

    my %cache;
    while (!exists($cache{$mod1}))
    {
        $cache{$mod1} = ++$e;
        ($mod1 *= $base) %= $mod;
    }

    my $PREFIX = $cache{$mod1};
    my $LEN = $e - $PREFIX;

    my $mod_recurse = hyperexp_modulo($base, $exp-1, $LEN, $PREFIX, $base);

    my $ret = 1;
    for my $i (1 .. $mod_recurse)
    {
        ($ret *= $base) %= $mod;
    }
    return $ret;
}

my $TEST_MOD = 37;
for my $m (4)
{
    for my $n (0 .. 2)
    {
        # print "A($m,$n) = ", (A($m,$n) % $ULTIMATE_MOD), "\n";
        print "A($m,$n) = ", (A($m,$n) % $TEST_MOD), "\n";
        print "A[t]($m,$n) = ", ((hyperexp_modulo(2, $n+3, $TEST_MOD, 0, [0 .. $TEST_MOD-1]) + $TEST_MOD - 3) % $TEST_MOD), "\n";
    }
    for my $n (3 .. 10)
    {
        print "A($m,$n) = ", ((hyperexp_modulo(2, $n+3, $TEST_MOD, 0, [0 .. $TEST_MOD-1]) + $TEST_MOD - 3) % $TEST_MOD), "\n";
    }
}

for my $m (4)
{
    for my $n (0 .. 10)
    {
        # print "A_mod($m,$n) = ", A_mod($m, $n, $ULTIMATE_MOD, 0), "\n";
        print "A_mod($m,$n) = ", A_mod($m, $n, $TEST_MOD, 0), "\n";
    }
}

for my $m (5)
{
    for my $n (0 .. 0)
    {
        print "A($m,$n) = ", (A($m,$n) % $ULTIMATE_MOD), "\n";
    }
}

for my $m (5)
{
    for my $n (0 .. 5)
    {
        print "A_mod($m,$n) = ", A_mod($m, $n, $ULTIMATE_MOD, 0), "\n";
    }
}

for my $m (6)
{
    for my $n (0 .. 6)
    {
        print "A_mod($m,$n) = ", A_mod($m, $n, $ULTIMATE_MOD, 0), "\n";
    }
}
