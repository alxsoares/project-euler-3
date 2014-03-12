#!/usr/bin/perl

use strict;
use warnings;
use integer;
use bytes;

use List::Util qw(min sum);
use List::MoreUtils qw();

sub gcd
{
    my ($n, $m) = @_;

    if ($m > $n)
    {
        ($n, $m) = ($m, $n);
    }

    while ($m > 0)
    {
        ($n, $m) = ($m, $n%$m);
    }

    return $n;
}

sub calc_sum
{
    my ($MAX) = @_;

    my $ret = 0;

    my $MAX_SQ = $MAX*$MAX;
    foreach my $aa (1 .. $MAX)
    {
        print "a=$aa\n";

        my $s = sub {
            my ($bb) = @_;

            # print "a=$aa b=$bb\n";

            # Question: when is ($cc*$bb/$aa) an integer?
            #
            # Answer: when $cc*$bb mod $aa == 0
            # That happens when $cc is a product of $aa/gcd($aa,$bb)

            my $cc_step = $aa / gcd($bb, $aa);

            my $p = (1 + ($bb/$aa)**2);

            my $max_cc = min(
                $aa,
                $MAX/($aa*$p),
            );

            my $cc_num_steps = int( ($max_cc-1) / $cc_step );
            # Sum of $aa+$cc_step + $aa + 2*$cc_step + $aa + 3 * $cc_step
            # up to $aa + $cc_step*($cc_num_steps)
            my $cc = $cc_step * ($cc_num_steps+1);
            my $cc_ret = $cc_num_steps *
            ($aa + ($cc>>1))
            ;


=begin foo
        while ($cc < $max_cc)
        {
            # my $delta = ($aa + $cc);
            # print "Found $aa+i$bb ; $cc+i$dd ; Adding: $delta\n";
            $cc_ret += $aa + $cc;
        }
        continue
        {
            $cc += $cc_step;
        }

=end foo

=cut

            if ($cc == $max_cc)
            {
                $cc_ret += $aa + (($cc == $aa) ? 0 : $cc);
            }

            return $cc_ret;
        };

        $ret += $s->(0);

        my $d = 0;
        foreach my $bb (1 .. int(sqrt($MAX_SQ - $aa*$aa)))
        {
            $d += $s->($bb);
        }
        $ret += $d << 1;
    }

    return $ret;
}

print calc_sum(shift(@ARGV)), "\n";
