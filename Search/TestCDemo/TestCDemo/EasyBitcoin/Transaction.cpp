// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#include <stdexcept>

#include "ByteArray.h"
#include "Transaction.h"
#include "Crypto.h"
#include "Constants.h"
#include "ScriptExecutor.h"

void Transaction::addInput(const TransactionInput &inp)
{
    inputs.push_back(inp);
}

void Transaction::addOutput(const TransactionOutput &out)
{
    outputs.push_back(out);
}

ByteArray Transaction::getHashAllForInput(std::vector<TransactionInput>::size_type inputNumber)
{
    ByteArray ret;

    ret += Conversions::fromUInt32(1);
    ret += Conversions::fromVarInt(inputs.size());

    for (std::vector<TransactionInput>::size_type inp = 0; inp < inputs.size(); inp++)
    {
        ret += inputs[inp].reversePrevHash;
        ret += Conversions::fromUInt32(inputs[inp].outputIndex);
        if (inp == inputNumber)
        {
            ret += Conversions::fromVarInt(inputs[inp].prevOutScript.size());
            ret += inputs[inp].prevOutScript;
        }
        else
        {
            ret += Conversions::fromVarInt(0);
        }
        ret += Conversions::fromUInt32(inputs[inp].sequence);
    }

    ret += Conversions::fromVarInt(outputs.size());

    for (std::vector<TransactionInput>::size_type out = 0; out < inputs.size(); out++)
    {
        ret += Conversions::fromUInt64(outputs[out].value);
        ret += Conversions::fromVarInt(outputs[out].scriptPubKey.size());
        ret += outputs[out].scriptPubKey;
    }

    ret += Conversions::fromUInt32(0);
    ret += Conversions::fromUInt32(1);

    return ret.sha256().sha256();
}

void Transaction::signPubKeyHashInput(std::vector<TransactionInput>::size_type inputNumber,
                                      const BtcPrivateKey &privKey)
{
    BtcPublicKey pubKey = privKey.getPublicKey();

    if (pubKey.sha256().ripemd160() != inputs[inputNumber].getPubKeyHash())
        throw std::runtime_error("Private key does not belong to public key hash");

    ByteArray signature = Crypto::sign(privKey, getHashAllForInput(inputNumber));

    inputs[inputNumber].script = ByteArray();
    inputs[inputNumber].script += signature.size() + 1;
    inputs[inputNumber].script += signature;
    inputs[inputNumber].script += SIGHASH_ALL;
    inputs[inputNumber].script += pubKey.size();
    inputs[inputNumber].script += pubKey;
}

bool Transaction::isSigned()
{
    for (size_t inp = 0; inp < inputs.size(); ++inp)
    {
        try
        {
            ScriptExecutor sce(*this, inp);
            sce.run();
            if(sce.getState() == INVALID)
                return false;
        }
        catch(std::exception e)
        {
            return false;
        }
    }
    return true;
}

ByteArray Transaction::serializeTransaction()
{
    ByteArray ret;

    ret += Conversions::fromUInt32(1);
    ret += Conversions::fromVarInt(inputs.size());

    for (std::vector<TransactionInput>::size_type inp = 0; inp < inputs.size(); inp++)
    {
        ret += inputs[inp].reversePrevHash;
        ret += Conversions::fromUInt32(inputs[inp].outputIndex);
        ret += Conversions::fromVarInt(inputs[inp].script.size());
        ret += inputs[inp].script;
        ret += Conversions::fromUInt32(inputs[inp].sequence);
    }

    ret += Conversions::fromVarInt(outputs.size());

    for (std::vector<TransactionInput>::size_type out = 0; out < inputs.size(); out++)
    {
        ret += Conversions::fromUInt64(outputs[out].value);
        ret += Conversions::fromVarInt(outputs[out].scriptPubKey.size());
        ret += outputs[out].scriptPubKey;
    }

    ret += Conversions::fromUInt32(0);

    return ret;
}
