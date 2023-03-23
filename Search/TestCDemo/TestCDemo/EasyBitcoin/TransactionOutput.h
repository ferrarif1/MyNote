// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_TRANSACTIONOUTPUT_H
#define EASYBITCOIN_TRANSACTIONOUTPUT_H


#include "ByteArray.h"

#include "stdint.h"
#include "string"

struct TransactionOutput
{
    TransactionOutput(std::string addr, uint64_t value);

    TransactionOutput(ByteArray scriptPubKey, uint64_t value);

    uint64_t value;
    ByteArray scriptPubKey;
};


#endif //EASYBITCOIN_TRANSACTIONOUTPUT_H
