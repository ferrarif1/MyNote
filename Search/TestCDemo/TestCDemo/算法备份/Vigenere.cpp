//#include <stdio.h>
//#include <stdlib.h>
//
//
//
//int main()//主程序
//{
//    
//  
//    //转换msg为数字
//    char context[1000] = "expl anation";
//    char key[20] = "leg";
//    int lengthOfKey = 3;
//    
//    
//    int numofcontext[1000];
//    printf("%s",context);
//    int index = 0;
//    int length = 0;
//    while (context[index]!='\0') {
//        if (context[index] != ' ') {
//            numofcontext[index] = context[index] - 'a';
//        }
//        else{
//            numofcontext[index] = 26;
//        }
//        index++;
//    }
//    length = index;
//    //加密
//    int numofencrpt[1000];
//    char  encrptcontext[1000];
//    index = 0;
//    for(int i = 0;i<1000;i++){
//        numofencrpt[i] = 0;
//    }
//    int enIndex = 0;
//    while (enIndex<length) {
//        int i = enIndex%lengthOfKey;
//        int kk = (int)(key[i]-'a');
//        numofencrpt[enIndex] = (kk + numofcontext[enIndex])%27;
//        if (numofencrpt[enIndex]<0) {
//            numofencrpt[enIndex]+=27;
//        }
//        enIndex++;
//    }
//    //输出
//    printf("encrpt num: \n");
//    for(int i = 0;i<index;i++){
//        printf(" %d",numofencrpt[i]);
//    }
//    index = 0;
//    while (index<length) {
//        if (numofencrpt[index]<26) {
//            encrptcontext[index] = (char)('a' + numofencrpt[index]);
//        }else{
//            encrptcontext[index] = ' ';
//        }
//        index++;
//    }
//    encrptcontext[index] = '\0';
//    printf("\nencrpt result = %s\n",encrptcontext);
//    
//    
//    //解密
//    int numofdecrpt[1000];
//    for(int i = 0;i<1000;i++){
//        numofdecrpt[i] = 0;
//    }
//    char  decrptcontext[1000];
//    int deIndex = 0;
//    while (deIndex<length) {
//        int i = deIndex%lengthOfKey;
//        int kk = (int)(key[i]-'a');
//        numofdecrpt[deIndex] = (numofencrpt[deIndex] - kk)%27;
//        if (numofdecrpt[deIndex]<0) {
//            numofdecrpt[deIndex]+=27;
//        }
//        deIndex++;
//    }
//    
//    //输出
//    printf("decrpt num:\n");
//    for(int i = 0;i<index;i++){
//        printf(" %d",numofdecrpt[i]);
//    }
//    index = 0;
//    while (index<length) {
//        if (numofdecrpt[index]<26) {
//            decrptcontext[index] = (char)('a' + numofdecrpt[index]);
//        }else{
//            decrptcontext[index] = ' ';
//        }
//        index++;
//    }
//    decrptcontext[index] = '\0';
//    printf("\ndecrpt result = %s\n",decrptcontext);
//    
//    printf("%s",context);
//   
//    
//    
//    return 0;
//}
