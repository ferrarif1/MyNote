// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_BASE58CHECKDECODE_H
#define EASYBITCOIN_BASE58CHECKDECODE_H

#include "ByteArray.h"

struct Base58CheckDecoded
{
    ByteArray data;
    Byte version;
};

#endif //EASYBITCOIN_BASE58CHECKDECODE_H
