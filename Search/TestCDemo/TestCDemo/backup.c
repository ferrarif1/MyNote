////
////  backup.c
////  TestCDemo
////
////  Created by 张元一 on 2020/1/13.
////  Copyright © 2020 张元一. All rights reserved.
////
//
//#include "backup.h"
//
////
////  main.m
////  TestCDemo
////
////  Created by 张元一 on 2019/1/14.
////  Copyright © 2019 张元一. All rights reserved.
////
//
////#import <Foundation/Foundation.h>
////#include<iostream>
////#include<ctime>
//#include<stdio.h>
//#include <string.h>
//
//int Isleapyear(int year){
//    return ((year%4==0)&&(year%100)!=0)||(year%400 == 0);
//}
//int DayOfYear(int year){
//    if (Isleapyear(year)) {
//        return 366;
//    }else{
//        return 365;
//    }
//}
//
//int main2(int argc, const char * argv[]) {
//    int day1[] = {0,31,28,31,30,31,30,31,31,30,31,30,31};
//    int day2[] = {0,31,29,31,30,31,30,31,31,30,31,30,31};
//    int numberOfLine;
//    int year,month,day,addDay;
//    //后面数据行数
//    scanf("%d",&numberOfLine);
//    for(int i = 0;i<numberOfLine;i++){
//        scanf("%d %d %d %d",&year,&month,&day,&addDay);
//        int isleapyear = Isleapyear(year);
//        int dayOfThatMonth;
//        if (isleapyear) {
//            dayOfThatMonth = day2[month];
//        }else{
//            dayOfThatMonth = day1[month];
//        }
//        int leftDayToTheMonth = dayOfThatMonth - day;
//        int leftDayToTheYear = leftDayToTheMonth;
//        for (int j = month+1; j<=12; ++j) {
//            if (isleapyear) {
//                leftDayToTheYear += day2[j];
//            }else{
//                leftDayToTheYear += day1[j];
//            }
//        }
//        int currentYear = year;
//        int currentMonth = 0;
//        int currentDay = 0;
//        int ifAddYear = 0;//是否跨年
//        int ifAddMonth = 0;//是否跨月
//        if (addDay>=leftDayToTheYear) {//如果跨年
//            ifAddYear = 1;
//            ifAddMonth = 1;
//            addDay -= leftDayToTheYear;
//            currentYear++;
//            while (addDay>DayOfYear(currentYear)) {//如果还需要跨年
//                addDay -= DayOfYear(currentYear);
//                currentYear++;
//            }
//
//        }
//        //月
//        if(ifAddYear == 0){//没有跨年,月日按当前开始算
//            currentMonth = month;
//            currentDay = day;
//        }else{//跨年了
//           currentMonth = 1;
//           currentDay = 0;
//        }
//        if (addDay>=leftDayToTheMonth) {//如果跨月
//            ifAddMonth = 1;
//            addDay -= leftDayToTheMonth;
//            currentMonth++;
//            if(currentMonth > 12){
//                currentMonth = 1;
//            }
//
//            int cuurday;
//            if (isleapyear) {
//                cuurday = day2[currentMonth];
//            }else{
//                cuurday = day1[currentMonth];
//            }
//            while(addDay>= cuurday){//还需再跨月
//                if (isleapyear) {
//                    cuurday = day2[currentMonth];
//                }else{
//                    cuurday = day1[currentMonth];
//                }
//                addDay -= cuurday;
//                currentMonth++;
//                if(currentMonth > 12){
//                    currentMonth = 1;
//                }
//            }
//
//        }
//
//        //日
//        if(ifAddMonth == 0){//没有跨月,日按当前开始算
//            currentDay = addDay+day;
//        }else{
//           currentDay = addDay;
//        }
//        printf("%04d-%02d-%02d\n",currentYear,currentMonth,currentDay);
//    }
//
//    return 0;
//}
////
////int *getRandom(){
////    static int r[10];
////    srand((unsigned int)time(NULL));
////    for (int i = 0; i < 10; i++) {
////        r[i] = rand();
////        cout << r[i] << endl;
////    }
////    return r;
////}
////
////void shell_sort(int array[], int length) {
////    int h = 1;
////    h=5;
////    printf("h = %d  \narray:",h);
////    for (int k = 0; k< length; k++) {
////        printf(" %d ",array[k]);
////    }
////    printf("\n");
////    while (h >= 1) {
////        for (int i = h; i < length; i++) {
////            printf("\n\n******* i = %d *******\n",i);
////            for (int j = i; j >= h && array[j] < array[j - h]; j -= h) {
////                printf("i == %d ,j == %d swap: array[%d]=%d, array[%d]=%d\n",i,j,j,array[j],j-h,array[j - h]);
////                std::swap(array[j], array[j - h]);
////            }
////        }
////        h = h / 2;
////    }
////    for (int k = 0; k< length; k++) {
////        printf("  %d  ",array[k]);
////    }
////}
//#include <stdio.h>
//#include <string.h>
////#include <iostream>
////#include <cstdio>
////#include <algorithm>
////
////using namespace std;
//
//struct Student{
//    char name[100];
//    int score;
//};
//
//int type;
//
//void bubble_sort(struct Student arr[], int len) {
//    int i, j;
//    for (i = 0; i < len - 1; i++)
//        for (j = 0; j < len - 1 - i; j++)
//            if (type == 1) {
//                if (arr[j].score > arr[j + 1].score) {
//                    struct Student t = arr[j];
//                    arr[j] = arr[j+1];
//                    arr[j+1] = t;
//                }
//            }else{
//                if (arr[j].score < arr[j + 1].score) {
//                     struct Student t = arr[j];
//                     arr[j] = arr[j+1];
//                     arr[j+1] = t;
//                }
//            }
//
//}
//
//int main(){
//    int num=0;
//
//    while (scanf("%d%d",&num,&type) != EOF) {
//        struct Student* student = (struct Student*)malloc(sizeof(struct Student)*num);
//        for (int i=0; i<num; ++i) {
//            scanf("%s %d",student[i].name,&student[i].score);
//        }
//        bubble_sort(student, num);
//        for (int i=0; i<num; ++i) {
//            printf("\n%s %d",student[i].name,student[i].score);
//        }
//    }
//    return 0;
//}
//
//
////KMP
//#include <stdio.h>
//#include <string.h>
//#include <cstdio>
//using namespace std;
//
//const int MAXM = 10000;
//const int MAXN = 1000000;
//
//int nextTable[MAXM];
//int pattern[MAXM];
//int text[MAXN];
//
//void GetNextTable(int m){
//    int j = 0;
//    nextTable[j] = -1;
//    int i = nextTable[j];
//    while (j<m) {
//        if (i == 1 || pattern[j] == pattern[i]) {
//            i++;
//            j++;
//            nextTable[j]=i;
//        }else{
//            i = nextTable[i];
//        }
//    }
//    return;
//}
//
//int KMP(int n,int m){
//    GetNextTable(m);
//    int i=0,j=0;
//    while (i<n && j<m) {
//        if (j == -1 || text[i] == pattern[j]) {
//            i++;
//            j++;
//        }else{
//            j = nextTable[j];
//        }
//    }
//    if (j == m) {
//        return i - j + 1;
//    }else{
//        return -1;
//    }
//}
//
//
//int main(){
//    int caseNum;
//    scanf("%d",&caseNum);
//    while (caseNum) {
//        caseNum--;
//        int n,m;
//        scanf("%d%d",&n,&m);
//        for (int i = 0; i<n; ++i) {
//            scanf("%d",&text[i]);
//        }
//        for (int j = 0; j<m; ++j) {
//            scanf("%d",&pattern[j]);
//        }
//        printf("%d\n",KMP(n, m));
//    }
//    return 0;
//}
//
//
//
//#include <stdio.h>
//#include <string.h>
//
//
//const int MAXM = 10000;
//const int MAXN = 1000000;
//
//int nextTable[MAXM];
//char pattern[MAXM];
//char text[MAXN];
//
//void GetNextTable(int m){
//    int j = 0;
//    nextTable[j] = -1;
//    int i = nextTable[j];
//    while (j<m) {
//        if (i == 1 || pattern[j] == pattern[i]) {
//            i++;
//            j++;
//            nextTable[j]=i;
//        }else{
//            i = nextTable[i];
//        }
//    }
//    return;
//}
//
//int KMP(int n,int m){
//    GetNextTable(m);
//    int i=0,j=0,number = 0;
//    while (i<n) {
//        if (j == -1 || text[i] == pattern[j]) {
//            i++;
//            j++;
//        }else{
//            j = nextTable[j];
//        }
//        if (j == m) {
//            number ++;
//        }
//    }
//    return number;
//}
//
//int main(){
//    int caseNum;
//    scanf("%d",&caseNum);
//    while (caseNum) {
//        caseNum--;
//        gets(text);
//        gets(pattern);
//        printf("%d",KMP((int)strlen(text), (int)strlen(pattern)));
//    }
//    return 0;
//}
///*
// 字符串除法
// */
//char* Devide(char* str,int x){
//    int rema = 0;//余数
//    for (int i = 0; i<strlen(str); ++i) {//除法从高位向低位
//        int current = rema*10+str[i]-'0';//当前位 + 高一位的余数
//        str[i] = current/x +'0';//(当前位 + 高一位的余数)/x
//        rema = current%x;
//    }
////    int pos = 0;
////    while (str[pos] == '0') {
////        pos ++;
////    }
//    return str;
//}
///*
//字符串乘法
//*/
//char * Multiple(char *str,int x){
//    int carry = 0;//进位
//    for (int i = (int)strlen(str)-1; i >= 0; --i) {//低位向高位
//        int current = carry + (str[i] - '0') * x;//当前位乘x + 进位
//        str[i] = (char)(current % 10 + '0');//(当前位乘x + 进位)%10
//        carry = current / 10;
//    }
//    if (carry!=0) {
//        int length = (int)strlen(str);
//        char str2[1+length];
//        str2[0] = ((char)('0'+carry));
//        str2[1] = '\0';
//        strcat(str2,str);
//        return  str2;
//    }
//    return str;
//}
//
///*
//字符串加法
//*/
//char * Add(char *str,int x){
//    int carry = x;
//    for (int i = (int)strlen(str)-1; i >= 0; --i) {//低位向高位
//        int current = carry + (str[i] - '0');//当前位乘x + 进位
//        str[i] = (char)(current % 10 + '0');//(当前位乘x + 进位)%10
//        carry = current / 10;
//    }
//    if (carry!=0) {
//        int length = (int)strlen(str);
//        char str2[1+length];
//        str2[0] = ((char)('0'+carry));
//        str2[1] = '\0';
//        strcat(str2,str);
//        return  str2;
//    }
//    return str;
//}
//char IntToChar(int x){
//    if (x<10) {
//        return x+'0';
//    }else{
//        return x-10+'a';
//    }
//}
//
//int CharToInt(char x){
//    if (x >= '0' && x<= '9') {
//        return x - '0';
//    }else if(x >= 'a' && x<= 'z'){
//        return x-'a'+10;
//    }else{
//        return x-'A'+10;
//    }
//}
//#include <stdio.h>
//#include <string.h>
//#import <objc/message.h>
////#include <iostream>
////#include <cstdio>
////#include <vector>
////using namespace std;
////
//
//
//
//int prime[5000];//2-10000内的素数数量不会超过一半
//int numberOfPrime = 0;
//
//int main(){
//
//    if (numberOfPrime == 0) {
//        prime[0] = 2;
//        numberOfPrime ++;
//    }
//    for(int i = 3;i<10000; i = i+2){
//        int isPrime = 1;
//        int j;
//        for (j = 0; (j<numberOfPrime) && (prime[j] <= sqrt(i)); ++j) {
//            if (i%prime[j]==0) {
//                isPrime = 0;
//                continue;
//            }
//        }
//        if (isPrime == 1) {
//            prime[numberOfPrime++] = i;
//        }
//    }
//    int n;
//    while (scanf("%d",&n) != EOF) {
//        if (n <2) {
//            printf("-1");
//        }else{
//            for (int index = 0; index < numberOfPrime && prime[index] < n; ++index) {
//                if (prime[index] % 10 == 1) {
//                    printf("%d ", prime[index]);
//                }
//            }
//        }
//        printf("\n");
//    }
//    return 0;
//
//}
//
///*
//快速幂 a^b 取后mod位
//*/
//int FastEx(int a,int b,int mod){
//    int answer = 1;
//    while (b != 0) {
//        if (b%2 == 1) {
//            answer *= a;
//            answer %= mod;
//        }
//        b/=2;
//        a*=a;
//        a%=mod;
//    }
//    return answer;
//}
////C 可变参数
//#include <stdarg.h>
//double average(int num,...)
//{
//
//    va_list valist;
//    double sum = 0.0;
//    int i;
//
//    /* 为 num 个参数初始化 valist */
//    va_start(valist, num);
//
//    /* 访问所有赋给 valist 的参数 */
//    for (i = 0; i < num; i++)
//    {
//       sum += va_arg(valist, int);
//    }
//    /* 清理为 valist 保留的内存 */
//    va_end(valist);
//
//    return sum/num;
//}
//#include <stdio.h>
//#include <string.h>
//
//struct LNode{
//    char data;
//    struct LNode *leftNode;
//    struct LNode *rightNode;
//};
//int pos = 0;
//void InOrder(struct LNode *a){
//    if (a == NULL) {
//        return;
//    }
//    if (a->leftNode != NULL) {
//        InOrder(a->leftNode);
//    }
//    printf("%c ",a->data);
//    if (a->rightNode != NULL) {
//        InOrder(a->rightNode);
//    }
//    return;
//}
//
//struct LNode* BuildTreeX(char *str){
//    if (pos >= strlen(str)) {
//        return NULL;
//    }
//    char c = str[pos++];
//    if (c == '#') {
//        return NULL;
//    }
//    struct LNode *root = (struct LNode*)malloc(sizeof(struct LNode));
//    root->data = c;
//    root->leftNode = BuildTreeX(str);
//    root->rightNode = BuildTreeX(str);
//    return root;
//}
//
//int main(){
//    char str[100];
//    gets(str);
//    struct LNode *root;
//    root = BuildTreeX(str);
//    InOrder(root);
//    return 0;
//}
//#include <stdio.h>
//#include <string.h>
//
//struct LNode{
//    int data;
//    struct LNode *leftNode;
//    struct LNode *rightNode;
//};
//
//struct LNode* Insert(struct LNode *root,int x, int fatherdata){
//    if (root == NULL) {
//        root = (struct LNode*)malloc(sizeof(struct LNode));
//        /*
//         注意⚠️
//         root->data = x;
//         root->leftNode = NULL;
//         root->rightNode = NULL;
//         root的每项必须初始化 不然会报错!!!!!!!!!!!
//         ⚠️
//         */
//        root->data = x;
//        root->leftNode = NULL;
//        root->rightNode = NULL;
//        printf("%d\n",fatherdata);
//    }else if(x < fatherdata){
//        root->leftNode = Insert(root->leftNode, x, root->data);
//    }else{
//        root->rightNode = Insert(root->rightNode, x, root->data);
//    }
//    return root;
//}
//
//
//int main(){
//
//    int n;
//    while (scanf("%d",&n)!=EOF) {
//        struct LNode *root = NULL;
//        for (int i = 0; i<n; ++i) {
//            int x;
//            scanf("%d",&x);
//            root = Insert(root, x, -1);
//        }
//    }
//    return 0;
//}
///*
//5
//2 5 1 3 4
//*/
//#include <stdio.h>
//#include <string.h>
//
//const int MAXN = 1000;
//
//int father[MAXN];
//int height[MAXN];
//
//void Init(int n){
//    for (int i = 0; i<=n; ++i) {
//        father[i] = i;
//        height[i] = 0;
//    }
//}
//
//int Find(int x){
//    if (x != father[x]) {
//        father[x] = Find(father[x]);
//    }
//    return father[x];
//}
//
//void Union(int x, int y){
//    x = Find(x);
//    y = Find(y);
//    if (x != y) {
//        if (height[x] < height[y]) {
//            father[x] = y;
//        }else if(height[x] > height[y]){
//            father[y] = x;
//        }else{
//            father[y] = x;
//            height[x]++;
//        }
//    }
//    return;
//}
//
//
//int main(){
//
//    int n,m;
//    while (scanf("%d",&n)!=EOF) {
//        if (n == 0) {
//            break;
//        }
//        scanf("%d",&m);
//        Init(n);
//        while (m--) {
//            int x,y;
//            scanf("%d",&x);
//            scanf("%d",&y);
//            Union(x, y);
//        }
//        int answer = -1;
//        for (int i = 1; i <= n; ++i) {
//            if (Find(i) == i) {
//                answer++;
//            }
//        }
//        printf("\n%d",answer);
//     
//    }
//    return 0;
//}
/*
 产生随机数
 */
