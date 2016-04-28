#!/usr/bin/env python

import sys

if sys.version_info > (3,):
    long = int
    xrange = range

Limit = 1000000         # Search under 1 million for now
factors = [0] * Limit   # number of prime factors.
count = 0
for i in xrange(2, Limit):
    if factors[i] == 0:
        # i is prime
        count = 0
        val = i
        while val < Limit:
            factors[val] += 1
            val += i
    elif factors[i] == 4:
        count += 1
        if count == 4:
            print(i-3)  # First number
            break
    else:
        count = 0
