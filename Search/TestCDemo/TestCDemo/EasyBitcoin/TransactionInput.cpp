// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#include <stdexcept>
#include <inttypes.h>

#include "TransactionInput.h"
#include "Constants.h"

TransactionInput::TransactionInput(const ByteArray &reversePrevHash,
                                   uint32_t outputIndex,
                                   const ByteArray &prevOutScript,
                                   uint64_t value,
                                   const ByteArray &script,
                                   uint32_t sequence)
        : reversePrevHash(reversePrevHash),
          outputIndex(outputIndex),
          prevOutScript(prevOutScript),
          sequence(sequence),
          value(value),
          script(script)
{
}

bool TransactionInput::isPayToPubKeyHash()
{
    if (prevOutScript.size() != 25)
        return false;

    if (prevOutScript[0] != OP_DUP)
        return false;

    if (prevOutScript[1] != OP_HASH160)
        return false;

    if (prevOutScript[2] != 0x14)
        return false;

    if (prevOutScript[23] != OP_EQUALVERIFY)
        return false;

    return prevOutScript[24] == OP_CHECKSIG;
}

ByteArray TransactionInput::getPubKeyHash()
{
    if (!isPayToPubKeyHash())
        throw std::runtime_error("Transaction isn't PayToPubKeyHash");

    ByteArray ret;
    ret.insert(ret.end(), prevOutScript.begin() + 3, prevOutScript.begin() + 23);

    return ret;
}