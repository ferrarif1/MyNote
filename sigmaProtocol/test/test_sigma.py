import rubenesque.curves

secp256r1 = rubenesque.curves.find('secp256r1')

# from test.utils import *
import utils

def test_sigma_pok_discrete_log():
    # Prove knowledge of a discrete log, PoK(x): g^x = y
    g, = get_generators(1)
    x = get_random_value()
    y = g * x

    (t, s) = prove_discrete_log_knowledge(g, y, x)
    assert verify_discrete_log_knowledge(g, y, t, s)


def test_sigma_pok_discrete_log_equality():
    # Prove knowledge of equality 2 discrete logs, PoK(a): g^a = P and h^a = Q
    g, h = get_generators(2)
    a = get_random_value()
    P = g * a
    Q = h * a
    t1, t2, s = prove_discrete_log_equality(g, h, P, Q, a)
    assert verify_discrete_log_equality(g, h, P, Q, t1, t2, s)


def test_sigma_pok_discrete_log_conjunction():
    # Prove knowledge of 2 discrete logs, i.e. AND composition of 2 discrete logs, PoK(a, b): g^a = P and h^b = Q
    g, h = get_generators(2)
    a = get_random_value()
    P = g * a
    b = get_random_value()
    Q = h * b

    (t1, s1), (t2, s2) = prove_discrete_log_conjunction(g, h, P, Q, a, b)
    assert verify_discrete_log_conjunction(g, h, P, Q, (t1, s1), (t2, s2))


def test_sigma_pok_discrete_log_disjunction():
    # Prove knowledge of OR composition of 2 discrete logs, PoK(a or b): g^a = P or h^b = Q
    g, h = get_generators(2)
    a = get_random_value()
    P = g * a
    b = get_random_value()
    Q = h * b

    # The prover knows only a
    t1c1s1, t2c2s2 = prove_discrete_log_disjunction(g, h, P, a, Q)
    assert verify_discrete_log_disjunction(g, h, P, Q, t1c1s1, t2c2s2)


def test_sigma_pok_message_and_randomness_in_pedersen_commitment():
    # Prove knowledge of message and randomness in a Pedersen commitment, PoK(a, b): g^a.h^b = P
    g, h = get_generators(2)
    a = get_random_value()
    b = get_random_value()
    P = g * a + h * b

    t, s1, s2 = prove_knowledge_of_opening_of_pedersen_commitment(g, h, P, a, b)
    assert verify_knowledge_of_opening_of_pedersen_commitment(g, h, P, t, s1, s2)


def test_sigma_pok_message_and_randomness_in_pedersen_commitments_equal():
    # Prove knowledge of message and randomness in 2 Pedersen commitments with different generators
    # and prove they are equal equal, PoK(a, b): g1^a.h1^b = g2^a.h2^b
    g1, h1, g2, h2 = get_generators(4)
    a = get_random_value()
    b = get_random_value()
    P = g1 * a + h1 * b
    Q = g2 * a + h2 * b

    (t1, s1), (t2, s2) = prove_knowledge_and_eq_of_opening_of_pedersen_commitments(g1, h1, g2, h2, P, Q, a, b)
    assert verify_knowledge_and_eq_of_opening_of_pedersen_commitments(g1, h1, g2, h2, P, Q, (t1, s1), (t2, s2))


def test_sigma_discrete_log_inequality():
    # Given P = g^a where a is known and given Q = h^b where b is unknown,
    # it can be checked that b is not same as a. If b !=a prove it without disclosing a.
    g, h = get_generators(2)
    a = get_random_value()
    P = g * a
    b = get_random_value()
    Q = h * b

    C, (t1, s1), (t2, s2) = prove_discrete_log_inequality(g, h, a, P, Q)
    assert verify_discrete_log_inequality(g, h, P, Q, C, (t1, s1), (t2, s2))


################   HELPERS  ##################


def prove_discrete_log_knowledge(g, y, x):
    # PoK(x): g^x = y
    # Choose a random value for committing
    r = get_random_value()
    # t is the commitment in 1st phase
    t = g * r
    # Simulate challenge for 2nd phase by hashing the commitment and instance values
    c = hash_points([g, y, t])
    # Third phase
    s = (r + ((c*x) % ORDER)) % ORDER
    return t, s


def verify_discrete_log_knowledge(g, y, t, s):
    # PoK(x): g^x = y
    # Generate same challenge as prover did
    c = hash_points([g, y, t])
    lhs = g * s
    rhs = t + (y * c)
    return lhs == rhs


def prove_discrete_log_equality(g, h, P, Q, a):
    # PoK(a): g^a = P and h^a = Q
    # Choose the same random value for both commitments
    r = get_random_value()
    # Generate 2 commitments
    t1 = g * r
    t2 = h * r
    # Simulate challenge by hashing both commitments
    c = hash_points([g, h, P, Q, t1, t2])
    s = (r + ((c * a) % ORDER)) % ORDER
    return t1, t2, s


def verify_discrete_log_equality(g, h, P, Q, t1, t2, s):
    # PoK(a): g^a = P and h^a = Q
    c = hash_points([g, h, P, Q, t1, t2])
    lhs1 = g * s
    rhs1 = t1 + (P * c)
    lhs2 = h * s
    rhs2 = t2 + (Q * c)
    return (lhs1 == rhs1) and (lhs2 == rhs2)


