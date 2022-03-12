from hashlib import sha256

import rubenesque.curves


secp256r1 = rubenesque.curves.find('secp256r1')


def test_point_addition():
    point_p1 = secp256r1.generator() * secp256r1.private_key()
    point_p2 = -point_p1
    assert point_p1.x == point_p2.x
    assert point_p1.y != point_p2.y
    assert (point_p1 + point_p2).is_identity


def test_scalar_multiplication():
    point_p1 = secp256r1.generator() * secp256r1.private_key()
    point_p2 = point_p1 + point_p1
    point_p3 = point_p1 * 2
    assert point_p2 == point_p3

    point_p4 = point_p1 + point_p1 + point_p1 + point_p1 + point_p1
    point_p5 = point_p1 * 5
    assert point_p4 == point_p5


def test_shared_secret():
    alice_prv = secp256r1.private_key()
    alice_pub = secp256r1.generator() * alice_prv

    bob_prv = secp256r1.private_key()
    bob_pub = secp256r1.generator() * bob_prv

    assert alice_pub * bob_prv == bob_pub * alice_prv
