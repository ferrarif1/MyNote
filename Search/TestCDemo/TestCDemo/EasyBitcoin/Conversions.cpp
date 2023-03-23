// Copyright (c) 2015 Sebastian Geisler
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.


#include "Conversions.h"
#include "Crypto.h"

#include <stdexcept>
#include <iostream>
#include <algorithm>

ByteArray Conversions::fromHex(const std::string &hex)
{
    ByteArray ret(hex.size() / 2 + (hex.size() % 2));
    for (size_t i = 0; i < hex.size(); i += 1)
    {
        char charVal;
        char charCode = (char) std::tolower(hex[i]);
        if (charCode >= '0' && charCode <= '9')
        {
            charVal = charCode - '0';
        }
        else if (charCode >= 'a' && charCode <= 'f')
        {
            charVal = (char) (charCode - 'a' + 10);
        }
        else
        {
            throw std::runtime_error("A character in the given string wasn't HEX.");
        }
        if (i % 2 == 1)
        {
            ret[i / 2] += charVal;
        }
        else
        {
            ret[i / 2] += 16 * charVal;
        }
    }

    return ret;
}


std::string Conversions::toHex(const ByteArray &bytes)
{
    std::string base16 = "0123456789abcdef";
    std::string ret;

    for (ByteArray::const_iterator it = bytes.begin(); it != bytes.end(); it++)
    {
        ret.append(1, base16[(*it) / 16]);
        ret.append(1, base16[(*it) % 16]);
    }

    return ret;
}

ByteArray Conversions::fromBase58(const std::string &base58)
{
    ByteArray base256(base58.size() * 733 / 1000 + 1);

    std::string::const_iterator base58It = base58.begin();
    int zeroes = 0;

    while (base58It != base58.end() && *base58It == '1')
    {
        zeroes++;
        base58It++;
    }

    unsigned int carry;
    for (; base58It != base58.end(); base58It++)
    {
        if ((*base58It) >= '1' && (*base58It) <= '9')
        {
            carry = (unsigned int) ((*base58It) - '1');
        }
        else if ((*base58It) >= 'A' && (*base58It) <= 'H')
        {
            carry = (unsigned int) ((*base58It) - 'A' + 9);
        }
        else if ((*base58It) >= 'J' && (*base58It) <= 'N')
        {
            carry = (unsigned int) ((*base58It) - 'J' + 17);
        }
        else if ((*base58It) >= 'P' && (*base58It) <= 'Z')
        {
            carry = (unsigned int) ((*base58It) - 'P' + 22);
        }
        else if ((*base58It) >= 'a' && (*base58It) <= 'k')
        {
            carry = (unsigned int) ((*base58It) - 'a' + 33);
        }
        else if ((*base58It) >= 'm' && (*base58It) <= 'z')
        {
            carry = (unsigned int) ((*base58It) - 'm' + 44);
        }
        else
        {
            throw std::runtime_error("One characte in the string isn't BASE58");
        }

        for (ByteArray::reverse_iterator retIt = base256.rbegin(); retIt != base256.rend(); retIt++)
        {
            carry += 58 * (*retIt);
            *retIt = (Byte) (carry % 256);
            carry /= 256;
        }
    }

    ByteArray ret;
    ByteArray::iterator base256It = base256.begin();

    while (base256It != base256.end() && *base256It == 0)
    {
        base256It++;
    }

    ret.assign(zeroes, 0x00);
    ret.insert(ret.end(), base256It, base256.end());

    return ret;
}

Base58CheckDecoded Conversions::fromBase58Check(const std::string &base58)
{
    Base58CheckDecoded ret;
    ByteArray dec = fromBase58(base58);

    if (dec.size() <= 4)
    {
        throw  std::runtime_error("data too short (no checksum found)");
    }

    ret.version = dec[0];

    ByteArray checksum = dec.getSection(dec.size() - 4, 4);
    dec.erase(dec.begin() + (dec.size() - 4), dec.end());

    if (dec.sha256().sha256().getSection(0, 4) != checksum)
    {
        throw std::runtime_error("Checksum not valid, data corrupted?");
    }

    dec.erase(dec.begin(), dec.begin() + 1);
    ret.data = dec;

    return ret;
}

ByteArray Conversions::fromBase58Check(const std::string &base58, Byte version)
{
    Base58CheckDecoded ret = fromBase58Check(base58);
    if (ret.version != version)
    {
        throw std::runtime_error("Wrong version byte!)");
    }

    return ret.data;
}

std::string Conversions::toBase58(const ByteArray &data)
{
    std::string base58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    ByteArray encoded(data.size() * 138 / 100 + 1);

    ByteArray::const_iterator dataIt = data.begin();
    unsigned int zeroes = 0;

    while (dataIt != data.end() && *dataIt == 0)
    {
        zeroes++;
        dataIt++;
    }

    for (; dataIt != data.end(); dataIt++)
    {
        int carry = *dataIt;

        for (ByteArray::reverse_iterator encodedIt = encoded.rbegin(); encodedIt != encoded.rend(); encodedIt++)
        {
            carry += 256 * (*encodedIt);
            *encodedIt = (Byte) (carry % 58);
            carry /= 58;
        }
    }

    ByteArray::iterator encodedIt = encoded.begin();

    while (encodedIt != encoded.end() && *encodedIt == 0)
    {
        encodedIt++;
    }

    std::string ret;
    ret.assign(zeroes, '1');

    while (encodedIt != encoded.end())
    {
        ret += base58[*(encodedIt++)];
    }

    return ret;
}

