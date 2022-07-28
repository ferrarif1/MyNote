/*
   Copyright (C) 2019 MIRACL UK Ltd.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.


    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

     https://www.gnu.org/licenses/agpl-3.0.en.html

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   You can be released from the requirements of the license by purchasing
   a commercial license. Buying such a license is mandatory as soon as you
   develop commercial activities involving the MIRACL Core Crypto SDK
   without disclosing the source code of your own applications, or shipping
   the MIRACL Core Crypto SDK with a closed source product.
*/
use crate::bls12381::big;
use crate::bls12381::big::BIG;
use crate::bls12381::ecp;
use crate::bls12381::ecp::ECP;
use crate::bls12381::dbig::DBIG;
use crate::bls12381::ecp2::ECP2;
use crate::bls12381::fp4::FP4;
use crate::bls12381::pair;
use crate::bls12381::rom;
use crate::hmac;

/* BLS API Functions */

/* Loosely (for now) following https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-bls-signature-00 */

// Minimal-signature-size variant

pub const BFS: usize = big::MODBYTES as usize;
pub const BGS: usize = big::MODBYTES as usize;
pub const BLS_OK: isize = 0;
pub const BLS_FAIL: isize = -1;

// NOTE this must be accessed in unsafe mode.
// But it is just written to once at start-up, so actually safe.
static mut G2_TAB: [FP4; ecp::G2_TABLE] = [FP4::new(); ecp::G2_TABLE];

fn ceil(a: usize,b: usize) -> usize {
    return (a-1)/b+1;
}

/* output u \in F_p */
fn hash_to_base(hash: usize,hlen: usize ,dst: &[u8],m: &[u8],ctr: isize) -> BIG {
    let q = BIG::new_ints(&rom::MODULUS);
    let el = ceil(q.nbits()+ecp::AESKEY*8,8);
    let tag = String::from("H2C");
    let tl = tag.len();
    let t=tag.as_bytes();
    let mut info:[u8; 16] = [0; 16];
    for i in 0..tl {
        info[i]=t[i];
    }
    info[tl]=ctr as u8;

    let mut prk: [u8;64]=[0;64];
    let mut okm: [u8;128]=[0;128];

    hmac::hkdf_extract(hash,hlen,&mut prk,Some(&dst),m);
    hmac::hkdf_expand(hash,hlen,&mut okm,el,&prk[0 .. hlen],&info[0 .. tl+1]);

    let mut dx = DBIG::frombytes(&okm[0 .. el]);
    let u=dx.dmod(&q);

    return u;
}

/* hash a message to an ECP point, using SHA2, random oracle method */
#[allow(non_snake_case)]
pub fn bls_hash_to_point(m: &[u8]) -> ECP {
    let dst= String::from("BLS_SIG_ZZZG1-SHA256-SSWU-RO-_NUL_".to_ascii_uppercase());
    let u=hash_to_base(hmac::MC_SHA2,ecp::HASH_TYPE,dst.as_bytes(),m,0);
    let u1=hash_to_base(hmac::MC_SHA2,ecp::HASH_TYPE,dst.as_bytes(),m,1);

    let mut P=ECP::hashit(&u);
    let P1=ECP::hashit(&u1);

    P.add(&P1);
    P.cfp();
    P.affine();
    return P;
}

pub fn init() -> isize {
    let g = ECP2::generator();
    if g.is_infinity() {
        return BLS_FAIL;
    }
    unsafe {
        pair::precomp(&mut G2_TAB, &g);
    }
    return BLS_OK;
}

/* generate key pair, private key s, public key w */
pub fn key_pair_generate(ikm: &[u8], s: &mut [u8], w: &mut [u8]) -> isize {
    let r = BIG::new_ints(&rom::CURVE_ORDER);   
    let el = ceil(3*ceil(r.nbits(),8),2);
    let g = ECP2::generator();
    
    let salt=String::from("BLS-SIG-KEYGEN-SALT-");
    let info=String::from("");

    let mut prk: [u8;64]=[0;64];
    let mut okm: [u8;128]=[0;128];

    let hlen=ecp::HASH_TYPE;

    hmac::hkdf_extract(hmac::MC_SHA2,hlen,&mut prk,Some(&salt.as_bytes()),ikm);
    hmac::hkdf_expand(hmac::MC_SHA2,hlen,&mut okm,el,&prk[0 .. hlen],&info.as_bytes());

    let mut dx = DBIG::frombytes(&okm[0 .. el]);
    let mut sc = dx.dmod(&r);
    sc.tobytes(s);

    pair::g2mul(&g, &sc).tobytes(w,true);  // true for public key compression
    return BLS_OK;
}

/* Sign message m using private key s to produce signature sig */

pub fn core_sign(sig: &mut [u8], m: &[u8], s: &[u8]) -> isize {
    let d = bls_hash_to_point(m);
    let sc = BIG::frombytes(&s);
    pair::g1mul(&d, &sc).tobytes(sig, true);
    return BLS_OK;
}

/* Verify signature given message m, the signature sig, and the public key w */

pub fn core_verify(sig: &[u8], m: &[u8], w: &[u8]) -> isize {
    let hm = bls_hash_to_point(m);

    let mut d = ECP::frombytes(&sig);
    if !pair::g1member(&d) {
        return BLS_FAIL;
    }
    d.neg();

    let pk = ECP2::frombytes(&w);

    // Use new multi-pairing mechanism
    let mut r = pair::initmp();
    //    pair::another(&mut r,&g,&d);

    unsafe {
        pair::another_pc(&mut r, &G2_TAB, &d);
    }
    pair::another(&mut r, &pk, &hm);
    let mut v = pair::miller(&mut r);

    //.. or alternatively
    //    let mut v = pair::ate2(&g, &d, &pk, &hm);

    v = pair::fexp(&v);
    if v.isunity() {
        return BLS_OK;
    }
    return BLS_FAIL;
}
