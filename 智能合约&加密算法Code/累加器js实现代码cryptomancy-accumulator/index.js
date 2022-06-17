/*  A cryptographic accumulator
    based on https://github.com/davidlazar/accumulator
*/

var Format = require("cryptomancy-format");
var Prime = require("cryptomancy-prime");
var Source = require("cryptomancy-source");
var Util = require("cryptomancy-util");
var nThen = require("nthen");
var bigint = require("jsbn").BigInteger;

var EXPONENT = 9; //10;

var PRIME_BITS = Math.pow(2, EXPONENT); //1024; // 1024 is 2^10
var G = new bigint('' + (Math.pow(2, EXPONENT) + 1)); //'65537'); // 2^10+1

var bigOne = bigint.ONE;

var Acc = module.exports;

/*  hashToPrime
    we have a prime generator which accepts any form of entropy,
    but for the purposes of this library we need the source to be deterministic
    such that when we pass in a value, we are always guaranteed to get
    the same prime.

    we do, however, want flavours which are sync or async, as well as
    versions which return bigints or Uint8Arrays. our library returns
    bigints, and for internal use we ought to be able to avoid the extra
    conversion to Uint8Arrays.
*/

// start with the internal async version
// accepts a Uint8Array and a callback
var _hashToPrime = function (U8, cb) {
    // initialize a PRNG with the Uint8Array as a seed
    var source = Source.bytes.deterministic(U8);
    // use the global setting for the number of bits (1024)
    Prime(source, PRIME_BITS, function (err, bi) {
        if (err) { return void cb(err); }
        if ((bi instanceof bigint) !== true) { return void cb('INVALID_TYPE_RETURNED'); }
        cb(void 0, bi);
    });
};

// now the sync flavour
// can throw?
_hashToPrime.sync = function (U8) {
    var source = Source.bytes.deterministic(U8);
    return Prime.sync(source, PRIME_BITS);
};

// export the version which accepts and exports a Uint8Array
Acc.hashToPrime = function (U8, cb) {
    _hashToPrime(U8, function (err, bi) {
        if (err) { return void cb(err); }
        cb(void 0, Format.decodeBigInt(bi));
    });
};

// export a sync flavour as well
Acc.hashToPrime.sync = function (U8) {
    return Format.decodeBigInt(_hashToPrime.sync(U8));
};

/*  Key generation

    we want sync and async versions here as well.
    the only async operation is prime generation,
    so let's separate that part from the rest of the derivation
*/

// async flavour
var genPrime = function (source, cb) {
    Prime(source, PRIME_BITS, cb);
};

// sync flavour
genPrime.sync = function (source) {
    return Prime.sync(source, PRIME_BITS);
};

// async pair generation
var genPair = function (source, cb) {
    var ret = {};
    nThen(function (w) {
        ['P', 'Q'].forEach(function (k) {
            genPrime(source, w(function (err, p) {
                if (err) { w.abort(); return void cb(err); }
                ret[k] = p;
            }));
        });
    }).nThen(function () {
        return cb(void 0, ret);
    });
};

// sync pair
genPair.sync = function (source) {
    return {
        P: genPrime.sync(source),
        Q: genPrime.sync(source),
    };
};

// the synchronous bit that transforms P and Q into a proper key
var usePair = function (P, Q) {
    var pminus1 = P.subtract(bigint.ONE);
    var qminus1 = Q.subtract(bigint.ONE);
    var totient = pminus1.multiply(qminus1);
    var g = G.gcd(totient);
    if (g.compareTo(bigOne) === 0) {
        return { // privateKey
            P: P,
            Q: Q,
            N: Format.decodeBigInt(P.multiply(Q)),
            Totient: Format.decodeBigInt(totient)
        };
    }
    return;
};

