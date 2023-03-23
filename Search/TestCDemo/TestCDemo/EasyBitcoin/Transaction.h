// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_TRANSACTION_H
#define EASYBITCOIN_TRANSACTION_H


#include <vector>
#include <stdint.h>

#include "TransactionInput.h"
#include "TransactionOutput.h"
#include "BtcPrivateKey.h"

class Transaction
{
public:

    /*!
     * adds input to transaction
     * @param inp input structure to add
     */
    void addInput(const TransactionInput &inp);

    /*!
     * adds output to transaction
     * @param out output structure that will be added
     */
    void addOutput(const TransactionOutput &out);

    /*!
     * @param inputNumber number for which input the hash will be generated
     * @return SIG_HASH_ALL hash of the tx
     * @see https://en.bitcoin.it/w/images/en/7/70/Bitcoin_OpCheckSig_InDetail.png
     */
    ByteArray getHashAllForInput(std::vector<TransactionInput>::size_type inputNumber);

    /*!
     * @param inputNumber input that will be signed
     * @param privKey key that will be used for signing
     */
    void signPubKeyHashInput(std::vector<TransactionInput>::size_type inputNumber, const BtcPrivateKey &privKey);

    /*!
     * @return true if all inputs are signed, false if not
     */
    bool isSigned();

    /*!
     * @return serialized transaction as ByteArray
     */
    ByteArray serializeTransaction();

    /*!
     * list of all inputs
     */
    std::vector<TransactionInput> inputs;

    /*!
     * list of all outputs
     */
    std::vector<TransactionOutput> outputs;
};


#endif //EASYBITCOIN_TRANSACTION_H
