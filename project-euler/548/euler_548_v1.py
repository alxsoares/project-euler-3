#!/usr/bin/env python

import math
import re
import sys
from subprocess import Popen, PIPE

if sys.version_info > (3,):
    long = int
    xrange = range

cache = {'':long(1)}

def factor_sig(n):
    pipe = Popen(['factor', str(n)], shell=False, stdout=PIPE).stdout
    l = pipe.readline()
    pipe.close()
    sig = {}
    factors_s = re.sub('^[^:]*:', '', l)
    for x in re.findall('[0-9]+', factors_s):
        if not x in sig:
            sig[x] = 0
        sig[x] += 1
    return sorted(sig.values())

def check_factor_sig(n, good):
    if factor_sig(n) != good:
        print ("%d is not good" % (n));
        raise BaseException
    return

check_factor_sig(24, [1, 3]);
check_factor_sig(100, [2, 2]);
check_factor_sig(1000, [3, 3]);

# sig must be sorted.
def real_calc_num_chains(sig):
    def helper(so_far, x, all_zeros):
        if x == len(sig):
            return 0 if all_zeros else calc_num_chains(sorted(so_far))
        ret = 0
        n = sig[x]
        for c in xrange(0, n+1):
            ret += helper(so_far + [n - c] if c < n else so_far, x+1, (all_zeros and (c == 0)))
        return ret
    return helper([], 0, True)

# sig must be sorted.
def calc_num_chains(sig):
    sig_s = ','.join(str(x) for x in sig)
    if not sig_s in cache:
        cache[sig_s] = real_calc_num_chains(sig)
    return cache[sig_s]

def check_num_chains(n, good):
    if calc_num_chains(factor_sig(n)) != good:
        print ("calc_num_chains %d is not good" % (n));
        raise BaseException
    return

check_num_chains(12, 8)
check_num_chains(48, 48)
check_num_chains(120, 132)
