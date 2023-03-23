

#include <fstream>
#include "../include/openssl/rand.h"
#include <thread>
#include <iostream>
#include <string>
#include <cstddef>
#include <cstring>
#include <string>
#include <cstdlib>
#include <ctime>
#include "EasyBitcoin/BtcPrivateKey.cpp"
#include "EasyBitcoin/Crypto.cpp"
#include "EasyBitcoin/ByteArray.cpp"
#include "EasyBitcoin/BtcPublicKey.cpp"
#include "EasyBitcoin/Base58CheckDecode.h"
#include "EasyBitcoin/Conversions.cpp"


using namespace std;


string random_string(size_t length) {
    const std::string charset = "0123456789abcdef";
    std::string result;
    result.resize(length);
    srand(static_cast<unsigned int>(time(nullptr)));
    for (size_t i = 0; i < length; i++) {
        result[i] = charset[rand() % charset.length()];
    }
    return result;
}

template <typename I>
string n2hexstr(I w, size_t hex_len = sizeof(I)<<1) {
    static const char* digits = "0123456789abcdef";
    string rc(hex_len,'0');
    for (size_t i=0, j=(hex_len-1)*4 ; i<hex_len; ++i,j-=4)
        rc[i] = digits[(w>>j) & 0x0f];
    return rc;
}

void findWIF()
{
    // 定义16进制私钥范围
    string start_hex_key = "$start";
    string end_hex_key =   "$end";

    int index = 0;
    // 随机寻找
    while (true) {
        index++;
        size_t length = start_hex_key.length(); // 哈希字符串的长度
        
        string result = ""; // 生成的随机字符串
        for (size_t i = 0; i < length; i++) {
            int start = stoi(start_hex_key.substr(i, 1), nullptr, 16); // 起始哈希字符串在当前位置的数值
            int end = stoi(end_hex_key.substr(i, 1), nullptr, 16); // 终止哈希字符串在当前位置的数值
            int random_num = rand() % (end - start + 1) + start; // 在当前位置生成的随机数
            string random_char = n2hexstr(random_num,1); // 将随机数转换为字符串
            result += random_char; // 将生成的随机字符串添加到结果中
           // cout <<random_char<< " " <<"privatekey" << i << " = " << result << endl; // 输出生成的随机字符串
        }
        cout <<"privatekey = " << result << " index = " << index << endl; // 输出生成的随机字符串
        const ByteArray *by = new ByteArray();
        string currentkeystr =  Conversions::toHex(*by);
       

        ByteArray currentkeyba =  Conversions::fromHex(result);
        

        index++;

        // 将16进制私钥转换为WIF格式
        BtcPrivateKey privatekey = BtcPrivateKey(currentkeyba);
        ByteArray publickeyba = Crypto:: privKeyToCompressedPubKey(privatekey);
        BtcPublicKey publickey = BtcPublicKey(publickeyba);
        string address = publickey.getAddress();
        
        cout << "address = "<< address << endl;
    
        // 如果地址与目标地址相同，则输出私钥
        if (address == "$addr") {
            string wif = privatekey.getWIF();
            // 创建文件流对象，打开文件
            ofstream file("example.txt");

            // 写入文本内容
            file << wif;

            // 关闭文件流
            file.close();
            cout << "文件已保存" << endl;
            cout << "Matching private key found: " << wif << endl;
            break;
        }
    }

}

int main() {
    findWIF();
    
//    int num = 3;
//    thread threads[num];
//
//    for (int i = 0; i<num; i++) {
//        threads[i] = std::thread(findWIF);
//        threads[i].join();
//    }
//
//    std::thread t1(findWIF);
//    std::thread::id t1_id = t1.get_id();
//
//    std::thread t2(findWIF);
//    std::thread::id t2_id = t2.get_id();
//
////    std::cout << "t1's id: " << t1_id << '\n';
////    std::cout << "t2's id: " << t2_id << '\n';

//    t1.join();
//    t2.join();
    
    return 0;
}
