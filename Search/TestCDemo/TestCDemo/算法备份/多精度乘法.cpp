////
////  多精度乘法.cpp
////  TestCDemo
////
////  Created by 张元一 on 2020/11/14.
////  Copyright © 2020 张元一. All rights reserved.
////
//
//# include <stdio.h>
// 
//void swap(int *i, int *j)
//{
//    int temp = *i;
//    *i = *j;
//    *j = temp;
//}
//void perm(int *p, int  k, int m)
//{
//    if (k == m)
//    {
//        for (int i = 0; i <= m; i++)
//        {
//            printf("%d ", p[i]);
//        }
//        printf("\n");
//    }
//    else
//    {
//        for (int j = k; j <= m; j++)
//        {
//            swap(&p[k], &p[j]); //不断变化前缀
//            perm(p, k + 1, m);  //递归
//            swap(&p[k], &p[j]); //还原集合
//        }
//    }
//}
//void Prt(int arr[], int length){
//    printf("result = ");
//    for (int i = length-1; i >= 0; i--) {
//        printf("%d ", arr[i]);
//    }
//}
//int main()
//{
//    /*
//     多精度乘法
//     */
//    int x[4] = { 4,7,2,9 };
//    int y[3] = { 7,4,8};
//    int result[11];
//    for (int i = 0; i< 11; i++) {
//        result[i] = 0;
//    }
//    int c = 0;
//    int u = 0;
//    int v = 0;
//    for (int i = 0; i < 3; i++) {//0-t t=2
//        c = 0;
//        for (int j = 0; j < 4; j++) {//0-n n=3
//            int k = result[i+j] + x[j]*y[i] + c;
//            u = k/10;
//            v = k%10;
//            printf("\n u = %d v = %d ", u,v);
//            Prt(result, 11);
//            result[i+j] = v;
//            c = u;
//        }
//        result[i+3+1]=u;
//    }
//    Prt(result, 11);
//    
//    return 0;
//}
