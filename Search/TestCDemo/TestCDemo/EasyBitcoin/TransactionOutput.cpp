// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#include <stdexcept>

#include "TransactionOutput.h"
#include "Conversions.h"
#include "Constants.h"

TransactionOutput::TransactionOutput(ByteArray scriptPubKey, uint64_t value)
{
    this->scriptPubKey = scriptPubKey;
    this->value = value;
}

TransactionOutput::TransactionOutput(std::string addr, uint64_t value)
{
    Base58CheckDecoded dec = Conversions::fromBase58Check(addr);
    this->value = value;

    switch (dec.version)
    {
        case 0x00:
            if (dec.data.size() != 20)
                throw std::runtime_error("This is not a valid address: " + addr);

            this->scriptPubKey += OP_DUP;
            this->scriptPubKey += OP_HASH160;
            this->scriptPubKey += 0x14;
            this->scriptPubKey += dec.data;
            this->scriptPubKey += OP_EQUALVERIFY;
            this->scriptPubKey += OP_CHECKSIG;

            break;

        case 0x05:
            if (dec.data.size() != 20)
                throw std::runtime_error("This is not a valid address: " + addr);

            this->scriptPubKey += OP_HASH160;
            this->scriptPubKey += 0x14;
            this->scriptPubKey += dec.data;
            this->scriptPubKey += OP_EQUAL;
            break;

        default:
            throw std::runtime_error("Address version not supported");
    }


}