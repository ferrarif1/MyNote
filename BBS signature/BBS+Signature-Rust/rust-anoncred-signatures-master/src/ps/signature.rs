use core::bls12381::big;
use core::bls12381::big::BIG;
use core::bls12381::ecp;
use core::bls12381::ecp::ECP;
use core::bls12381::dbig::DBIG;
use core::bls12381::ecp2::ECP2;
use core::bls12381::fp4::FP4;
use core::bls12381::fp12::FP12;
use core::rand::RAND;
use core::hash384::HASH384;

use core::bls12381::pair;
use core::bls12381::rom;
use core::hmac;


pub struct PublicKey {
    X: ECP2,
    Y_array:Vec<ECP2>
}

pub struct SecretKey {
    x: BIG,
    y_array: Vec<BIG>
}


pub fn key_generation(msg_count: usize, q: &BIG, rng: &mut RAND) -> (PublicKey, SecretKey){
    let g2 = ECP2::generator();
    let x = BIG::randomnum(&q, rng);
    let X = pair::g2mul(&g2, &x);

    let mut y_array = Vec::new();
    let mut Y_array = Vec::new();
    for i in 0..msg_count {
        let yi = BIG::randomnum(&q, rng);
        y_array.push(yi);
        Y_array.push(pair::g2mul(&g2, &yi));
    }


    (PublicKey {X, Y_array}, SecretKey {x, y_array})
}


pub struct Signature {
    sigma_1: ECP,
    sigma_2: ECP
}

impl Signature {
    pub fn new(messages: Vec<&str>, sk: &SecretKey, q: &BIG, rng: &mut RAND) -> Self {
        assert_eq!(sk.y_array.len(), messages.len());

        let p = BIG::new_ints(&rom::MODULUS);

        let mut hasher = HASH384::new();

        let g1 = ECP::generator();

        let mut x = BIG::new_copy(&sk.x);
        println!("X {}", x.tostring());

        let sum = messages.iter().zip(sk.y_array.iter()).fold(x, |mut acc, (msg, y)| {
            println!("acc {}", acc.tostring());
            println!("msg {}", msg);

            hasher.process_array(msg.as_bytes());

            let mut m_big = BIG::frombytes(&hasher.hash());
            println!("m_big {}", m_big.tostring());

            m_big.rmod(q);
            println!("mod m_big {}", m_big.tostring());
            let m_y = BIG::modmul(&m_big, y, q);

            BIG::modadd(&acc, &m_y, q)

        });



        let H = ECP::hashit(&BIG::randomnum(&p, rng));




        let mut sig2 = pair::g1mul(&H, &sum);

        Signature {
            sigma_1: H,
            sigma_2: sig2
        }

    }
}


impl PublicKey {
    pub fn verify(&self, signature: &Signature, messages: Vec<&str>, q: &BIG, rng: &mut RAND) -> bool {
        assert_eq!(self.Y_array.len(), messages.len());

        let mut g2 = ECP2::generator();
        let mut hasher = HASH384::new();

        let mut X = ECP2::new();
        X.copy(&self.X);

        let check = self.Y_array.iter().zip(messages.iter()).fold(X, |mut acc, (Y, msg)| {
            println!("acc {}", acc.tostring());
            println!("msg {}", msg);
            hasher.process_array(msg.as_bytes());

            let mut m_big = BIG::frombytes(&hasher.hash());
            println!("m_big {}", m_big.tostring());

            m_big.rmod(q);
            println!("mod m_big {}", m_big.tostring());


            let mut y_m= pair::g2mul(&Y, &m_big);

            y_m.add(&acc);
            y_m

        });

        let mut lhs =pair::ate(&check, &signature.sigma_1);
        lhs = pair::fexp(&lhs);
        println!("LHS {}", lhs.tostring());
        let mut rhs = pair::ate(&g2, &signature.sigma_2);
        rhs = pair::fexp(&rhs);
        println!("RHS {}", rhs.tostring());

        lhs.equals(&rhs)

    }
}


