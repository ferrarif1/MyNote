// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#include "Crypto.h"

#include "Constants.h"

#include "../include/openssl/sha.h"
#include "../include/openssl/ripemd.h"
#include "../include/openssl/ssl.h"
#include <stdexcept>

ByteArray Crypto::sha256(const ByteArray &input)
{
    ByteArray ret(SHA256_DIGEST_LENGTH);
    SHA256(&input[0], input.size(), &ret[0]);

    return ret;
}

ByteArray Crypto::ripemd160(const ByteArray &input)
{
    ByteArray ret(RIPEMD160_DIGEST_LENGTH);
    RIPEMD160(&input[0], input.size(), &ret[0]);

    return ret;
}

ByteArray Crypto::newPrivateKey()
{
    EC_KEY * key = EC_KEY_new_by_curve_name(NID_secp256k1);

    if(key == NULL)
        throw std::runtime_error("Error: can't create new key.");

    if(1 != EC_KEY_generate_key(key))
        throw std::runtime_error("Error: can't create new random key.");

    ByteArray privKey(EC_PRIVATE_KEY_LENGTH);

    BN_bn2bin(EC_KEY_get0_private_key(key), &privKey[0]);

    return privKey;
}


ByteArray Crypto::sign(const ByteArray &privKey, const ByteArray hash)
{
    // I found 74 as the max. sig. len., but can't confirm
    // if somebody can confirm this it would be great (then
    // I would add it as a constant.
    ByteArray signature(74);

    unsigned int sigSize;
    EC_KEY *key = EC_KEY_new_by_curve_name(NID_secp256k1);
    BIGNUM *bn = BN_bin2bn(&privKey[0], EC_PRIVATE_KEY_LENGTH, NULL);

    if(key == NULL || bn == NULL)
        throw std::runtime_error("Error: can't create key object.");

    EC_KEY_set_private_key(key, bn);
    ECDSA_sign(0, &hash[0], hash.size(), &signature[0], &sigSize, key);

    EC_KEY_free(key);
    BN_free(bn);

    signature.resize(sigSize);

    return signature;
}

ByteArray Crypto::privKeyToPubKey(const ByteArray &privKey)
{
    ByteArray pubKey(EC_PUBLIC_KEY_LENGTH);

    BIGNUM *privBn = BN_bin2bn(&privKey[0], EC_PRIVATE_KEY_LENGTH, NULL);
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
    EC_POINT *point = EC_POINT_new(group);
    BN_CTX *ctx = BN_CTX_new();

    EC_POINT_mul(group, point, privBn, NULL, NULL, ctx);
    EC_POINT_point2oct(group, point, POINT_CONVERSION_UNCOMPRESSED, &pubKey[0], EC_PUBLIC_KEY_LENGTH, ctx);

    BN_CTX_free(ctx);
    EC_POINT_free(point);
    EC_GROUP_free(group);
    BN_free(privBn);

    return pubKey;
}

ByteArray Crypto::privKeyToCompressedPubKey(const ByteArray &privKey)
{
    ByteArray pubKey(EC_COMPRESSED_PUBLIC_KEY_LENGTH);

    BIGNUM *privBn = BN_bin2bn(&privKey[0], EC_PRIVATE_KEY_LENGTH, NULL);
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
    EC_POINT *point = EC_POINT_new(group);
    BN_CTX *ctx = BN_CTX_new();

    EC_POINT_mul(group, point, privBn, NULL, NULL, ctx);
    EC_POINT_point2oct(group, point, POINT_CONVERSION_COMPRESSED, &pubKey[0], EC_COMPRESSED_PUBLIC_KEY_LENGTH, ctx);

    BN_CTX_free(ctx);
    EC_POINT_free(point);
    EC_GROUP_free(group);
    BN_free(privBn);

    return pubKey;
}

bool Crypto::checkSig(const ByteArray &pubKey, const ByteArray &hash, const ByteArray &sig)
{
    EC_KEY * eckey;
    EC_KEY * key;
    int res = 0;
    const Byte * pubKeyPointer = &pubKey[0];

    key = EC_KEY_new_by_curve_name(NID_secp256k1);
    eckey = key;
    o2i_ECPublicKey(&key, &pubKeyPointer, pubKey.size());

    if (key != NULL)
        res = ECDSA_verify(0, &hash[0], 32, &sig[0], sig.size(), key);
    else
        throw std::runtime_error("checkSig failed, pubKey invalid!");

    EC_KEY_free(eckey);

    return res == 1;
}
