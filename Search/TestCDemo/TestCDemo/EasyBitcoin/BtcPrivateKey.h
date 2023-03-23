// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_PRIVATEKEY_H
#define EASYBITCOIN_PRIVATEKEY_H


#include "ByteArray.h"
#include "BtcPublicKey.h"

#include "string"

class BtcPrivateKey : public ByteArray
{
public:

    /*
     * will initialize a new random key
     */
    BtcPrivateKey();

    /*!
     * @param key private key binary representation ( = fromBase58Check(WIF))
     */
    BtcPrivateKey(const ByteArray &key);

    /*!
     * @param wifKey wallet import format key
     */
    BtcPrivateKey(const std::string &wifKey);

    /*!
     * @return compressed or uncompressed public key
     */
    BtcPublicKey getPublicKey() const;

    /*!
     * @return the private key as WIF (wallet import format) string
     */
    std::string getWIF() const;

    /*!
     * @param hash data to sign
     * @return signed data
     */
    ByteArray sign(const ByteArray &hash) const;

private:
    bool compressed;
};


#endif //EASYBITCOIN_PRIVATEKEY_H
