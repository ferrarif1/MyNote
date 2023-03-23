// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#ifndef EASYBITCOIN_BYTEARRAY_H
#define EASYBITCOIN_BYTEARRAY_H

#include <vector>
#include <string>
#include <inttypes.h>

class ByteArray;
typedef unsigned char Byte;

class ByteArray : public std::vector<Byte>
{
public:
    /*!
     * initializes empty ByteArray
     */
    ByteArray() : std::vector<Byte>()
    {
    };

    /*!
     * initializes ByteArray of given length filled with 0x00
     * @param len length of ByteArray
     */
    ByteArray(std::vector<Byte>::size_type len) : std::vector<Byte>(len)
    {
    };

    /*!
     * initializes a ByteArray using a raw array of bytes
     * @param data pointer to first element of input array
     * @param len size of the array CAUTION: if too height SIGSEV may occur (only use if necessary e.g. to read from sockets)
     */
    ByteArray(const Byte * data, size_t len);

    /*!
     * appends ByteArray
     * @param other ByteArray to append to this
     */
    void operator+=(const ByteArray &other);

    /*!
     * appends single Byte
     * @param other Byte to append to this
     */
    void operator+=(const Byte &other);

    /*!
     * appends ByteArray and returns result
     * @param other ByteArray to append
     * @return this and other concatenated
     */
    ByteArray operator+(const ByteArray &other) const;

    /*
     * appends one byte to a byte array and returns the result
     * @param other byte to append to this
     * @return byte array
     */
    ByteArray operator+(const Byte other) const;

    /*!
     * encodes ByteArray to a hex string
     * @return hex representation
     */
    std::string toHex() const;

    /*!
     * encodes ByteArray to base58
     * @return base58 representation
     */
    std::string toBase58() const;

    /*!
     * encodes ByteArray to base58 and adds checksum and version byte
     * @param version version byte
     * @return base58check representation
     */
    std::string toBase58Check(Byte version) const;

    /*!
     * @return sha256 hash of ByteArray
     */
    ByteArray sha256() const;

    /*!
     * @return ripemd160 hash of ByteArray
     */
    ByteArray ripemd160() const;

    /*!
     * @param begin first byte of the section in the array
     * @param len length of the section that will be copied
     * @return section defined by begin and len (out of bounds error may be thrown)
     */
    ByteArray getSection(ByteArray::size_type begin, ByteArray::size_type len);

    /*!
     * @return first two bytes converted to uint16
     */
    uint16_t toUInt16();

    /*!
     * @return first four bytes converted to uint32
     */
    uint32_t toUInt32();

    /*!
     * @return first eight bytes converted to uint64
     */
    uint64_t toUInt64();
};


#endif //EASYBITCOIN_BYTEARRAY_H
