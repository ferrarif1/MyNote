// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_BTCPUBLICKEY_H
#define EASYBITCOIN_BTCPUBLICKEY_H


#include "ByteArray.h"
#include "Conversions.h"

#include <string>

class BtcPublicKey : public ByteArray
{
public:

    /*!
     * @param pubKey compressed or uncompressed EC public key
     */
    BtcPublicKey(const ByteArray &pubKey);

    /*!
     * @return returns if the key is compressed
     */
    bool isCompressed() const;

    /*!
     * @return the Base58Check encoded address belonging to the key
     */
    std::string getAddress() const;

    /*
     * @param hash the signed data (typically a hash)
     * @param sig signature of data
     * @return true if signature is valid, otherwise false
     */
    bool checkSig(ByteArray hash, ByteArray sig);
};


#endif //EASYBITCOIN_BTCPUBLICKEY_H
