//#include <bits/stdc++.h>
//using namespace std;
//int a[101],b[101],c[101],d,i;
//void shuru(int a[])
//{
//    string s;
//    cin>>s;              //读入字符串
//    a[0]=s.length();      //a[0]储存字符串的长度
//    for (i=1;i<=a[0];i++)
//        a[i]=s[a[0]-i]-'0';   //将字符串转化为数组a，并倒序储存，模拟竖式计算
//}
//void shuchu(int a[])// 用于输出最后的答案，并注意若答案为0的情况
//{
//    int i;
//    if (a[0]==0) {cout<<"0"<<endl;return;}
//    for (i=a[0];i>0;i--) cout<<a[i];
//    cout<<endl;
//    return;
//}
//int bijiao(int a[],int b[])//比较a和b的大小关系，若a>b则为1，若a<b则为-1，若a=b则为0
//{
//    int i;
//    if (a[0]>b[0]) return 1;  //若a的位数大于b，则a>b
//    if (a[0]<b[0]) return -1;  //若a的位数小于b，则a<b
//    for (i=a[0];i>0;i--){if (a[i]>b[i]) return 1;if (a[i]<b[i]) return -1;} //从高位到低位依次比较，找出大小关系
//    return 0;
//}
//void jian(int a[],int b[])  //a数组既做被除数，又作为储存余数
//{
//    int pd;
//    int i;
//    pd=bijiao(a,b);            //调用函数比较ab大小
//    if (pd==0) {a[0]=0;return;}  //相等
//    if (pd==1)
//    {
//        for (i=1;i<=a[0];i++)
//        {
//            if (a[i]<b[i]) {a[i+1]--;a[i]+=10;}   //若不够减向上一位借一位
//            if (a[i]>=b[i])  a[i]-=b[i];
//        }
//        while((a[a[0]]==0)&&(a[0]>0)) a[0]--;
//        return;
//    }
//}
//void numcpy(int p[],int q[],int det) //复制p数组到q数组从det开始的地方
//{
//    for (int i=1;i<=p[0];i++) q[i+det-1]=p[i];//将数组右移，使两个数组右端对齐，形参q数组储存右移后的结果
//    q[0]=p[0]+det-1;
//}
//void chugao(int a[],int b[],int c[])
//{
//    int i,tmp[101];
//    c[0]=a[0]-b[0]+1;
//    for (i=c[0];i>0;i--)
//    {
//        memset(tmp,0,sizeof(tmp));     //tmp数组清零
//        numcpy(b,tmp,i);               //将除数b右移后复制给tmp数组，注意用i控制除数位数
//        while (bijiao(a,tmp)>=0){c[i]++;jian(a,tmp);}   //减法模拟除法，并计数
//    }
//    while((c[c[0]]==0)&&(c[0]>0)) c[0]--;   // 控制最高位的0
//}
//int main()//主程序
//{
//    memset(a,0,sizeof(a));
//    memset(b,0,sizeof(b));
//    memset(c,0,sizeof(c));
//    shuru(a);shuru(b);
//    chugao(a,b,c);
//    shuchu(c);
//    shuchu(a);
//    return 0;
//}
