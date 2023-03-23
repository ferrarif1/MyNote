////
////  动态规划.cpp
////  TestCDemo
////
////  Created by 张元一 on 2020/10/25.
////  Copyright © 2020 张元一. All rights reserved.
////
//
//#include<stdio.h>
//#include<algorithm>
//#include<string.h>
//using namespace std;
//long long dp[1005][1005];
//const int mod=1e9+7;
//int main()
//{
//    int n,m,i,j;
//        scanf("%d%d",&n,&m);
//        memset(dp,0,sizeof(dp));
//        for(i=1;i<=n;i++)
//        {
//            for(j=1;j<=m;j++)
//            {
//                if(i==1&&j==1)    dp[i][j]=1;
//                else dp[i][j]=(dp[i-1][j]+dp[i][j-1])%mod;
//            }
//        }
//        printf("%ld\n",dp[n][m]);
//    return 0;
//}
// 
