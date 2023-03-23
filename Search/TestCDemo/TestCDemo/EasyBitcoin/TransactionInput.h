// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_TRANSACTIONINPUT_H
#define EASYBITCOIN_TRANSACTIONINPUT_H


#include "BtcPrivateKey.h"
#include "stdint.h"

struct TransactionInput
{
    /*!
     * @param reversePrevHash reversed hash of the transaction of the input
     * @param outputIndex index of the input (output index of the tx)
     * @param script script of the input
     * @param value value of the input
     * @param sequence 0xffffffff, could be used to replace tx later
     * @param isSigned if the script is the output script or the signed input script
     */
    TransactionInput(const ByteArray &reversePrevHash,
                     uint32_t outputIndex,
                     const ByteArray &prevOutScript,
                     uint64_t value,
                     const ByteArray &script = ByteArray(),
                     uint32_t sequence = 0xffffffff);

    ByteArray reversePrevHash;
    uint32_t outputIndex;
    ByteArray script;
    ByteArray prevOutScript;
    uint32_t sequence;
    uint64_t value;

    /*!
     * @return if the tx pays to the owner of the key with the given hash
     */
    bool isPayToPubKeyHash();

    /*!
     * @return pubKeyHash of the key that can sign the tx
     */
    ByteArray getPubKeyHash();
};


#endif //EASYBITCOIN_TRANSACTIONINPUT_H
