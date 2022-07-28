use core::bls12381::big;
use core::bls12381::big::BIG;
use core::bls12381::ecp;
use core::bls12381::ecp::ECP;
use core::bls12381::ecp2::ECP2;
use core::bls12381::fp4::FP4;
use core::bls12381::fp12::FP12;
use core::rand::RAND;
use core::hash384::HASH384;

use core::bls12381::pair;
use core::bls12381::rom;
use core::hmac;

pub fn cl_key_generation(msg_count: usize, q: &BIG, rng: &mut RAND) -> (ClSecretKey, ClPublicKey){

    let g2 = ECP2::generator();

    let x = BIG::randomnum(q, rng);
    let y = BIG::randomnum(q, rng);

    let X = pair::g2mul(&g2, &x);
    let Y = pair::g2mul(&g2, &y);

    let mut z_array = Vec::new();
    let mut Z_array = Vec::new();

    for i in 0..msg_count-1 {
        let zi = BIG::randomnum(q, rng);
        Z_array.push(pair::g2mul(&g2, &zi));
        z_array.push(zi);
    }

    let pk = ClPublicKey {
        X,
        Y,
        Z_array
    };
    let sk = ClSecretKey {
        x,
        y,
        z_array
    };

    (sk, pk)

}

pub struct ClSecretKey {
    x: BIG,
    y: BIG,
    z_array: Vec<BIG>
}

pub struct ClPublicKey {
    X: ECP2,
    Y: ECP2,
    Z_array: Vec<ECP2>
}

pub struct ClSignature {
    a: ECP,
    ai: Vec<ECP>,
    b: ECP,
    bi: Vec<ECP>,
    c: ECP
}

impl ClSignature {
    pub fn new(messages: Vec<&str>, secret_key: &ClSecretKey, q: &BIG, rng: &mut RAND) -> ClSignature {
        let mut hasher = HASH384::new();

        let h = BIG::randomnum(q, rng);
        let a = ECP::hashit(&h);

        let mut ai_array: Vec<ECP> = secret_key.z_array.iter().map(|zi| pair::g1mul(&a, zi)).collect();

        let b = pair::g1mul(&a, &secret_key.y);

        let bi_array: Vec<ECP> = ai_array.iter().map(|ai| pair::g1mul(&ai, &secret_key.y)).collect();

        hasher.process_array(messages.get(0).unwrap().as_bytes());

        let mut m0 = BIG::frombytes(&hasher.hash());
        m0.rmod(&q);

        let mut x_xym0 = BIG::modadd(&secret_key.x, &BIG::modmul(&secret_key.x, &BIG::modmul(&secret_key.y, &m0, q), &q), &q);



        let m_array = Vec::from(&messages[1..]);



        let mut exponent_total = m_array.iter().zip(secret_key.z_array.iter()).fold(x_xym0, |acc, (mi, zi)| {
            hasher.process_array(&*mi.as_bytes());
            let mut mi_big = BIG::frombytes(&hasher.hash());
            mi_big.rmod(q);

            let x_xym0 = BIG::modadd(&secret_key.x, &BIG::modmul(&secret_key.x, &BIG::modmul(&secret_key.y, &mi_big, q), &q), &q);

            let zi_x_xym0 = BIG::modadd(&zi, &x_xym0, q);
            BIG::modadd(&acc, &zi_x_xym0, q)

        });

        let mut c = pair::g1mul(&a, &exponent_total);


        ClSignature {
            a,
            ai: ai_array,
            b,
            bi: bi_array,
            c
        }

    }

    pub fn verify(&self, public_key: &ClPublicKey, q: &BIG, rng: &RAND) -> bool {
        let g2 = ECP2::generator();
        let mut verified = true;

        self.ai.iter().zip(public_key.Z_array.iter()).map(|(ai, zi)| {

            let mut lhs = pair::ate(&zi, &self.a);
            lhs = pair::fexp(&lhs);
            let mut rhs = pair::ate(&g2, &ai);
            rhs = pair::fexp(&rhs);

            if !rhs.equals(&lhs) {
                verified = false;
            }
        });


        return true
    }
}