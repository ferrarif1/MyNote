//#include <stdio.h>
//#include <stdlib.h>
//
//#define N 2
////Hill
//int secretkey[N][N];
//int nisecretkey[N][N];
////9 4 5 7
////因有空格 将空格标记为26 0-26共26个字符
//void ColculateNi(int num,int modnum){
//    int result = 0;
//    for(int i = 1;i<=modnum;i++){
//        if ((num*i)%modnum==1) {
//            result = i;
//            printf("%d mod %d 的逆= %d\n",num,modnum,result);
//        }
//    }
//}
//
//void ColculateNiOfmatrix(){
//    int det = (secretkey[0][0]*secretkey[1][1]-secretkey[0][1]*secretkey[1][0])%26;
//    if (det<0) {
//        det+=26;
//    }
//    int niOfdet = 0;
//    for(int i = 1;i<=26;i++){
//        if ((det*i)%26==1) {
//            niOfdet = i;
//        }
//    }
//    if (niOfdet<0) {
//        niOfdet+=26;
//    }
//    printf("det = %d Det 的逆= %d\n",det,niOfdet);
//    nisecretkey[0][0] = (niOfdet * secretkey[1][1])%26;
//    nisecretkey[1][1] = (niOfdet * secretkey[0][0])%26;
//    nisecretkey[0][1] = (niOfdet*(-secretkey[0][1]))%26;
//    nisecretkey[1][0] = (niOfdet*(-secretkey[1][0]))%26;
//
//    printf("Key 的逆：\n");
//    for(int i = 0;i<2;i++){
//        for(int j = 0;j<2;j++){
//            if (nisecretkey[i][j]<0) {
//                nisecretkey[i][j]+=26;
//            }
//            printf("%d ",nisecretkey[i][j]);
//        }
//        printf("\n");
//    }
//    printf("\n");
//}
//
//
//int main()//主程序
//{
//
//    for(int i = 0;i<2;i++){
//        for(int j = 0;j<2;j++){
//            scanf("%d",&secretkey[i][j]);
//        }
//    }
//
//    //计算逆
//    ColculateNiOfmatrix();
//    //转换msg为数字
//    char context[1000] = "meet me at the usual place at then";
//    int numofcontext[1000];
//    printf("%s",context);
//    int index = 0;
//    while (context[index]!='\0') {
//        if (context[index] != ' ') {
//            numofcontext[index] = context[index] - 'a';
//        }
//        else{
//            numofcontext[index] = 26;
//        }
//        index++;
//    }
//
//
//    //加密
//    int numofencrpt[1000];
//    char  encrptcontext[1000];
//    index = 0;
//    for(int i = 0;i<1000;i++){
//        numofencrpt[i] = 0;
//    }
//    printf("\nencrpt ******************\n");
//    while (context[index]!='\0') {
//        int result = numofcontext[index]*secretkey[0][0]+numofcontext[index+1]*secretkey[1][0];
//        numofencrpt[index] = (result)%26;
//        if (numofencrpt[index]<0) {
//            numofencrpt[index] =numofencrpt[index] + 26;
//        }
//        int result2 = numofcontext[index]*secretkey[0][1]+numofcontext[index+1]*secretkey[1][1];
//        numofencrpt[index+1] = (result2)%26;
//        if (numofencrpt[index+1]<0) {
//            numofencrpt[index+1] =numofencrpt[index+1] + 26;
//        }
//        index+=2;
//    }
//
//
//    //5 8 17 3
//    printf("encrpt num: \n");
//    for(int i = 0;i<index;i++){
//        printf(" %d",numofencrpt[i]);
//    }
//
//    index = 0;
//    while (context[index]!='\0') {
//        if (numofencrpt[index]<26) {
//            encrptcontext[index] = (char)('a' + numofencrpt[index]);
//        }else{
//            encrptcontext[index] = ' ';
//        }
//        index++;
//    }
//    printf("\nencrpt result = %s\n",encrptcontext);
//
//    //解密
//    int numofdecrpt[1000];
//    for(int i = 0;i<1000;i++){
//        numofdecrpt[i] = 0;
//    }
//    char  decrptcontext[1000];
//    index = 0;
//    while (context[index]!='\0') {
//        int result = numofencrpt[index]*nisecretkey[0][0]+numofencrpt[index+1]*nisecretkey[1][0];
//        numofdecrpt[index] += (result)%26;
//        if (numofdecrpt[index]<0) {
//            numofdecrpt[index]+=26;
//        }
//        int result2 = numofencrpt[index]*nisecretkey[0][1]+numofencrpt[index+1]*nisecretkey[1][1];
//        numofdecrpt[index+1] += (result2)%26;
//        if (numofdecrpt[index+1]<0) {
//            numofdecrpt[index+1]+=26;
//        }
//        index+=2;
//    }
//    printf("decrpt num:\n");
//    for(int i = 0;i<index;i++){
//        printf(" %d",numofdecrpt[i]);
//    }
//
//    index = 0;
//    while (context[index]!='\0') {
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
//
//
//    return 0;
//}
////