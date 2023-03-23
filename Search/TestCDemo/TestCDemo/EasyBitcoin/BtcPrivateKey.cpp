// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#include <stdexcept>

#include "Crypto.h"
#include "Conversions.h"
#include "BtcPublicKey.h"
#include "BtcPrivateKey.h"
#include "Constants.h"

BtcPrivateKey::BtcPrivateKey() : ByteArray()
{
    ByteArray pk = Crypto::newPrivateKey();
    this->insert(this->begin(), pk.begin(), pk.end());
    this->compressed = true;
}

BtcPrivateKey::BtcPrivateKey(const ByteArray &key) : ByteArray()
{
    if (key.size() == EC_PRIVATE_KEY_LENGTH) {
        this->insert(this->begin(), key.begin(), key.end());
        this->compressed = false;
        return;
    }
    else if (key.size() == EC_PRIVATE_KEY_LENGTH + 1) {
        if (key.back() == 1) {
            this->insert(this->begin(), key.begin(), key.begin() + EC_PRIVATE_KEY_LENGTH);
            this->compressed = true;
            return;
        }
    }

    throw std::runtime_error("Wrong key size!");
}

BtcPrivateKey::BtcPrivateKey(const std::string &wifKey)
{
    ByteArray key = Conversions::fromBase58Check(wifKey, 0x80);
    if (key.size() == EC_PRIVATE_KEY_LENGTH)
    {
        this->insert(this->begin(), key.begin(), key.end());
        this->compressed = false;
        return;
    }
    else if (key.size() == EC_PRIVATE_KEY_LENGTH + 1)
    {
        if (key.back() == 1)
        {
            this->insert(this->begin(), key.begin(), key.begin() + EC_PRIVATE_KEY_LENGTH);
            this->compressed = true;
            return;
        }
    }

    throw std::runtime_error("Wrong key size!");
}

BtcPublicKey BtcPrivateKey::getPublicKey() const
{
    if (compressed) {
        return Crypto::privKeyToCompressedPubKey(*this);
    }
    else {
        return Crypto::privKeyToPubKey(*this);
    }
}

std::string BtcPrivateKey::getWIF() const
{
    if(compressed)
        return (*this + 0x01).toBase58Check(0x80);
    else
        return this->toBase58Check(0x80);
}

ByteArray BtcPrivateKey::sign(const ByteArray &hash) const
{
    return Crypto::sign(*this, hash);
}

