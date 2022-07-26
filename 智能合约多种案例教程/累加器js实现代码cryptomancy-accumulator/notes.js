var bigint = require("jsbn").BigInteger;
var assert = require("assert");

var P = 3,
    Q = 5,
    N = P * Q,
    G = 17;

var bi = function (num) {
    return new bigint('' + num);
};

var product = function (A) {
    return A.reduce(function (a, b) { return a * b; });
};

var U = [7, 11, 13]; //= 1001
assert(product(U) === 1001);

var C = product(U) % N; // 1001 %  15
assert(C === 11);

// reveal one of the members of U
//var R = 7;

var S = product([11, 13]);
assert(S === 143); // the product of all the remaining elements in U

// given G and S (where N is publically known)
var Proof = Number(bi('' + G).modPow(bi(S), bi(N)).toString());

// Math.pow(G, S) % N; // mod(G^S, N)
assert(Proof === 8);

/*
C' = mod(P^R, N)
C' = 2
*/ 

var qminus1 = P - 1;
var pminus1 = Q - 1;
var totient = pminus1 * qminus1;

var exp = G;

[7, 11, 13].forEach(function (prime) {
    exp *= prime;
    exp %= totient;
}); //  exp = 1

// as above
//7 % 8 = 7
//7 * 11 % 8 = 5
//5 * 13  % 8 = 1

assert(exp === 1);

var primes = U;

var witness1 = function (i) {
    var prime = bi(primes[i]);
    var inv = prime
        .modInverse(bi(totient))
        .multiply(bi(exp))
        .mod(bi(totient));
    return Number((bi(G).modPow(inv, bi(N))).toString());
};

var wit1 = witness1(1);  // inv = 3
 // G.modPow(inv, N)
 // 8
assert(wit1 === 8);

// should be equivalent to
var witness2 = function (j) {
    var wit = bi(G);
    primes.forEach(function (prime, i) {
        if (i === j) { return; }
        wit = wit.modPow(bi(prime), bi(N));
    });
    return Number(wit.toString());
};

var wit2 = witness2(1);

// G.modPow(7, N).modPow(13, N); // 8
assert(wit2 === wit1);


// verification


// factoring elements out...

var C1 = product([7, 11, 13]) % N; // 11
//console.log(product([7, 11, 13]));
//console.log(C1);
assert(C1 === 11);

var C2 = product([7, 11]) % 15; // 2
assert(C2 === 2);

// to remove an element from C...
// need a function which transforms 11 into 2 given C and 13

// FIXME this doesn't work
var remove = function (C, _prime, totient) {
    var prime = bi(_prime);
    //var acc = bi(C);
    var tot = bi(totient);

    var inv = prime
        .modInverse(tot)
        .multiply(prime)
        .mod(tot);

    var result = bi(G).modPow(inv, bi(N));
    return Number(result.toString());
};

[7, 11, 13].forEach(function (prime, i, primes) {
    var C0 = product(primes) % N;

    // find the set of primes excluding this current prime
    var complement = primes.filter(function (n) {
        return n !== prime;
    });
    var C1 = product(complement) % N;

    console.log('product([%s]) % %s === %s (C0)', primes, N, C0);
    console.log('trying to remove %s from ', prime, primes);
    console.log('product([%s]) % %s === %s (C1)', complement, N, C1);
    //console.log(complement);


    //assert.equal(remove(C0, prime, totient), C1);

    var C2 = remove(C0, prime, totient);
    console.log("remove(%s, %s, %s) === %s (C2)", C0, prime, totient, C2);

    assert.equal(C1, C2);

    console.log();
});

//assert(remove(C1, 13, totient) === 2);


