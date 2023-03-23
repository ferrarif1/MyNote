////
////  qipanfugai.cpp
////  TestCDemo
////
////  Created by 张元一 on 2020/10/21.
////  Copyright © 2020 张元一. All rights reserved.
////
///*
// 棋盘覆盖
// */
//#include <stdio.h>
//#include <stdlib.h>
//
//int num = 0;
//int Matrix[100][100];
//void chessBoard(int tr, int tc, int dr, int dc, int size);
//static int numx = 0;
//static int sizex = 0;
//
//void printMatrix(){
//    printf("\n\n\n************* %d **********\n\n\n",numx++);
//    for (int r = 0; r < sizex; r++)
//    {
//        for (int c = 0; c < sizex; c++)
//        {
//            printf("%2d ",Matrix[r][c]);
//        }
//        printf("\n");
//    }
//}
//
//int main()
//{
//    int size,row,col;
//    printf("请输入棋盘的行列号");
//    scanf("%d",&size);
//    printf("请输入特殊方格的行列号(从0开始)");
//    scanf("%d %d",&row,&col);
//    sizex = size;
//    Matrix[row][col] = -1;
//    chessBoard(0,0,row,col,size);
//
//    printMatrix();
//
//    return 0;
//}
//
//
///*
// tr,tc -------- 子棋盘起始点
// dr,dc -------- 特殊点
// size  -------- 子棋盘大小
// */
//
//void chessBoard(int tr, int tc, int dr, int dc, int size)
//{
//
//    int s,t;
//    if (size==1) return;
//    printMatrix();
//    s = size/2;    //分割棋盘
//    t = ++num;      //L型骨牌号
//    if (dr < tr + s && dc < tc +s)                //覆盖左上角子棋盘
//    {
//        //特殊方格在此棋盘中
//        chessBoard(tr,tc,dr,dc,s);
//    }
//    else            //此棋盘中无特殊方格
//    {
//        //用t号L型骨牌覆盖右下角
//        Matrix[tr+s-1][tc+s-1] = t;
//        //覆盖其余方格
//        chessBoard(tr,tc,tr+s-1,tc+s-1,s);
//    }
//    //覆盖右上角子棋盘
//    if (dr < tr + s && dc >= tc + s )           //
//    {
//        //特殊方格在此棋盘中
//        chessBoard(tr,tc+s,dr,dc,s);
//    }
//    else      //此棋盘中无特殊方格
//    {
//        //用t号L型骨牌覆盖左下角
//        Matrix[tr+s-1][tc+s] = t;
//        //覆盖其余方格
//        chessBoard(tr,tc+s,tr+s-1,tc+s,s);
//    }
//     //覆盖左下角子棋盘
//    if (dr >= tr + s && dc < tc + s)
//    {
//        //特殊方格在此棋盘中
//        chessBoard(tr+s,tc,dr,dc,s);
//    }
//    else
//    {
//        //用t号L型骨牌覆盖右上角
//        Matrix[tr+s][tc+s-1] = t;
//        //覆盖其余方格
//        chessBoard(tr+s,tc,tr+s,tc+s-1,s);
//    }
//      //覆盖右下角子棋盘
//    if (dr >= tr + s && dc >= tc + s)
//    {
//          //特殊方格在此棋盘中
//        chessBoard(tr+s,tc+s,dr,dc,s);
//    }
//    else
//    {
//        //用t号L型骨牌覆盖左上角
//        Matrix[tr+s][tc+s] = t;
//        //覆盖其余方格
//        chessBoard(tr+s,tc+s,tr+s,tc+s,s);
//    }
//
//}
