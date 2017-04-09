import math
import sys

if sys.version_info > (3,):
    long = int
    xrange = range


def find_exp(n, p, m):
    if m > n:
        return 0
    else:
        return (int(n / m) + find_exp(n, p, m*p))


def get_vec_exp(n, p, m, e):
    if n % m == 0:
        return get_vec_exp(n, p, m*p, e+1)
    else:
        return e


def get_vec(primes, n):
    return [get_vec_exp(n, p, p, 0) for p in primes]


def get_split(primes, e):
    return [[get_vec(primes, 1+x) for x in [y, e-y]] for y in xrange(0, e+1)]


def calc_C(fact_n):
    primes = [x for x in xrange(2, fact_n+1)
              if len([y for y in xrange(2, 1+int(math.sqrt(x)))
                      if x % y == 0]) == 0]
    print(primes)
    exps = [find_exp(fact_n, p, p) for p in primes]
    print(exps)
    num_1s = 0
    while exps[-1] == 1:
        exps.pop()
        num_1s += 1
    exps_splits = [get_split(primes, e) for e in exps]
    print(exps_splits)
    exps_diffs = [[[x-y for (x, y) in zip(a[0], a[1])] for a in b]
                  for b in exps_splits]
    print(exps_diffs)

    l = exps_diffs[0]
    new_l = []
    for d in l:
        found = False
        for i, x_ in enumerate(d):
            x = abs(x_)
            s = 0
            for ll in exps_diffs[1:]:
                m = max([dd[i] for dd in ll])
                s += m
            if x > s:
                found = True
                break
        if not found:
            new_l.append(d)

    exps_diffs[0] = new_l

    exps_counts = [len(x) for x in exps_diffs]
    prod = long(1)
    for x in exps_counts:
        prod *= x
    print(exps_diffs)

    print("prod=%d" % prod)

    return 200


def print_C(n):
    print("C(%d!) = %d" % (n, calc_C(n)))


def main():
    print_C(10)
    print_C(100)


if __name__ == "__main__":
    main()