// generate keys by composing the internal functions defined above
var genkeys = Acc.genkeys = function (source, cb) {
    var P, Q;
    nThen(function (w) {
        genPair(source, w(function (err, pair) {
            if (err) { w.abort(); return void cb(err); }
            P = pair.P;
            Q = pair.Q;
        }));
    }).nThen(function () {
        var keys = usePair(P, Q);
        if (!keys) { return void genkeys(source, cb); }
        cb(void 0, keys);
    });
};

// same thing, but synchronous
genkeys.sync = function (source) {
    var pair = genPair.sync(source);
    var keys = usePair(pair.P, pair.Q);
    if (!keys) { return genkeys.sync(source); }
    return keys;
};

// There are two ways of generating accumulators
// one uses the private keys
// one uses only the public key (N)

// given all the same information, they should be equivalent

// synchronous functionality present in either flavour of 'secretly'
var _secretly = function (keys, Primes) {
    var N = Format.encodeBigInt(keys.N);
    var Totient = Format.encodeBigInt(keys.Totient);

    var exp = bigOne.clone();
    Primes.forEach(function (prime) {
        exp = exp.multiply(prime);
        exp = exp.mod(Totient);
    });
    var acc = G.modPow(exp, N);

    var Witnesses = Primes.map(function (prime) {
        var inv = prime.modInverse(Totient).multiply(exp).mod(Totient);
        return G.modPow(inv, N);
    });
    return {
        acc: Format.decodeBigInt(acc),
        primes: Primes.map(Format.decodeBigInt),
        witnesses: Witnesses.map(Format.decodeBigInt),
    };
};

Acc.secretly = function (keys, items, cb) {
    var CB = Util.once(cb);
    var Primes = [];
    nThen(function (w) {
        items.forEach(function (item, i) {
            _hashToPrime(item, w(function (err, p) {
                if (err) { w.abort(); return void CB(err); }
                Primes[i] = p;
            }));
        });
    }).nThen(function () {
        CB(void 0, _secretly(keys, Primes));
    });
};

Acc.secretly.sync = function (keys, items) {
    var Primes = items.map(_hashToPrime.sync);
    return _secretly(keys, Primes);
};

// synchronous functionality present in either flavour of 'publicly'
var _publicly = function (keys, Primes) {
    var N = Format.encodeBigInt(keys.N);
    var acc = G;
    Primes.forEach(function (prime) {
        acc = acc.modPow(prime, N);
    });
    var Witnesses = Primes.map(function (_, i) {
        var witness = G;
        Primes.forEach(function (prime, j) {
            if (j === i) { return; }
            witness = witness.modPow(prime, N);
        });
        return witness;
    });
    return {
        acc: Format.decodeBigInt(acc),
        primes: Primes.map(Format.decodeBigInt),
        witnesses: Witnesses.map(Format.decodeBigInt),
    };
};

Acc.publicly = function (keys, items, cb) {
    var CB = Util.once(cb);
    var Primes = [];
    nThen(function (w) {
        items.forEach(function (item, i) {
            _hashToPrime(item, w(function (err, p) {
                if (err) { w.abort(); return void CB(err); }
                Primes[i] = p;
            }));
        });
    }).nThen(function () {
        CB(void 0, _publicly(keys, Primes));
    });
};

Acc.publicly.sync = function (keys, items) {
    var Primes = items.map(_hashToPrime.sync);
    return _publicly(keys, Primes);
};

var _verify = function (keys, acc, u8_witness, R) {
    var N = Format.encodeBigInt(keys.N);
    var C = Format.encodeBigInt(acc);
    var S = Format.encodeBigInt(u8_witness);

    var U = S.modPow(R, N);
    return U.compareTo(C) === 0;
};

// FIXME too many parameters
Acc.verify = function (keys, acc, u8_witness, item, cb) { // jshint ignore:line
    _hashToPrime(item, function (err, R) {
        if (err) { return void cb(err); }
        cb(void 0, _verify(keys, acc, u8_witness, R));
    });
};

Acc.verify.sync = function (keys, acc, u8_witness, item) {
    var R = _hashToPrime.sync(item);
    return _verify(keys, acc, u8_witness, R);
};

