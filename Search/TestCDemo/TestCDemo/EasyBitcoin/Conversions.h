// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_CONVERSIONS_H
#define EASYBITCOIN_CONVERSIONS_H

#include <string>
#include <stdint.h>

#include "ByteArray.h"
#include "Base58CheckDecode.h"

namespace Conversions
{
    /*!
     * Converts hex std::string to ByteArray, if the string has an odd size a '0' will be appended.
     *
     * @param hex hex string
     * @see ByteArray
     * @return ByteArray of the converted hex string
     */
    ByteArray fromHex(const std::string &hex);

    /*!
     * Encodes a ByteArray to hex string
     * @param bytes data to encode
     * @return hex encoded data
     */
    std::string toHex(const ByteArray &bytes);

    /*!
     * Converts base58 string to ByteArray
     * @param base58 string with base58 encoded data
     * @return ByteArray with the converted data
     */
    ByteArray fromBase58(const std::string &base58);

    /*!
     * Converts base58 string to ByteArray and performs signature check (throws runtime_error if it fails)
     * @param base58 string with base58 encoded data
     * @return struct with version and data
     */
    Base58CheckDecoded fromBase58Check(const std::string &base58);

    /*!
     * Converts base58 string to ByteArray and performs signature check (throws runtime_error if it fails)
     * @param base58 string with base58 encoded data
     * @param version expected version byte (first byte)
     * @return ByteArray with the converted data
     */
    ByteArray fromBase58Check(const std::string &base58, Byte version);

    /*!
     * Encodes ByteArray base58
     * @param data data that will be encoded
     * @return string with base58 encoded data
     */
    std::string toBase58(const ByteArray &data);

    /*!
     * Encodes data base58 and adds hash for checking integrity
     * @param data data that will be encoded
     * @param version version byte (first byte) of the resulting string
     * @return base58 encoded data with hash
     */
    std::string toBase58Check(ByteArray data, Byte version);

    /*!
     * @param num 16 bit integer that will be encoded to ByteArray
     * @return byte representation of num
     */
    ByteArray fromUInt16(uint16_t num);

    /*!
     * @param num 32 bit integer that will be encoded to ByteArray
     * @return byte representation of num
     */
    ByteArray fromUInt32(uint32_t num);

    /*!
     * @param num 64 bit integer that will be encoded to ByteArray
     * @return byte representation of num
     */
    ByteArray fromUInt64(uint64_t num);

    /*!
     * @see https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
     * @param num integer that will be encoded
     * @return 1-9 bytes VarInt representation on num
     */
    ByteArray fromVarInt(uint64_t num);

    /*!
     * @param data Byte representation of an uint16 (min. 2 Bytes, the first two bytes will be converted, remaining Bytes will be ignored)
     * @return converted uint16
     */
    uint16_t toUInt16(const ByteArray &data);

    /*!
     * @param data Byte representation of an uint32 (min. 4 Bytes, the first two bytes will be converted, remaining Bytes will be ignored)
     * @return converted uint16
     */
    uint32_t toUInt32(const ByteArray &data);

    /*!
     * @param data Byte representation of an uint64 (min. 8 Bytes, the first two bytes will be converted, remaining Bytes will be ignored)
     * @return converted uint16
     */
    uint64_t toUInt64(const ByteArray &data);

    /*!
     * @param inp ByteArray that will be reversed
     * @return reversed ByteArray
     */
    ByteArray reverse(ByteArray inp);

    /*/
     * @param data varInt as ByteArray from bitcoin script (little-endian, least significant bit = sign)
     * @return decoded integer
     */
    int64_t toScriptVarInt(const ByteArray& data);

    /*
     * @param val integer that will be encoded for script (varInt)
     * @return encoded int
     */
    ByteArray fromScriptVarInt(int64_t val);

    /*!
     * @param s String that will be converted to byte-array (char[] -> unsigned char[])
     * @return strings as ByteArray
     */
    ByteArray fromString(const std::string &s);

    /*!
     * @param data ByteArray that will be converted to std::string
     * @return the resulting string
     */
    std::string toString(const ByteArray &data);
};


#endif //EASYBITCOIN_CONVERSIONS_H
