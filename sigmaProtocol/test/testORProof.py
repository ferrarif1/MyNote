#属性的离散集合满足性证明使用1 of n的Sigma协议OR Proof
#1-n个pubkey中 证明知道其中至少一个的私钥prikey
import rubenesque.curves

secp256r1 = rubenesque.curves.find('secp256r1')

#from utils import *
import utils
#指数运算对应椭圆曲线乘法 g^r => g * r
#乘法运算对应椭圆曲线加法 h^s*g^r => h*s + g*r
#以n=3为例：

# def test_sigma_pok_discrete_log_disjunction():
#     # Prove knowledge of OR composition of 2 discrete logs, PoK(a or b): g1^a1 = P1 or g2^a2 = P2  or g3^a3 = P3 
#     g1, g2, g3 = utils.get_generators(3)
#     a1 = utils.get_random_value()
#     #椭圆曲线上 故为乘法
#     P1 = g1 * a1

#     a2 = utils.get_random_value()
#     #椭圆曲线上 故为乘法
#     P2 = g2 * a2

#     a3 = utils.get_random_value()
#     #椭圆曲线上 故为乘法
#     P3 = g3 * a3
   
    
#     # The prover knows only a1
#     t1c1s1, t2c2s2, t3c3s3 = prove_discrete_log_disjunction(g1, g2, g3, a1, P1, P2, P3)
#     print("t1 = ",t1c1s1[0]," c1 = ",t1c1s1[1],",s1 = ",t1c1s1[1]," \n\nt2 = ",t2c2s2[0],"c2 = ",t2c2s2[1],"s2 = ",t2c2s2[2], t3c3s3[1]," \n\nt3 = ",t3c3s3[0],"c3 = ",t3c3s3[1],"s3 = ",t3c3s3[2])
#     # t1 =  secp256r1(DE4EBF0BA862A2D4E67399990BEB84896B0DA1AC6532DC92B00C68861E73B7DA, 920162AF5ECA047C59E85389B2A0519A387D3FC7436F6609D3461580DAF2EEEE) 
#     # c1 =  15353063062970010770084244815306271906143277068340618502975255973757121655731 
#     # s1 =  15353063062970010770084244815306271906143277068340618502975255973757121655731 
#     # t2 =  secp256r1(97DC624D072586C5C8949543047CE1CC8D7EB98A36C0CB6C94C6E21E76D963DF, 4881AD8758A479C3AB8F783C72C1E3DB96D1FDA99AE26FD481DB49CD605C0C55) 
#     # c2 =  47331786199475917879805207695411116672024328700228442813864297848256733383166 
#     # s2 =  76566419582430905737836643565411049569193823509691242632848622041036617635616
#     assert verify_discrete_log_disjunction(g1, g2, g3, P1, P2, P3, t1c1s1, t2c2s2, t3c3s3)

# def prove_discrete_log_disjunction(g1, g2, g3, a1, P1, P2, P3):
    
#     r1 = utils.get_random_value()
#     c2 = utils.get_random_value()
#     s2 = utils.get_random_value()
#     c3 = utils.get_random_value()
#     s3 = utils.get_random_value()
#     # t1 = g^r1
#     t1 = g1 * r1
#     # t2 = h^s2.Q^-c2
#     t2 = (g2 * s2) + (P2 * ((0-c2) % utils.ORDER))
#     t3 = (g3 * s3) + (P3 * ((0-c3) % utils.ORDER))
#     c = utils.hash_points([g1, g2, g3, P1, P2, P3, t1, t2, t3])
#     c1 = (c - c2 - c3) % utils.ORDER
#     s1 = (r1 + ((c1 * a1) % utils.ORDER)) % utils.ORDER
#     return (t1, c1, s1), (t2, c2, s2), (t3, c3, s3)


# def verify_discrete_log_disjunction(g1, g2, g3, P1, P2, P3, t1c1s1, t2c2s2, t3c3s3):
#     # PoK(a or b): g^a = P or h^b = Q

#     (t1, c1, s1) = t1c1s1
#     (t2, c2, s2) = t2c2s2
#     (t3, c3, s3) = t3c3s3
#     c = utils.hash_points([g1, g2, g3, P1, P2, P3, t1, t2, t3])
#     assert (c == ((c1 + c2 + c3) % utils.ORDER))
#     lhs1 = g1 * s1
#     rhs1 = t1 + (P1 * c1)
#     lhs2 = g2 * s2
#     rhs2 = t2 + (P2 * c2)
#     lhs3 = g3 * s3
#     rhs3 = t3 + (P3 * c3)
#     return (lhs1 == rhs1) and (lhs2 == rhs2) and (lhs3 == rhs3)

def test_sigma_pok_discrete_log_disjunction(n):
    # Prove knowledge of OR composition of 2 discrete logs, PoK(a or b): g1^a1 = P1 or g2^a2 = P2  or g3^a3 = P3 
   
    g = []
    a = []
    P = []
    g = utils.get_generators(n)
    for i in range(n):
       ai = utils.get_random_value()
       a.append(ai)
       #椭圆曲线上 故为乘法
       Pi = g[i] * ai
       P.append(Pi)
   
    
    # The prover knows only a1
    tcs = prove_discrete_log_disjunction(g, a[0], P, n) 
    assert verify_discrete_log_disjunction(g1, g2, g3, P1, P2, P3, t1c1s1, t2c2s2, t3c3s3)

def prove_discrete_log_disjunction(g, a1, P, n):
    c = []
    s = []
    t = []
    r1 = utils.get_random_value()
    for i in range(1,n):
       ci = utils.get_random_value()
       si = utils.get_random_value()
       c.append(ci)
       s.append(si)

    # t1 = g^r1
    t1 = g[0] * r1
    t.append(t1)
    # t2 = h^s2.Q^-c2
    for i in range(1,n):
       t.append((g[i] * s[i-1]) + (P[i] * ((0-c[i-1]) % utils.ORDER)))
    #这里看下如何处理
    x = g + P + t
    cx = utils.hash_points(x)
    c1 = cx
    for i in range(n-1):
       c1 = c1-c[i-1]
    c1 = c1 % utils.ORDER 
    c.insert(0, c1)


    s1 = (r1 + ((c1 * a1) % utils.ORDER)) % utils.ORDER
    s.insert(0, s1)

    return (t,c,s)


# def verify_discrete_log_disjunction(g1, g2, g3, P1, P2, P3, t1c1s1, t2c2s2, t3c3s3):
#     # PoK(a or b): g^a = P or h^b = Q

#     (t1, c1, s1) = t1c1s1
#     (t2, c2, s2) = t2c2s2
#     (t3, c3, s3) = t3c3s3
#     c = utils.hash_points([g1, g2, g3, P1, P2, P3, t1, t2, t3])
#     assert (c == ((c1 + c2 + c3) % utils.ORDER))
#     lhs1 = g1 * s1
#     rhs1 = t1 + (P1 * c1)
#     lhs2 = g2 * s2
#     rhs2 = t2 + (P2 * c2)
#     lhs3 = g3 * s3
#     rhs3 = t3 + (P3 * c3)
#     return (lhs1 == rhs1) and (lhs2 == rhs2) and (lhs3 == rhs3)


test_sigma_pok_discrete_log_disjunction(3)