//#include <stdio.h>
//#include <string.h>
//#include <stdlib.h>
//#include <time.h>
//
//
//int main(){
//
//    int n,m;
//    time_t t;
//
//    srand((unsigned)time(t));
//    for (int i = 0; i<10; ++i) {
//        printf("\n%d",rand()%10);
//    }
//
//    return 0;
//}
//#include <stdio.h>
//#include <string.h>
//#include <stdlib.h>
//
//const int MAXN = 100;
//
//struct Edge{
//    int from;
//    int to;
//    int length;
//};
//
//int Compare(const void * a, const void * b){
//    return (*(struct Edge *)a).length > (*(struct Edge *)b).length;
//}
//
//struct Edge edge[MAXN * MAXN];
//int father[MAXN];
//int height[MAXN];
//
//void Init(int n){
//    for (int i = 0; i < n; ++i) {
//        father[i] = i;
//        height[i] = 0;
//    }
//    return;
//}
//
//int Find(int x){
//    if (x != father[x]) {
//        father[x] = Find(father[x]);
//    }
//    return father[x];
//}
//
//void Union(int x,int y){
//    x = Find(x);
//    y = Find(y);
//    if (x != y) {
//        if (height[x] > height[y]) {
//            father[y] = x;
//        }else if (height[x] < height[y]){
//            father[x] = y;
//        }else{
//            father[x] = y;
//            height[x]++;
//        }
//    }
//    return;
//}
//
//int Kruskal(int n,int edgenum){
//    Init(n);
//    qsort(edge, edgenum, sizeof(struct Edge), Compare);
//    int sum = 0;
//    for (int i = 0; i< edgenum; ++i) {
//        if (Find(edge[i].from) != Find(edge[i].to)) {
//            Union(edge[i].from, edge[i].to);
//            sum += edge[i].length;
//        }
//    }
//    return sum;
//}
//
//int main(){
//
//    int n;
//    while (scanf("%d",&n)!= EOF) {\
- 2
//        if (n == 0) {
//            break;
//        }
//        int edgenum = n*(n-1)/2;
//        printf("\n*** %d ****\n",edgenum);
//        for (int i = 0; i<edgenum; i++) {
//            scanf("%d%d%d",&edge[i].from,&edge[i].to,&edge[i].length);
//        }
//        int answer = Kruskal(n, edgenum);
//        printf("%d\n",answer);
//    }
//    return 0;
//}
//#include <stdio.h>
//#include <string.h>
//#include <stdlib.h>
//
//
//int main(){
//
//    FILE *fp = NULL;
//    char buff[1000];
//    fp = fopen("/Users/zhangyuanyi/Desktop/work/TestCDemo/TestCDemo/test.txt", "r");
//    fscanf(fp, "%s", buff);
//    printf("1: %s\n", buff );
//
////    FILE *fp = NULL;
////    char buff[255];
////
////    fp = fopen("/tmp/test.txt", "r");
////    fscanf(fp, "%s", buff);
////    printf("1: %s\n", buff );
////
////    fgets(buff, 255, (FILE*)fp);
////    printf("2: %s\n", buff );
////
////    fgets(buff, 255, (FILE*)fp);
////    printf("3: %s\n", buff );
////    fclose(fp);
//    return 0;
//}

