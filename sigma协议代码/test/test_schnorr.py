from random import randint
import rubenesque.curves

secp256r1 = rubenesque.curves.find('secp256r1')

from .utils import *


def test_schnorr_sig1():
    # https://crypto.stackexchange.com/q/50221
    point_P = secp256r1.generator() * secp256r1.private_key()   # Generator

    l = point_P.order
    a = randint(1, l)       # secret key
    point_Q = point_P * a   # public key
    msg = b'abc'

    k = randint(1, l)
    point_S0 = point_P * k

    s1 = hash_msg_and_point_xcord(msg, point_S0)
    s2 = (k + a * s1) % l

    # Sig is (point_S0, s2)

    assert point_S0.is_valid
    lhs = point_P * s2
    rhs = point_S0 + point_Q * s1

    assert lhs == rhs


def test_schnorr_sig2():
    # https://crypto.stackexchange.com/q/34863
    l = secp256r1.order
    point_G = secp256r1.generator()
    d = secp256r1.private_key()             # secret key
    point_P = point_G * d                   # public key
    msg = b'abc'

    k = randint(1, l)
    point_Q = point_G * k

    h = hash_msg_and_point_xcord(msg, point_Q)
    s = (k - h * d) % l

    # Sig is (h, s)

    v1 = point_G * s + point_P * h      # This should evaluate to `G*k`
    v2 = hash_msg_and_point_xcord(msg, v1)
    assert v2 == h


def test_schnorr_sig3():
    # https://crypto.stackexchange.com/q/34863
    l = secp256r1.order
    point_G = secp256r1.generator()
    d = secp256r1.private_key()  # secret key
    point_P = point_G * d  # public key
    msg = b'abc'

    k = randint(1, l)
    point_Q = point_G * k

    h = hash_point_xcord_and_msg(point_Q, msg)
    s = (k - h * d) % l

    # Sig is (point_Q.x, s)
    h_prime = hash_list([str(point_Q.x).encode(), msg])     # compute the hash from the message and a part of sig
    v1 = point_G * s + point_P * h_prime
    assert v1.x == point_Q.x


def test_blind_schnorr():
    # TODO: Use this https://blog.cryptographyengineering.com/a-note-on-blind-signature-schemes/
    l = secp256r1.order
    point_G = secp256r1.generator()

    x = secp256r1.private_key()  # secret key
    point_y = point_G * x  # public key
    # Bank (who does the blind signature) picks, `k` and generates `point_R`
    k = secp256r1.private_key()
    point_r = point_G * k

    a = randint(1, l)
    b = randint(1, l)
    msg = b'abc'

    point_r_prime = point_r + (point_G * a) + (point_y * b)
    e_prime = hash_msg_and_point_xcord(msg, point_r_prime)
    # The blog post describes `e = e_prime – b` but that is incorrect
    e = (b - e_prime) % l

    s = (e * x + k) % l

    s_prime = (s + a) % l
    # Sig is (s_prime, e_prime)
    lhs = (point_G * s_prime) + (point_y * e_prime)
    assert lhs == point_r_prime


def test_schnorr_sig_aggregation_naive():
    # Vulnerable to rogue public key attack
    l = secp256r1.order
    point_G = secp256r1.generator()

    num_signers = 5

    secret_keys = [secp256r1.private_key() for _ in range(num_signers)]
    public_keys = [point_G * secret_keys[i] for i in range(num_signers)]
    point_X = public_keys[0]
    for i in range(1, num_signers):
        point_X = point_X + public_keys[i]

    msg = b'abc'

    nonces = [randint(1, l) for _ in range(num_signers)]
    nonce_points = [point_G * nonces[i] for i in range(num_signers)]
    point_R = nonce_points[0]
    for i in range(1, num_signers):
        point_R = point_R + nonce_points[i]

    common_challenge = hash_point_xcord_and_msg(point_X + point_R, msg)

    ses = [(nonces[i] + common_challenge*secret_keys[i]) % l for i in range(num_signers)]
    s = ses[0]
    for i in range(1, num_signers):
        s = (s + ses[i]) % l

    # Sig is (point_R, s)
    lhs = point_G * s
    rhs = point_R + point_X * common_challenge

    assert lhs == rhs

    # A Rogue signer, Kim joins.
    secret_key_kim = secp256r1.private_key()
    public_key_kim = point_G * secret_key_kim
    rogue_public_key = public_key_kim - point_X
    nonce_kim = randint(1, l)
    nonce_point_kim = point_G * nonce_kim
    rogue_nonce_point = nonce_point_kim - point_R

    # After Kim joins, the aggregate public key and point_R change
    new_point_X = point_X + rogue_public_key
    new_point_R = point_R + rogue_nonce_point

    # Kim alone forges an aggregate signature on behalf of everybody
    s_prime = (nonce_kim + common_challenge * secret_key_kim) % l

    # Sig is (new_point_R, s_prime)

    lhs = point_G * s_prime
    rhs = new_point_R + new_point_X * common_challenge

    assert lhs == rhs


def test_schnorr_sig_aggregation_MuSig():
    # Blockstream's MuSig, taken from here https://blockstream.com/2018/01/23/musig-key-aggregation-schnorr-signatures.html
    l = secp256r1.order
    point_G = secp256r1.generator()

    num_signers = 5

    secret_keys = [secp256r1.private_key() for _ in range(num_signers)]
    public_keys = [point_G * secret_keys[i] for i in range(num_signers)]
    h = sha256()
    for pk in public_keys:
        h.update(str(pk.x).encode())
    L = h.digest()

    xs = [pk * hash_msg_and_point_xcord(L, pk) for pk in public_keys]
    point_X = xs[0]
    for i in range(1, num_signers):
        point_X = point_X + xs[i]

    msg = b'abc'

    nonces = [randint(1, l) for _ in range(num_signers)]
    nonce_points = [point_G * nonces[i] for i in range(num_signers)]
    point_R = nonce_points[0]
    for i in range(1, num_signers):
        point_R = point_R + nonce_points[i]

    common_challenge = hash_point_xcord_and_msg(point_X + point_R, msg)

    ses = []
    for i in range(num_signers):
        pk = public_keys[i]
        ses.append(
            (nonces[i] + (common_challenge * secret_keys[i] * hash_msg_and_point_xcord(L, pk))) % l
        )

    s = ses[0]
    for i in range(1, num_signers):
        s = (s + ses[i]) % l

    # Sig is (point_R, s)
    lhs = point_G * s
    rhs = point_R + point_X * common_challenge

    assert lhs == rhs