def prove_discrete_log_conjunction(g, h, P, Q, a, b):
    # PoK(a, b): g^a = P and h^b = Q
    r1 = get_random_value()
    r2 = get_random_value()
    t1 = g * r1
    t2 = h * r2
    # Simulate challenge by hashing both commitments
    c = hash_points([g, h, P, Q, t1, t2])
    s1 = (r1 + ((c * a) % ORDER)) % ORDER
    s2 = (r2 + ((c * b) % ORDER)) % ORDER
    return (t1, s1), (t2, s2)


def verify_discrete_log_conjunction(g, h, P, Q, t1s1, t2s2):
    # PoK(a, b): g^a = P and h^b = Q
    (t1, s1) = t1s1
    (t2, s2) = t2s2
    c = hash_points([g, h, P, Q, t1, t2])
    lhs1 = g * s1
    rhs1 = t1 + (P * c)
    lhs2 = h * s2
    rhs2 = t2 + (Q * c)
    return (lhs1 == rhs1) and (lhs2 == rhs2)


def prove_discrete_log_disjunction(g, h, P, a, Q):
    # PoK(a or b): g^a = P or h^b = Q

    # Choose r1, c2 and s2 randomly
    r1 = get_random_value()
    c2 = get_random_value()
    s2 = get_random_value()
    # t1 = g^r1
    t1 = g * r1
    # t2 = h^s2.Q^-c2
    t2 = (h * s2) + (Q * ((0-c2) % ORDER))
    c = hash_points([g, h, P, Q, t1, t2])
    c1 = (c - c2) % ORDER
    s1 = (r1 + ((c1 * a) % ORDER)) % ORDER
    return (t1, c1, s1), (t2, c2, s2)


def verify_discrete_log_disjunction(g, h, P, Q, t1c1s1, t2c2s2):
    # PoK(a or b): g^a = P or h^b = Q

    (t1, c1, s1) = t1c1s1
    (t2, c2, s2) = t2c2s2
    c = hash_points([g, h, P, Q, t1, t2])
    assert (c == ((c1 + c2) % ORDER))
    lhs1 = g * s1
    rhs1 = t1 + (P * c1)
    lhs2 = h * s2
    rhs2 = t2 + (Q * c2)
    return (lhs1 == rhs1) and (lhs2 == rhs2)


def prove_knowledge_of_opening_of_pedersen_commitment(g, h, P, a, b):
    # PoK(a, b): g^a.h^b = P
    r1 = get_random_value()
    r2 = get_random_value()
    t = g * r1 + h * r2
    c = hash_points([g, P, t])
    s1 = (r1 + ((c * a) % ORDER)) % ORDER
    s2 = (r2 + ((c * b) % ORDER)) % ORDER
    return t, s1, s2


def verify_knowledge_of_opening_of_pedersen_commitment(g, h, P, t, s1, s2):
    lhs = g * s1 + h * s2
    c = hash_points([g, P, t])
    rhs = t + (P * c)
    return lhs == rhs


def prove_knowledge_and_eq_of_opening_of_pedersen_commitments(g1, h1, g2, h2, P, Q, a, b):
    # PoK(a, b): g1^a.h1^b = g2^a.h2^b
    r1 = get_random_value()
    r2 = get_random_value()
    t1 = g1 * r1 + h1 * r2
    t2 = g2 * r1 + h2 * r2
    c = hash_points([g1, h1, g2, h2, P, Q, t1, t2])
    s1 = (r1 + ((c * a) % ORDER)) % ORDER
    s2 = (r2 + ((c * b) % ORDER)) % ORDER
    return (t1, s1), (t2, s2)


def verify_knowledge_and_eq_of_opening_of_pedersen_commitments(g1, h1, g2, h2, P, Q, t1s1, t2s2):
    (t1, s1) = t1s1
    (t2, s2) = t2s2
    lhs1 = g1 * s1 + h1 * s2
    lhs2 = g2 * s1 + h2 * s2
    c = hash_points([g1, h1, g2, h2, P, Q, t1, t2])
    rhs1 = t1 + (P * c)
    rhs2 = t2 + (Q * c)
    return (lhs1 == rhs1) and (lhs2 == rhs2)


def prove_discrete_log_inequality(g, h, a, P, Q):
    r = get_random_value()
    C = h * ((a * r) % ORDER) + (Q * ((0-r) % ORDER))
    # alpha = a * r
    alpha = ((a * r) % ORDER)
    # beta = -r
    beta = ((0-r) % ORDER)

    # iden is the identity element so adding or subtracting it from something makes no difference
    iden = C - C

    # Prove knowledge of alpha and beta such that g^alpha * P^beta = 1 and h^alpha * Q^beta = C
    (t1, s1), (t2, s2) = prove_knowledge_and_eq_of_opening_of_pedersen_commitments(g, P, h, Q, iden, C, alpha, beta)
    return C, (t1, s1), (t2, s2)


def verify_discrete_log_inequality(g, h, P, Q, C, t1s1, t2s2):
    if C.is_identity:
        return False

    # iden is the identity element so adding or subtracting it from something makes no difference
    iden = C - C
    return verify_knowledge_and_eq_of_opening_of_pedersen_commitments(g, P, h, Q, iden, C, t1s1, t2s2)