//#include <stdio.h>
//#include <string.h>
//#include <stdlib.h>
//
//const int MAXN = 100;
//
//int matrix[MAXN][MAXN];
//int total[MAXN][MAXN];
//int arr[MAXN];
//int dp[MAXN];
//
//void PrintfMatrix(int row,int col){
//    printf("\n");
//    for (int i = 0; i < row; ++i) {
//        for (int j = 0;j < col; ++j) {
//            printf("%d ",total[i][j]);
//        }
//        printf("\n");
//    }
//}
//
//int MaxSubsequence(int n){
//    int max = 0;
//    for (int i = 0; i < n; i++) {
//        if (i == 0) {
//            dp[i] = arr[i];
//        }else{
//            if (arr[i] > dp[i - 1]+arr[i]) {
//                dp[i] = arr[i];
//            }else{
//                dp[i] =  dp[i - 1]+arr[i];
//            }
//            if (max < dp[i]) {
//                max = dp[i];
//            }
//        }
//    }
//    return max;
//}
//
//int MaxSubMatrix(int n){
//    int max = 0;
//    for (int i = 0; i < n; ++i) {
//        for (int j = i; j < n; ++j) {
//            for (int k = 0; k < n; ++k) {
//                if (i == 0) {
//                    arr[k] = total[j][k];
//                }else{
//                    arr[k] = total[j][k] - total[i-1][k];
//                }
//            }
//           int kmax = MaxSubsequence(n);
//            if (max < kmax) {
//                max = kmax;
//            }
//        }
//    }
//    return max;
//}
// 
//int main(){
//    int n = 0;
//    while (scanf("%d",&n)!=EOF) {
//        for (int i = 0; i < n; ++i) {
//            for (int j = 0;j < n; ++j) {
//                scanf("%d",&matrix[i][j]);
//            }
//        }
//        for (int i = 0; i < n; ++i) {
//            for (int j = 0; j < n; ++j) {
//                if (i == 0) {
//                    total[i][j] = matrix[i][j];
//                }else{
//                    total[i][j] = total[i - 1][j] + matrix[i][j];
//                }
//                
//            }
//        }
//        int ans = MaxSubMatrix(n);
//        printf("%d\n",ans);
//    }
//    return 0;
//}
//#include <stdio.h>
//#include <string.h>
//#include <stdlib.h>
//
//const int MAXN = 1001;
//
//int main(){
//    float a,b;
//    /*
//     综合总成绩=（初试总分÷5）×50%+（复试总分÷2）×50%
//     调剂考生
//     综合总成绩=（（初试总分-专业课分）÷3.5×50% +（复试总分÷2）×50%
//     */
//    while (scanf("%f%f",&a,&b)!=EOF) {//a是复试总分*0.5，b是综合总成绩
//        float c = b - a*0.6;//去掉复试成绩
//        float d = c/0.6*2;//初试总分-专业课分
//        printf("\n%.0f",d);
//    }
//    return 0;
//}

