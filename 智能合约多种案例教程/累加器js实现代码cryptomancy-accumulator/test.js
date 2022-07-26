var Format = require("cryptomancy-format");
var Source = require("cryptomancy-source");
var Acc = require(".");
var nThen = require("nthen");
var assert = require("assert");

var randomTokens = function (n) {
    var junk = [];

    var secure = Source.bytes.secure();
    var x = n;

    // generate some junk which should not be found in the accumulator
    while (x--) { junk.push(secure(32)); }

    return junk;
};

nThen(function (w) {
    // check consistency of sync and async flavours of prime generation
    var u8 = Format.decodeUTF8('pewpewpew');
    Acc.hashToPrime(u8, w(function (err, prime) {
        if (err) { throw new Error(err); }
        var prime2 = Acc.hashToPrime.sync(u8);
        assert.equal(Format.encode64(prime),
            Format.encode64(prime2));
    }));
}).nThen(function (w) {
    // check that sync and async key generation are equivalent as well
    // use a deterministic source
    var source1 = Source.bytes.deterministic(5);
    var source2 = Source.bytes.deterministic(5);

    Acc.genkeys(source1, w(function (err, keys1) {
        var keys2 = Acc.genkeys.sync(source2);
        var N1 = Format.encode64(keys1.N);
        var N2 = Format.encode64(keys2.N);
        assert.equal(N1, N2);
    }));
}).nThen(function () {
    // check synchronous public accumulation and verification
    var source = Source.bytes.deterministic(5);
    var keys = Acc.genkeys.sync(source);

    var items = [
        'pewpew',
        'bangbang',
        'ansuz',
        'borb',
        'blammo',
    ];
    var u8_items = items.map(Format.decodeUTF8);
    var result = Acc.publicly.sync(keys, u8_items);

    assert(Acc.verify.sync(keys, result.acc, result.witnesses[0], u8_items[0]));
}).nThen(function (w) {
    // check async public accumulation and verification
    var done = w();

    var source = Source.bytes.deterministic(5);
    var items = [
        'pewpew',
        'bangbang',
        'ansuz',
        'borb',
        'blammo',
    ];
    var u8_items = items.map(Format.decodeUTF8);

    var keys;
    var result;
    nThen(function (w) {
        Acc.genkeys(source, w(function (err, k) {
            if (err) { throw new Error(err); }
            keys = k;
        }));
    }).nThen(function () {
        result = Acc.publicly.sync(keys, u8_items);
        Acc.verify(
            keys,
            result.acc,
            result.witnesses[0],
            u8_items[0], function (err, bool) {
                if (err) { throw new Error(err); }
                assert(bool);
                done();
            });
    });
}).nThen(function () {
    // check that public and private accumulators are equivalent

    // check synchronous public accumulation and verification
    var source = Source.bytes.deterministic(5);
    var keys = Acc.genkeys.sync(source);

    var items = [
        'pewpew',
        'bangbang',
        'ansuz',
        'borb',
        'blammo',
    ];
    var u8_items = items.map(Format.decodeUTF8);
    var pubResult = Acc.publicly.sync(keys, u8_items);
    var privResult = Acc.secretly.sync(keys, u8_items);

    var pubAcc = Format.encode64(pubResult.acc);
    var privAcc = Format.encode64(privResult.acc);

    assert.equal(pubAcc, privAcc);

    pubResult.witnesses.forEach(function (witness, i) {
        var pubWit = Format.encode64(witness);
        var privWit = Format.encode64(privResult.witnesses[i]);
        assert.equal(pubWit, privWit);
    });

    var junk = randomTokens(2 /*100*/);

    privResult.witnesses.forEach(function (witness, i) {
        assert(Acc.verify.sync(keys, privResult.acc, witness, u8_items[i]));

        // check that none of the witnesses work for each bit of junk
        junk.forEach(function (j) {
            assert.equal(false,
                Acc.verify.sync(keys, privResult.acc, witness, j));
        });
    });
});


