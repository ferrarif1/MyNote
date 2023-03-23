// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_CONSTANTS_H
#define EASYBITCOIN_CONSTANTS_H

//key lengths
#define EC_PRIVATE_KEY_LENGTH           32
#define EC_PUBLIC_KEY_LENGTH            65
#define EC_COMPRESSED_PUBLIC_KEY_LENGTH 33

//OP codes
#define OP_FALSE                0x00
#define OP_PUSH_BEGIN           0x01
#define OP_PUSH_END             0x4b
#define OP_PUSHDATA1            0x4c
#define OP_PUSHDATA2            0x4d
#define OP_PUSHDATA4            0x4e
#define OP_1NEGATE              0x4f
#define OP_TRUE                 0x51
#define OP_2                    0x52
#define OP_16                   0x60

#define OP_NOP                  0x61
#define OP_IF                   0x63
#define OP_NOTIF                0x64
#define OP_ELSE                 0x67
#define OP_ENDIF                0x68
#define OP_VERIFY               0x69
#define OP_RETURN               0x6a

#define OP_TOALTSTACK           0x6b
#define OP_FROMALTSTACK         0x6c
#define OP_IFDUP                0x73
#define OP_DEPTH                0x74
#define OP_DROP                 0x75
#define OP_DUP                  0x76
#define OP_NIP                  0x77
#define OP_OVER                 0x78
#define OP_PICK                 0x79
#define OP_ROLL                 0x7a
#define OP_ROT                  0x7b
#define OP_SWAP                 0x7c
#define OP_TUCK                 0x7d
#define OP_2DROP                0x6d
#define OP_2DUP                 0x6e
#define OP_3DUP                 0x6f
#define OP_2OVER                0x70
#define OP_2ROT                 0x71
#define OP_2SWAP                0x72

#define OP_CAT                  0x7e
#define OP_SUBSTR               0x7f
#define OP_LEFT                 0x80
#define OP_RIGHT                0x81
#define OP_SIZE                 0x82

#define OP_INVERT               0x83
#define OP_END                  0x84
#define OP_OR                   0x85
#define OP_XOR                  0x86
#define OP_EQUAL                0x87
#define OP_EQUALVERIFY          0x88

#define OP_1ADD                 0x8b
#define OP_1SUB                 0x8c
#define OP_2MUL                 0x8d
#define OP_2DIV                 0x8e
#define OP_NEGATE               0x8f
#define OP_ABS                  0x90
#define OP_NOT                  0x91
#define OP_0NOTEQUAL            0x92
#define OP_ADD                  0x93
#define OP_SUB                  0x94
#define OP_MUL                  0x95
#define OP_DIV                  0x96
#define OP_MOD                  0x97
#define OP_LSHIFT               0x98
#define OP_RSHIFT               0x99
#define OP_BOOLAND              0x9a
#define OP_BOOLOR               0x9b
#define OP_NUMEQUAL             0x9c
#define OP_NUMEQUALVERIFY       0x9d
#define OP_NUMNOTEQUAL          0x9e
#define OP_LESSTHAN             0x9f
#define OP_GREATERTHAN          0xa0
#define OP_LESSTHANOREQUAL      0xa1
#define OP_GREATERTHANOREQUAL   0xa2
#define OP_MIN                  0xa3
#define OP_MAX                  0xa4
#define OP_WITHIN               0xa5

#define OP_RIPEMD160            0xa6
#define OP_SHA1                 0xa7
#define OP_SHA256               0xa8
#define OP_HASH160              0xa9
#define OP_HASH256              0xaa
#define OP_CODESEPARATOR        0xab
#define OP_CHECKSIG             0xac
#define OP_CHECKSIGVERIFY       0xad
#define OP_CHECKMULTISIG        0xae
#define OP_CHECKMULTISIGVERIFY  0xaf


//hashtypes
#define SIGHASH_ALL             0x00000001
#define SIGHASH_NONE            0x00000002
#define SIGHASH_SINGLE          0x00000003
#define SIGHASH_ANYONECANPAY    0x00000080

#endif //EASYBITCOIN_CONSTANTS_H
