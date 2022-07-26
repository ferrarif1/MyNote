# cryptomancy-accumulator

This module implements a cryptographic accumulator, which allows the holder of a private key to prove that a given token is contained within a set without revealing the contents of the set.

## API

Methods are all implemented with both synchronous and asynchronous flavours.

```javascript
// Import the library
var Acc = require("cryptomancy-accumulator");

// You'll need a source of entropy too
var Source = require("cryptomancy-source");

// You probably want cryptographically secure entropy for key generation...
var secure = Source.bytes.secure(); // a function...

// Finally, you'll most likely want to be able to convert formats
var Format = require("cryptomancy-format");

```

### Acc.genkeys(source, cb)

Generate a set of keys asynchronously.

```javascript
Acc.genkeys(secure, function (err, keys) {
    console.log(keys);
    /*
        'keys' is an object containing some large numbers,
        encoded as Uint8Arrays.

        keys include two large random primes P and Q
        which ought to be kept secret.

        N is the product of those primes.
        it acts as a public key.
        people will need it to verify your proofs

        Totient is derived from P and Q, and is a bit less sensitive
        than either, but you should still keep it secret!
    */
});
```

### Acc.genkeys.sync(source)

As above, but synchronous.

```javascript
var keys = Acc.genkeys(secure);
```

### Acc.hashToPrime(U8, cb)

You shouldn't need to use this function, but it's exposed anyway.

Call it with a Uint8Array and it will return a prime number encoded as a another Uint8Array.
Given the same input, it will yield the same prime.
This is important, as the verification function depends on its determinacy.

```javascript
var u8 = Format.decodeUTF8('pewpewpew');

Acc.hashToPrime(u8, function (err, function (err, prime) {
    console.log(prime);
});
```

### Acc.hashToPrime.sync(U8)

As above, but synchronous.

```javascript
var prime = Acc.hashToPrime(Format.decodeUTF8('pewpewpew'));
```

### Acc.secretly(keys, items, cb)

Create an accumulator and byproducts using your secret key

```javascript
var items = [
    'a',
    'list',
    'of',
    'secret',
    'words',
].map(function (item) {
    // remember that the accumulator is made from Uint8Arrays
    return Format.decodeUTF8(item);
});

Acc.secretly(keys, items, function (err, result) {
    console.log(result);

    /*  result is an object containing:

        acc: a Uint8Array representing a very large number
        composed of all the prime factors derived from your items.

        witnesses: an array of Uint8Arrays, each representing the
        aggregation of all but one of the items prime factors.
        the prime derived by `item[i]` has `witnesses[i]` as its complement.

        primes: you shouldn't need to use the primes, but they're
        returned anyway. also in Uint8Array form.
    */
});
```

### Acc.secretly.sync(keys, items)

As above, but synchronous.

```javascript
var result = Acc.secretly.sync(keys, items);
```

### Acc.publicly(keys, items, cb)

You can produce the same output as `Acc.secretly` using only the public key if you provide all the same inputs.

```javascript
Acc.publicly(keys, items, function (err, result) {
    console.log(result);
    // result should be exactly equivalent to that returned from 'privately'
});
```

### Acc.publicly.sync(keys, items)

As above, but synchronous.

```javscript
var result = Acc.publicly.sync(keys, items);
```

### Acc.verify(keys, acc, witness, item, cb)

The creator of an accumulator has a set of 'witnesses', which can be used as a proof that a particular prime is encoded within the accumulator.

```javascript
// as mentioned above, each 'witness' is basically the set-theoretic
// complement of a particular item's prime.

// verification checks that modular multiplication of the witness and item
// produces a value equal to that of the supplied accumulator.

// verification only requires 'N'
// don't go distributing your private keys
Acc.verify(keys, acc, witness, item, function (err, bool) {
    if (bool) {
        // the supplied witness proves that the supplied item
        // is indeed contained within the accumulator
    }

    // but you can't prove the negative
    // this lends the system some interesting properties for deniability
});
```

### Acc.verify.sync(keys, acc, witness, item)

As above, but synchronous.

```javascript
var bool = Acc.verify(keys, acc, witness, item);
if (bool) {
    // the witness proves that the item is present in acc
}
```

