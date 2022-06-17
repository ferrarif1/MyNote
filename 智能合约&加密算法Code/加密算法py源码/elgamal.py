import random

from params import p
from params import g

def keygen():
    rand = random.seed(a=None, version = 2)
    q = (p-1)/2
    a = random.randint(1,q)
    sk = a
    pk = pow(g,a,mod = p)
    return pk,sk

def encrypt(pk,m):
    rand = random.seed(a=None, version = 2)
    q = (p-1)/2
    r = random.randint(1,q)
    c1 = pow(g,r,mod = p)
    c2 = pow(pow(pk,r,mod = p) * pow(m,1,mod=p),1,mod=p)
    return [c1,c2]

def decrypt(sk,c):
    c1 = c[0]
    c2 = c[1]
    m = pow((pow(c2,1, mod = p) * pow(c1,-sk,mod = p)),1,mod = p)
    return m
