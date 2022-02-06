Circom是零知识证明中的电路编程语言，方便设计和开发零知识证明的数值电路。

Circom工具包包括：

    Circom: 电路开发语言；
    Circomlib: Circom 模板库；
    SnarkJS: JavaScript zk-SNARK实现；

Circom电路示例为：
```
template Multiplier() {
    signal private input a;
    signal private input b;
    signal output c;
    signal inva;
    signal invb;

    inva <-- 1/(a-1);
    (a-1)*inva === 1;

    invb <-- 1/(b-1);
    (b-1)*invb === 1;

    c <== a*b;
}
component main = Multiplier();
```

    <--： 赋值，不创建任何约束
    ===: 添加一个约束，而非赋值
Circom 基础

Templates

采用template创建通用电路， 利用 component进行实例化, main component用于启动执行。

template 可以递归定义。

functions 用于实现计算，不生成约束，可递归定义。

域元素

域元素表示为：Z/pZ

布尔类型： TRUE: 非0的域元素表示； FALSE: 元素

数组：var x[3] = [2,8,4];

带符号的整数：

    val(z) = z-p
    val(z)= z

Signals

Signal赋值采用 <--, <== 或 --> , ==>

对于<==, ==> , 赋值的同时，会生成约束条件；

对于<--, -->： 计算赋值，不产生约束条件。

=== 是约束赋值。

普通变量采用var定义，用= 赋值。

约束生成

主要有以下几种形式：

    常量： 只允许常量值
    线性表达式：例如2*x + 3*y + 2
    二次表达式： A*B + C
    非二次表达式。
相关链接：
https://github.com/iden3/circom
https://zhuanlan.zhihu.com/p/143519030
https://github.com/ferrarif1/Samples
