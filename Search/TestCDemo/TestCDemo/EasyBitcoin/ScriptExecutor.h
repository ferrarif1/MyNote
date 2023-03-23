// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_SCRIPTEXECUTOR_H
#define EASYBITCOIN_SCRIPTEXECUTOR_H

#include "ByteArray.h"
#include "Transaction.h"

enum ScriptState
{
    VALID,
    INVALID,
    RUNNING
};

class ScriptExecutor
{
public:
    ScriptExecutor(const Transaction &t, size_t inputNumber);

    std::vector<ByteArray> getStack();
    bool run(bool onlyOneStep = false);
    ByteArray::size_type getPosition();
    ByteArray getScript();
    ScriptState getState();

private:
    std::vector<ByteArray> stack;
    std::vector<ByteArray> altStack;
    ByteArray script;
    Transaction t;
    size_t inputNumber;
    ByteArray::size_type position;
    ScriptState state;

    ByteArray::size_type findAfter(Byte term, ByteArray::size_type begin = 0);
};


#endif //EASYBITCOIN_SCRIPTEXECUTOR_H