//#include <stdio.h>
//#include <string.h>
//#include <stdlib.h>
///*
// 杭电
// 第三题题目如下：
// 瓜农王大爷去年种西瓜赚了不少钱。看到收入不错，今年他又重新开辟了n个西瓜地。
// 为了能给他的n个西瓜地顺利的浇上水，对于每个西瓜地他可以选择在本地打井，也可以修管道从另一个瓜地（这个瓜地可能打了井；也可能没打井，他的水也是从其他瓜地引来的）将水引过来。
// 当然打井和修管道的费用有差别。已知在第i个西瓜地打井需要耗费wi元，在第i、j个西瓜地之间修管道需要耗费pi,j元。
// 现在的问题是：王大爷要想使所有瓜地都被浇上水，至少需要花费多少钱（打井与修管道的费用和）？
// 由于瓜地较多，王大爷无法选择在哪些（个）瓜地打井，哪些西瓜地之间修管道。
// 请你编程帮王大爷做出决策，求出最小费用。
// 输入格式
// 第1行，一个正整数n，代表西瓜地的数量。
// 以下n行，依次给出整数w1..wn（每块西瓜地的打井费用）。
// 紧接着是一个n*n的整数矩阵，矩阵的第i行第j列的数代表pi,j（两块西瓜地之间建立管道的费用）。每行的两个数之间有一个空格隔开。
//
// 样例说明
// 在第4个瓜地打井（费用为3），然后将第2,3，4个瓜地与第1个瓜地间修管道（费用分别是2,2,2），这样水可以经过管道从4流向1，然后经1再流向2和3；
// 在第5个瓜地打井（费用为1），5和6之间修管道（费用为9）。
// 这样一共打了2口井，修了4条管道，能给所有的6个瓜地浇水，费用是：3+2+2+2+1+9=19。
// */
//const int MAXN = 20;
//
//int P[MAXN][MAXN];
//int W[MAXN];
//
//int main(){
//    int n = 0;
//    scanf("%d",&n);
//    for (int i = 0; i< n; ++i) {
//        scanf("%d",&W[i]);
//    }
//    for (int i = 0; i< n; ++i) {
//        for (int j = 0; j< n; ++j) {
//            scanf("%d",&P[i][j]);
//        }
//    }
//    int k = 0;
//    int costminend = 0;
//    printf("n = %d \n",n);
//    for (int i = 0; i < n; ++i) {
//        int costmin = W[i];//第i个作为起点打井
//        k = 0;
//        while (k < n) {//加入第k个 要么打井要么连通
//            if (k != i) {
//                int min = P[k][i];//默认连i点
//                for (int j = 0; j <= k-1; ++j) {//连其余已经连接的点
//                    if (min > P[k][j]) {
//                        min = P[k][j];
//                    }
//                }
////                printf("min P[%d] = %d",k,min);
//                if (min > W[k]) {//若>打井成本
//                    min = W[k];
//                }
////                printf("  min = %d\n",min);
//                costmin += min;
////                printf("***** i = %d \n",i);
//            }
//            k++;
//        }
//        if (i == 0 || costminend > costmin) {
//            costminend = costmin;
//        }
//        printf("the %d time = %d\n",i,costminend);
//    }
//
//    printf("\n = %d",costminend);
//    return 0;
//}
////6
////5
////4
////4
////3
////1
////20
////0 2 2 2 9 9
////2 0 3 3 9 9
////2 3 0 4 9 9
////2 3 4 0 9 9
////9 9 9 9 0 9
////9 9 9 9 9 0
