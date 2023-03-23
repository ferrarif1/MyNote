//#include <stdio.h>
//#include <stdlib.h>
//#include <iostream>
//#include <string.h>
//#include <sstream>
//using namespace std;
//
//
//
///*
// 1ByteModel = 1字节 = 8位 = 2个16进制数
// 如A3
// */
//typedef struct ByteModel
//{
//    char byte_data[2];
//}ByteModel;
//
///*
// 1Word = 4ByteModel = 4个字节 = 16字节 4个ByteModel
// 如A3 B2 6E 4C
// */
//typedef struct Word
//{
//    ByteModel word_data[4];
//}Word;
//
//ByteModel S[16][16];
////key是4个字 = 16字节
//ByteModel key[16];
//
////w是扩展密钥 w[i]为1个字 = 4个字节
//Word w[44];
//char RC[21] = "01020408102040801B36";
//
//
//ByteModel ByteModelinit(string a){
//    static ByteModel bm;
//    bm.byte_data[0] = a[0];
//    bm.byte_data[1] = a[1];
//    return bm;
//}
//
//
//void initBM(){
//    S[0][0] = ByteModelinit("63");
//    S[0][1] = ByteModelinit("7c");
//    S[0][2] = ByteModelinit("77");
//    S[0][3] = ByteModelinit("7b");
//    S[0][4] = ByteModelinit("f2");
//    S[0][5] = ByteModelinit("6b");
//    S[0][6] = ByteModelinit("6f");
//    S[0][7] = ByteModelinit("c5");
//    S[0][8] = ByteModelinit("30");
//    S[0][9] = ByteModelinit("01");
//    S[0][10] = ByteModelinit("67");
//    S[0][11] = ByteModelinit("2b");
//    S[0][12] = ByteModelinit("fe");
//    S[0][13] = ByteModelinit("d7");
//    S[0][14] = ByteModelinit("ab");
//    S[0][15] = ByteModelinit("76");
//    
//    S[1][0] = ByteModelinit("ca");
//    S[1][1] = ByteModelinit("82");
//    S[1][2] = ByteModelinit("c9");
//    S[1][3] = ByteModelinit("7d");
//    S[1][4] = ByteModelinit("fa");
//    S[1][5] = ByteModelinit("59");
//    S[1][6] = ByteModelinit("47");
//    S[1][7] = ByteModelinit("f0");
//    S[1][8] = ByteModelinit("ad");
//    S[1][9] = ByteModelinit("d4");
//    S[1][11] = ByteModelinit("a2");
//    S[1][11] = ByteModelinit("af");
//    S[1][12] = ByteModelinit("9c");
//    S[1][13] = ByteModelinit("a4");
//    S[1][14] = ByteModelinit("72");
//    S[1][15] = ByteModelinit("c0");
//    
//    S[2][0] = ByteModelinit("b7");
//    S[2][1] = ByteModelinit("fd");
//    S[2][2] = ByteModelinit("93");
//    S[2][3] = ByteModelinit("26");
//    S[2][4] = ByteModelinit("36");
//    S[2][5] = ByteModelinit("3f");
//    S[2][6] = ByteModelinit("f7");
//    S[2][7] = ByteModelinit("cc");
//    S[2][8] = ByteModelinit("34");
//    S[2][9] = ByteModelinit("a5");
//    S[2][12] = ByteModelinit("e5");
//    S[2][11] = ByteModelinit("f1");
//    S[2][12] = ByteModelinit("71");
//    S[2][13] = ByteModelinit("d8");
//    S[2][14] = ByteModelinit("31");
//    S[2][15] = ByteModelinit("15");
//    
//    S[3][0] = ByteModelinit("04");
//    S[3][1] = ByteModelinit("c7");
//    S[3][2] = ByteModelinit("23");
//    S[3][3] = ByteModelinit("c3");
//    S[3][4] = ByteModelinit("18");
//    S[3][5] = ByteModelinit("96");
//    S[3][6] = ByteModelinit("05");
//    S[3][7] = ByteModelinit("9a");
//    S[3][8] = ByteModelinit("07");
//    S[3][9] = ByteModelinit("12");
//    S[3][10] = ByteModelinit("80");
//    S[3][11] = ByteModelinit("e2");
//    S[3][12] = ByteModelinit("eb");
//    S[3][13] = ByteModelinit("27");
//    S[3][14] = ByteModelinit("b2");
//    S[5][15] = ByteModelinit("75");
//    
//    S[4][0] = ByteModelinit("09");
//    S[4][1] = ByteModelinit("83");
//    S[4][2] = ByteModelinit("2c");
//    S[4][3] = ByteModelinit("1a");
//    S[4][4] = ByteModelinit("1b");
//    S[4][5] = ByteModelinit("6e");
//    S[4][6] = ByteModelinit("5a");
//    S[4][7] = ByteModelinit("a0");
//    S[4][8] = ByteModelinit("52");
//    S[4][9] = ByteModelinit("3b");
//    S[4][10] = ByteModelinit("d6");
//    S[4][11] = ByteModelinit("b3");
//    S[4][12] = ByteModelinit("29");
//    S[4][13] = ByteModelinit("e3");
//    S[4][14] = ByteModelinit("2f");
//    S[4][15] = ByteModelinit("84");
//    
//    S[5][0] = ByteModelinit("53");
//    S[5][1] = ByteModelinit("d1");
//    S[5][2] = ByteModelinit("00");
//    S[5][3] = ByteModelinit("ed");
//    S[5][4] = ByteModelinit("20");
//    S[5][5] = ByteModelinit("fc");
//    S[5][6] = ByteModelinit("b1");
//    S[5][7] = ByteModelinit("5b");
//    S[5][8] = ByteModelinit("6a");
//    S[5][9] = ByteModelinit("cb");
//    S[5][10] = ByteModelinit("be");
//    S[5][11] = ByteModelinit("39");
//    S[5][12] = ByteModelinit("4a");
//    S[5][13] = ByteModelinit("4c");
//    S[5][14] = ByteModelinit("58");
//    S[5][15] = ByteModelinit("cf");
//    
//    S[6][0] = ByteModelinit("d0");
//    S[6][1] = ByteModelinit("ef");
//    S[6][2] = ByteModelinit("aa");
//    S[6][3] = ByteModelinit("fb");
//    S[6][4] = ByteModelinit("43");
//    S[6][5] = ByteModelinit("4d");
//    S[6][6] = ByteModelinit("33");
//    S[6][7] = ByteModelinit("85");
//    S[6][8] = ByteModelinit("45");
//    S[6][9] = ByteModelinit("f9");
//    S[6][10] = ByteModelinit("02");
//    S[6][11] = ByteModelinit("7f");
//    S[6][12] = ByteModelinit("50");
//    S[6][13] = ByteModelinit("3c");
//    S[6][14] = ByteModelinit("9f");
//    S[6][15] = ByteModelinit("a8");
//    
//    S[7][0] = ByteModelinit("51");
//    S[7][1] = ByteModelinit("a3");
//    S[7][2] = ByteModelinit("40");
//    S[7][3] = ByteModelinit("8f");
//    S[7][4] = ByteModelinit("92");
//    S[7][5] = ByteModelinit("9d");
//    S[7][6] = ByteModelinit("38");
//    S[7][7] = ByteModelinit("f5");
//    S[7][8] = ByteModelinit("bc");
//    S[7][9] = ByteModelinit("b6");
//    S[7][10] = ByteModelinit("da");
//    S[7][11] = ByteModelinit("21");
//    S[7][12] = ByteModelinit("10");
//    S[7][13] = ByteModelinit("ff");
//    S[7][14] = ByteModelinit("f3");
//    S[7][15] = ByteModelinit("d2");
//    
//    S[8][0] = ByteModelinit("cd");
//    S[8][1] = ByteModelinit("0c");
//    S[8][2] = ByteModelinit("13");
//    S[8][3] = ByteModelinit("ec");
//    S[8][4] = ByteModelinit("5f");
//    S[8][5] = ByteModelinit("97");
//    S[8][6] = ByteModelinit("44");
//    S[8][7] = ByteModelinit("17");
//    S[8][8] = ByteModelinit("c4");
//    S[8][9] = ByteModelinit("a7");
//    S[8][10] = ByteModelinit("7e");
//    S[8][11] = ByteModelinit("3d");
//    S[8][12] = ByteModelinit("64");
//    S[8][13] = ByteModelinit("5d");
//    S[8][14] = ByteModelinit("19");
//    S[8][15] = ByteModelinit("73");
//    
//    S[9][0] = ByteModelinit("60");
//    S[9][1] = ByteModelinit("81");
//    S[9][2] = ByteModelinit("4f");
//    S[9][3] = ByteModelinit("dc");
//    S[9][4] = ByteModelinit("22");
//    S[9][5] = ByteModelinit("2a");
//    S[9][6] = ByteModelinit("90");
//    S[9][7] = ByteModelinit("88");
//    S[9][8] = ByteModelinit("46");
//    S[9][9] = ByteModelinit("ee");
//    S[9][10] = ByteModelinit("b8");
//    S[9][11] = ByteModelinit("14");
//    S[9][12] = ByteModelinit("de");
//    S[9][13] = ByteModelinit("5e");
//    S[9][14] = ByteModelinit("0b");
//    S[9][15] = ByteModelinit("db");
//    
//    S[10][0] = ByteModelinit("e0");
//    S[10][1] = ByteModelinit("32");
//    S[10][2] = ByteModelinit("3a");
//    S[10][3] = ByteModelinit("0a");
//    S[10][4] = ByteModelinit("49");
//    S[10][5] = ByteModelinit("06");
//    S[10][6] = ByteModelinit("24");
//    S[10][7] = ByteModelinit("5c");
//    S[10][8] = ByteModelinit("c2");
//    S[10][9] = ByteModelinit("d3");
//    S[10][10] = ByteModelinit("ac");
//    S[10][11] = ByteModelinit("62");
//    S[10][12] = ByteModelinit("91");
//    S[10][13] = ByteModelinit("95");
//    S[10][14] = ByteModelinit("e4");
//    S[10][15] = ByteModelinit("79");
//    
//    S[11][0] = ByteModelinit("e7");
//    S[11][1] = ByteModelinit("c8");
//    S[11][2] = ByteModelinit("37");
//    S[11][3] = ByteModelinit("6d");
//    S[11][4] = ByteModelinit("8d");
//    S[11][5] = ByteModelinit("d5");
//    S[11][6] = ByteModelinit("4e");
//    S[11][7] = ByteModelinit("a9");
//    S[11][8] = ByteModelinit("6c");
//    S[11][9] = ByteModelinit("56");
//    S[11][10] = ByteModelinit("f4");
//    S[11][11] = ByteModelinit("ea");
//    S[11][12] = ByteModelinit("65");
//    S[11][13] = ByteModelinit("7a");
//    S[11][14] = ByteModelinit("ae");
//    S[11][15] = ByteModelinit("08");
//    
//    S[12][0] = ByteModelinit("ba");
//    S[12][1] = ByteModelinit("78");
//    S[12][2] = ByteModelinit("25");
//    S[12][3] = ByteModelinit("2e");
//    S[12][4] = ByteModelinit("1c");
//    S[12][5] = ByteModelinit("a6");
//    S[12][6] = ByteModelinit("b4");
//    S[12][7] = ByteModelinit("c6");
//    S[12][8] = ByteModelinit("e8");
//    S[12][9] = ByteModelinit("dd");
//    S[12][10] = ByteModelinit("74");
//    S[12][11] = ByteModelinit("1f");
//    S[12][12] = ByteModelinit("4b");
//    S[12][13] = ByteModelinit("bd");
//    S[12][14] = ByteModelinit("8b");
//    S[12][15] = ByteModelinit("8a");
//    
//    S[13][0] = ByteModelinit("70");
//    S[13][1] = ByteModelinit("3e");
//    S[13][2] = ByteModelinit("b5");
//    S[13][3] = ByteModelinit("66");
//    S[13][4] = ByteModelinit("48");
//    S[13][5] = ByteModelinit("03");
//    S[13][6] = ByteModelinit("f6");
//    S[13][7] = ByteModelinit("0e");
//    S[13][8] = ByteModelinit("61");
//    S[13][9] = ByteModelinit("35");
//    S[13][10] = ByteModelinit("57");
//    S[13][11] = ByteModelinit("b9");
//    S[13][12] = ByteModelinit("86");
//    S[13][13] = ByteModelinit("c1");
//    S[13][14] = ByteModelinit("1d");
//    S[13][15] = ByteModelinit("9e");
//    
//    S[14][0] = ByteModelinit("e1");
//    S[14][1] = ByteModelinit("f8");
//    S[14][2] = ByteModelinit("98");
//    S[14][3] = ByteModelinit("11");
//    S[14][4] = ByteModelinit("69");
//    S[14][5] = ByteModelinit("d9");
//    S[14][6] = ByteModelinit("8e");
//    S[14][7] = ByteModelinit("94");
//    S[14][8] = ByteModelinit("9b");
//    S[14][9] = ByteModelinit("1e");
//    S[14][10] = ByteModelinit("87");
//    S[14][11] = ByteModelinit("e9");
//    S[14][12] = ByteModelinit("ce");
//    S[14][13] = ByteModelinit("55");
//    S[14][14] = ByteModelinit("28");
//    S[14][15] = ByteModelinit("df");
//    
//    S[15][0] = ByteModelinit("8c");
//    S[15][1] = ByteModelinit("a1");
//    S[15][2] = ByteModelinit("89");
//    S[15][3] = ByteModelinit("0d");
//    S[15][4] = ByteModelinit("bf");
//    S[15][5] = ByteModelinit("e6");
//    S[15][6] = ByteModelinit("42");
//    S[15][7] = ByteModelinit("68");
//    S[15][8] = ByteModelinit("41");
//    S[15][9] = ByteModelinit("99");
//    S[15][10] = ByteModelinit("2d");
//    S[15][11] = ByteModelinit("0f");
//    S[15][12] = ByteModelinit("b0");
//    S[15][13] = ByteModelinit("54");
//    S[15][14] = ByteModelinit("bb");
//    S[15][15] = ByteModelinit("16");
//    
//}
//
////8位2进制数转hex
//ByteModel ByteToHex(char *a,char *b){
//    static ByteModel result;
//    int rr = 0;
//    int rr1 = 0;
//    for (int i = 0; i<4; i++) {
//        rr += a[3-i]*pow(2, i);
//        rr1 += b[3-i]*pow(2, i);
//    }
//    if (rr<=9 && rr>=0) {
//        result.byte_data[0] = (char)(rr+'0');
//        result.byte_data[1] = (char)(rr1+'0');
//    }else{
//        result.byte_data[0] = (char)(rr-10+'a');
//        result.byte_data[1] = (char)(rr1-10+'a');
//    }
//    return result;
//}
//
//
////返回4位2进制数
//char* HexToByte(char a){
//    static char hex[4];
//    
//    int x = 0;
//    if (a >= '0' && a <= '9') {
//        x = a - '0';
//    }
//    else if (a >= 'a' && a <= 'f') {
//        x = a - 'a' + 10;
//    }
//    for (int i = 0; i<4; i++) {
//        int rr = 0;
//        rr = x % 2;
//        x = x/2;
//        hex[3-i] = (char)(rr + '0');
//    }
//    return hex;
//}
////返回int
//int HexToInt(char a){
//
//    int x = 0;
//    if (a >= '0' && a <= '9') {
//        x = a - '0';
//    }
//    else if (a >= 'a' && a <= 'f') {
//        x = a - 'a' + 10;
//    }
//    return x;
//}
///*
//char的异或
//*/
//char ByteXOR(char b1, char b2){
//    int a = b1 - '0';
//    int b = b2 - '0';
//    int result = (a^b);
//    return  (char)(result+'0');
//}
///*
// 两位16进制数的异或
// a,b 为16进制ByteModel
// 如a = 7f  b = 7f
// result = 00
// */
//ByteModel XOR(ByteModel a,ByteModel b){
//    static ByteModel resultBM;
//    static char result[8];
//    char* a0 = HexToByte(a.byte_data[0]);
//    a0[8] = '\0';
//    char* a1 = HexToByte(a.byte_data[1]);
//    a1[8] = '\0';
//    char* b0 = HexToByte(b.byte_data[0]);
//    b0[8] = '\0';
//    char* b1 = HexToByte(b.byte_data[1]);
//    b1[8] = '\0';
//    
//    for (int i = 0; i<4; i++) {
//        result[i] = ByteXOR(a0[i], b0[i]);
//        result[i+4] = ByteXOR(a1[i], b1[i]);
//    }
//    printf("\n%.8s%.8s\n%.8s%.8s\n=\n%.8s",a0,a1,b0,b1,result);
//    static char st1[4];
//    static char st2[4];
//    st1[0] = result[0];
//    st1[1] = result[1];
//    st1[2] = result[2];
//    st1[3] = result[3];
//    
//    st2[0] = result[4];
//    st2[1] = result[5];
//    st2[2] = result[6];
//    st2[3] = result[7];
//    
//    resultBM = ByteToHex(st1,st2);
//    
////
//    
//    return resultBM;
//            
//}
//
//
//void PrintKey(){
//    printf("key:");
//    for (int i = 0; i<16; i++) {
//        if (i%4 == 0) {
//            printf("\n");
//        }
//        printf("%c%c ",key[i].byte_data[0],key[i].byte_data[1]);
//    }
//    printf("\n");
//}
///*
// 输出一组w，如w0-w3
// */
//void PrintW(int start){
//    printf("w%d - w%d",start,start+3);
//    for (int i = 0; i<4; i++) {
//        printf("\n");
//        for (int j = 0; j<4; j++)  {
//            printf("%c%c ",w[i].word_data[j].byte_data[0],w[i].word_data[j].byte_data[1]);
//        }
//        
//    }
//    printf("\n");
//}
///*
// 输出一个w，如w0
// */
//void PrintWord(Word w){
//    printf("w:\n");
//    for (int j = 0; j<4; j++)  {
//        printf("%c%c ",w.word_data[j].byte_data[0],w.word_data[j].byte_data[1]);
//    }
//    printf("\n");
//}
//
///*
// 移位 B0 B1 B2 B3 -> B1 B2 B3 B0
// */
//Word MoveOneStep(int index){
//     static Word result;
////    ByteModel temp = w[index].word_data[0];
////    for (int i = 0; i < 3; i++) {
////        w[index].word_data[i] = w[index].word_data[i+1];
////    }
////    w[index].word_data[3] = temp;
//    ByteModel temp = w[index].word_data[0];
//    for (int i = 0; i < 3; i++) {
//        result.word_data[i] = w[index].word_data[i+1];
//    }
//    result.word_data[3] = temp;
//    return result;
//}
//
///*
// w 函数g，index为w对应的index,num为对应第几轮(1-10)
// */
//Word ggenerate(Word w,int index,int num){
//    Word resultWord;
//    Word w1;
//    //移位
//    Word wmove = MoveOneStep(3);
//    PrintWord(wmove);
//    //S盒
//    for (int i = 0;i < 4; i++) {
//        char x = wmove.word_data[i].byte_data[0];
//        char y = wmove.word_data[i].byte_data[1];
//        int xx = HexToInt(x);
//        int yy = HexToInt(y);
//        ByteModel ss = S[xx][yy];
//        w1.word_data[i].byte_data[0] = ss.byte_data[0];
//        w1.word_data[i].byte_data[1] = ss.byte_data[1];
//    }
//    printf("w1 after S-Box:\n");
//    PrintWord(w1);
//    //与RC异或
//    for (int i = 0;i < 4; i++) {
//        ByteModel rc;
//        rc.byte_data[0] = RC[(num-1)*2];
//        rc.byte_data[1] = RC[(num-1)*2+1];
//        if (i > 0) {
//            rc.byte_data[0] = '0';
//            rc.byte_data[1] = '0';
//        }
//        ByteModel result = XOR(w1.word_data[i], rc);
//        resultWord.word_data[i].byte_data[0] = result.byte_data[0];
//        resultWord.word_data[i].byte_data[1] = result.byte_data[1];
//        printf("rc = %c %c\n   \n",rc.byte_data[0],rc.byte_data[1]);
//    }
//    printf("resultWord:\n");
//    PrintWord(resultWord);
//    return resultWord;
//}
//
///*
// key[i]是一个字节
// w[i]是一个字
// */
//void ExtendKey(){
//    
//    
//    //初始赋值w0 - w3
//    for(int i = 0;i<4;i++){
//        for(int j = 0;j<4;j++){
//            (w[i]).word_data[j].byte_data[0] = key[i*4+j].byte_data[0];
//            (w[i]).word_data[j].byte_data[1] = key[i*4+j].byte_data[1];
//        }
//    }
//    PrintW(0);
//    //g（w3）******** start
//    //w3移位 第1轮
//    Word wx = ggenerate(w[3], 3, 1);
//    for(int j = 0;j<4;j++){
//        (w[4]).word_data[j].byte_data[0] = XOR(w[0].word_data[j], wx.word_data[j]).byte_data[0];
//        (w[4]).word_data[j].byte_data[1] = XOR(w[0].word_data[j], wx.word_data[j]).byte_data[1];
//    }
//    printf("w4:\n");
//    PrintWord(w[4]);
//    //g（w3）******** end
//}
//
//
//
//
//int main()//主程序
//{
//
//    
//    char keyoriginal[33] = "0f1571c947d9e8590cb7add6af7f6798";
//    
//    int j = 0;
//    for (int i = 0; i<16; i++) {
//        key[i].byte_data[0]=keyoriginal[j];
//        key[i].byte_data[1]=keyoriginal[j+1];
//        j+=2;
//    }
//    initBM();
//    ExtendKey();
//    
//   
//
//    return 0;
//}
//
//
