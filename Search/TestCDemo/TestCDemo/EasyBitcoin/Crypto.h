// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_CRYPTO_H
#define EASYBITCOIN_CRYPTO_H

#include "ByteArray.h"

namespace Crypto
{
    /*!
     * hashes binary data using SHA256
     * @param input binary data that will be hashed
     * @return ByteArray containing the hash
     */
    ByteArray sha256(const ByteArray &input);

    /*!
     * hashes binary data using RIPEMD160
     * @param input binary data that will be hashed
     * @return ByteArray containing the hash
     */
    ByteArray ripemd160(const ByteArray &input);

    /*
     * @return random private ECDSA key
     */
    ByteArray newPrivateKey();

    /*!
     * Signs binary data using ECDSA
     * @param privKey the private key that should be used
     * @param hash binary data that will be signed
     * @return signed data
     */
    ByteArray sign(const ByteArray &privKey, const ByteArray hash);

    /*!
     * Derives the public key from the private key
     * @param privKey private key
     * @return public key
     */
    ByteArray privKeyToPubKey(const ByteArray &privKey);

    /*!
     * Derives the compressed public key from the private key
     * @param privKey private key
     * @return compressed public key
     */
    ByteArray privKeyToCompressedPubKey(const ByteArray &privKey);

    /*
     * Checks if an ECDSA signature is valid
     * @param hash the signed data (typically a hash)
     * @param sig signature of data
     * @return true if signature is valid, otherwise false
     */
    bool checkSig(const ByteArray &pubKey, const ByteArray &hash, const ByteArray &sig);
};


#endif //EASYBITCOIN_CRYPTO_H
