#!/usr/bin/env python

import math
import subprocess
import sys

if sys.version_info > (3,):
    long = int
    xrange = range

MAX = 1000000
MOD = 2017

root = int(math.sqrt(MAX))
p1 = subprocess.Popen(["primes", "2", str(root)], stdout=subprocess.PIPE)

while True:
    l = p1.stdout.readline()
    if l == '':
        break
    n = int(l)
    nn = n
    sum_ = 1 + nn
    while nn <= MAX:
        if (sum_ % MOD == 0):
            prod = nn
            print(prod)
            while prod <= MAX:
                for i in range(1, n):
                    prod += nn
                    if prod <= MAX:
                        print(prod)
                    else:
                        break
                prod += nn
        nn *= n
        sum_ += nn

def is_prime(n):
    for x in xrange(3, int(math.sqrt(n))+1, 2):
        if n % x == 0:
            return False
    return True

m2 = MOD * 2
start = root + m2 - (root % m2)

for n in xrange(start-1,MAX+1,m2):
    if is_prime(n):
        for nn in xrange(n,MAX+1,n):
            print(nn)