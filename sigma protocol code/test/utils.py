from hashlib import sha256

import rubenesque.curves


secp256r1 = rubenesque.curves.find('secp256r1')

ORDER = secp256r1.order


def get_generators(n):
    gs = []
    G = secp256r1.generator()
    for _ in range(n):
        # Erase k. The prover should not discrete log of generators with respect to each other
        k = secp256r1.private_key()
        gs.append(G * k)
    return gs


def hash_list(lst):
    h = sha256()
    for i in lst:
        h.update(i)
    return int(h.hexdigest(), 16)


def hash_msg_and_point_xcord(msg, point):
    return hash_list([msg, str(point.x).encode()])


def hash_point_xcord_and_msg(point, msg):
    return hash_list([str(point.x).encode(), msg])


def hash_points(points):
    return hash_list([str(point.x).encode() for point in points])


def get_random_value():
    return secp256r1.private_key()
