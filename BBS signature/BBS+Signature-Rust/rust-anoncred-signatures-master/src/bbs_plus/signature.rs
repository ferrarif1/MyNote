use core::bls12381::big::BIG;
use core::rand::RAND;

use core::bls12381::ecp2::ECP2;
use core::bls12381::ecp::ECP;
use core::bls12381::pair;
use core::bls12381::rom;
use core::hmac;
use core::hash384::HASH384;

pub struct BBSPlusKey {
    sk: BIG,
    pub pk: BBSPlusPublicKey
}

pub struct BBSPlusPublicKey {
    pub w: ECP2,
    pub h0: BIG,
    pub h: Vec<BIG>
}

impl BBSPlusPublicKey {
    pub fn new(sk: &BIG, message_array_len: usize, q: &BIG, rng: &mut RAND) -> BBSPlusPublicKey {

        let g2 = ECP2::generator();
        
        
        //w = g2^sk => G2
        let w = pair::g2mul(&g2, sk);
        
        let mut h0 = BIG::randomnum(q, rng);
        let mut h = Vec::new();

        // Create random h one plus the number of messages
        for index in 0..message_array_len {
            let current_h = BIG::randomnum(q, rng);
            h.push(current_h);
        };

        BBSPlusPublicKey {
            w,
            h0,
            h
        }

    }
}

impl BBSPlusKey {
    pub fn new(size: usize, q: &BIG, rng: &mut RAND) -> BBSPlusKey {
        let x = BIG::randomnum(q, &mut *rng);

        BBSPlusKey {
            sk: x,
            pk: BBSPlusPublicKey::new(&x, size, q, rng)
        }

    }

    pub fn sign(&self, messages: Vec<&str>, q: &BIG, rng: &mut RAND) -> BBSPlusSig {

        assert!(messages.len() == self.pk.h.len());

        let mut hasher = HASH384::new();

        let e = BIG::randomnum(q, rng);
        let s = BIG::randomnum(q, rng);

        let g1 = ECP::generator();


        let mut running_total = BIG::new();
//        running_total.one();

        let mut h0 = BIG::new_copy(&self.pk.h0);

         //h0^s
        let mut h0s = h0.powmod(&s, q);
        let mut total = BIG::new();
        total.one();
        //b = 累乘m^h
        let b = self.pk.h.iter().zip(messages.iter()).fold(total, |acc, (h, msg)| {
//            println!("Message {}", msg);
            hasher.process_array(msg.as_bytes());

            let hash_result = hasher.hash();

            let mut m = BIG::frombytes(&hash_result);
//            println!("Hashed M {}", m.tostring());

            m.rmod(&q);
            //mh = m^h mod q  ?? should be h^m ??
            let mut mh = m.powmod(h, &q);
            //mh = mh * acc mod q
            BIG::modmul(&mh, &acc, &q)
        });
        //h0sb = h0^s * b (mod q)
        let mut h0sb = BIG::modmul(&h0s, &b, &q);
        //A = g1 ^ h0sb 
        let mut A = pair::g1mul(&g1, &h0sb);

        let mut ex = BIG::new_copy(&e);
        ex.add(&self.sk);
        ex.rmod(&q);

        //(e+x)^-1
        ex.invmodp(q);
        //A^ex = [g1 ^(h0^s * m1^h1 *... *ml^hl)]^[(e+x)^-1]
        A = pair::g1mul(&A, &ex); //指数运算对应椭圆曲线乘法

        BBSPlusSig {
            A,
            e,
            s
        }

    }
}

pub struct BBSPlusSig {
    A: ECP,
    e: BIG,
    s: BIG
}

//DOC about ECCurve
//https://docs.rs/amcl_wrapper/latest/amcl_wrapper/ECCurve/pair/fn.fexp.html
impl BBSPlusSig {
    pub fn verify(&self, messages: Vec<&str>, pk: &BBSPlusPublicKey, q: &BIG) -> bool {

        if messages.len() != pk.h.len() {
            return false
        }

        let mut hasher = HASH384::new();

        let g2 = ECP2::generator();
        let g1 = ECP::generator();
        print!("g1={}", g1.tostring());
        print!("g2={}", g2.tostring());
        let mut g2e = pair::g2mul(&g2, &self.e);
         //?? should be g2^(e+x) ??
        g2e.add(&pk.w);

        //ate配对分两步：主循环和最终幂计算
        let mut lhs = pair::ate(&g2e, &self.A);
        //最终幂计算
        lhs = pair::fexp(&lhs);


        let mut h0 = BIG::new_copy(&pk.h0);

        let mut h0s = h0.powmod(&self.s, q);

        let mut total = BIG::new();
        total.one();

        let b = pk.h.iter().zip(messages.iter()).fold(total, |acc, (h, msg)| {
            hasher.process_array(msg.as_bytes());

            let hash_result = hasher.hash();

            let mut m = BIG::frombytes(&hash_result);

            m.rmod(&q);

            let mut mh = m.powmod(h, &q);

            BIG::modmul(&mh, &acc, &q)


        });

        let mut h0sb = BIG::modmul(&h0s, &b, q);

        let mut g1hm = pair::g1mul(&g1, &h0sb);

        let mut rhs = pair::ate(&g2, &g1hm);
        rhs = pair::fexp(&rhs);

        lhs.equals(&rhs)

    }

}