std::string Conversions::toBase58Check(ByteArray data, Byte version)
{
    data.insert(data.begin(), version);

    ByteArray hash = Crypto::sha256(Crypto::sha256(data));
    data.insert(data.end(), hash.begin(), hash.begin() + 4);

    return toBase58(data);
}

ByteArray Conversions::fromUInt16(uint16_t num)
{
    ByteArray ret(2);

    for (unsigned int bNum = 0; bNum < 2; bNum++)
    {
        ret[3 - bNum] = (Byte) (num / (((uint16_t) 1) << (8 * (1 - bNum))));
        num %= (((uint16_t) 1) << (8 * (1 - bNum)));
    }

    return ret;
}

ByteArray Conversions::fromUInt32(uint32_t num)
{
    ByteArray ret(4);

    for (unsigned int bNum = 0; bNum < 4; bNum++)
    {
        ret[3 - bNum] = (Byte) (num / (((uint32_t) 1) << (8 * (3 - bNum))));
        num %= (((uint32_t) 1) << (8 * (3 - bNum)));
    }

    return ret;
}


ByteArray Conversions::fromUInt64(uint64_t num)
{
    ByteArray ret(8);

    for (unsigned int bNum = 0; bNum < 8; bNum++)
    {
        ret[7 - bNum] = (Byte) (num / (((uint64_t) 1) << (8 * (7 - bNum))));
        num %= (((uint64_t) 1) << (8 * (7 - bNum)));
    }

    return ret;
}

ByteArray Conversions::fromVarInt(uint64_t num)
{
    size_t len;
    Byte firstByte;

    if (num < 0xfd)
    {
        len = 0;
        firstByte = (Byte) num;
    }
    else if (num <= 0xffff)
    {
        len = 2;
        firstByte = 0xfd;
    }
    else if (num <= 0xffffffff)
    {
        len = 4;
        firstByte = 0xfe;
    }
    else
    {
        len = 8;
        firstByte = 0xff;
    }

    ByteArray ret(len + 1);
    ret[0] = firstByte;

    for (size_t bytePos = len; bytePos >= 1; --bytePos)
    {
        ret[bytePos] = (Byte) (num / (1 << (8 * (bytePos - 1))));
        num %= (1 << (8 * (bytePos - 1)));
    }

    return ret;
}

uint16_t Conversions::toUInt16(const ByteArray &data)
{
    if (data.size() < 2)
        throw std::runtime_error("can't convert data to uint16, data too short!");

    uint16_t ret = 0;

    for (unsigned int byteNum = 0; byteNum < 2; byteNum++)
    {
        ret += (((uint16_t) 1) << (8 * (1 - byteNum))) * data[byteNum];
    }

    return ret;
}

uint32_t Conversions::toUInt32(const ByteArray &data)
{
    if (data.size() < 4)
        throw std::runtime_error("can't convert data to uint16, data too short!");

    uint32_t ret = 0;

    for (unsigned int byteNum = 0; byteNum < 4; byteNum++)
    {
        ret += (((uint32_t) 1) << (8 * (3 - byteNum))) * data[byteNum];
    }

    return ret;
}

uint64_t Conversions::toUInt64(const ByteArray &data)
{
    if (data.size() < 8)
        throw std::runtime_error("can't convert data to uint16, data too short!");

    uint64_t ret = 0;

    for (unsigned int byteNum = 0; byteNum < 8; byteNum++)
    {
        ret += (((uint64_t) 1) << (8 * (7 - byteNum))) * data[byteNum];
    }

    return ret;
}

ByteArray Conversions::reverse(ByteArray inp)
{
    std::reverse(inp.begin(), inp.end());
    return inp;
}

int64_t Conversions::toScriptVarInt(const ByteArray& data)
{
    if(data.empty())
        return 0;

    if(data.size() > 4)
        throw std::runtime_error("number too big to convert (more than 4 bytes)");

    uint64_t val = 0;

    for(size_t b = 0; b < data.size(); ++b)
    {
        val |= static_cast<int64_t>(data[b]) << (8 * b);
    }

    if(data.back() &0x80)
    {
        return -((int64_t)(val & ~(0x80ULL << 8 * (data.size() - 1))));
    }
    else
    {
        return val;
    }
}

ByteArray Conversions::fromScriptVarInt(int64_t val)
{
    ByteArray ret;

    if(val == 0)
        return ret;

    bool negative = (val < 0);

    uint64_t absVal = negative ? -val : val;

    while(absVal)
    {
        ret.push_back(absVal & 0xff);
        absVal >>= 8;
    }

    if (ret.back() & 0x80)
        ret.push_back(negative ? 0x80 : 0);
    else if (negative)
        ret.back() |= 0x80;

    return ret;
}

ByteArray Conversions::fromString(const std::string &s)
{
    return ByteArray((Byte*)s.c_str(), s.size());
}

std::string Conversions::toString(const ByteArray &data)
{
    return std::string((char *)&data[0], data.size());
}