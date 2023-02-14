extern crate core;
use core::bls12381::big::BIG;
use core::rand::RAND;

use core::bls12381::ecp::ECP;
use core::bls12381::ecp2::ECP2;
use core::bls12381::rom;

pub mod bbs_plus;
pub mod cl;
pub mod ps;

use bbs_plus::signature::{BBSPlusKey, BBSPlusPublicKey, BBSPlusSig};
use ps::signature::{key_generation, SecretKey, Signature};

use std::fs;
use std::fs::File;
use std::fs::OpenOptions;
use std::io::prelude::*;
use std::io::stdin;
use std::collections::HashMap;
use std::thread;
use std::time::Duration;
use std::sync::mpsc;

fn test2() -> std::io::Result<u32> {
    let mut file = OpenOptions::new().append(true).open("src/text.txt")?;
    file.write(b" And Shit")?;
    //以读写权限打开
    // let mut file = OpenOptions::new()
    //         .read(true).write(true).open("D:\\text.txt")?;

    // file.write(b"COVER")?;
    Ok(200)
}

trait Descriptive {
    fn describe(&self) -> String {
        String::from("[Object]")
    }
}

struct Person {
    name: String,
    age: u8
}

impl Descriptive for Person {
    fn describe(&self) -> String {
        format!("{} {}", self.name, self.age)
    }
}


fn main() {
    //test start
    println!("******************** Test Start *************************\n\n");
    //args
    println!("************ System args Start **********\n");
    let args = std::env::args();
    println!("{:?}", args);
    for arg in args {
        println!(" {} \n", arg);
    }
    println!("\n************ System args End **********\n\n");

    //read from command line
    // let mut str_buf = String::new();
    // stdin().read_line(&mut str_buf)
    //     .expect("Failed to read line.");

    // println!("Your input line is \n{}", str_buf);

    println!("\n************ IO Read Start **********\n");
    //io test 文本文件内容读入字符串
    let text = fs::read_to_string("src/test.txt").unwrap();
    println!("The content of test.txt : {}", text);

    //如果要读取的文件是二进制文件，我们可以用 std::fs::read 函数读取 u8 类型集合
    let content = fs::read("src/test.txt").unwrap();
    println!("The content of test.txt :{:?}", content);

    //io test 2 文件流读取方式：
    let mut buffer = [0u8; 5];
    let mut file = fs::File::open("src/test.txt").unwrap();
    file.read(&mut buffer).unwrap();
    println!("The 1st 5 content of test.txt :{:?}", buffer);
    file.read(&mut buffer).unwrap();
    println!("The 2nd 5 content of test.txt :{:?}", buffer);
    println!("\n************ IO Read End **********\n");

    println!("\n************ IO Write Start **********\n");
    //一次性写入
    fs::write("src/text.txt", "Shit!").unwrap();
    //使用流的方式写入文件内容
    let mut file = File::create("src/text.txt").unwrap();
    file.write(b"BullShit").unwrap();
    //File 类中不存在 append 静态方法，但是我们可以使用 OpenOptions 来实现用特定方法打开文件：

    let resu = test2();
    if let Ok(r) = resu {
        println!("File append successfully :{}.", r);
    } else {
        println!("Failed to append the file.");
    }
    println!("\n************ IO Write End **********\n");
    println!("\n************ Vec Start **********\n");

    let mut vector = vec![1, 2, 4, 8];
    vector.push(16);
    vector.push(32);
    vector.push(64);
    println!("{:?}", vector);

    let mut v1: Vec<i32> = vec![1, 2, 4, 8];
    let mut v2: Vec<i32> = vec![16, 32, 64];
    v1.append(&mut v2);
    println!("{:?}", v1);

    let mut v3 = vec![1, 2, 4, 8];
    //因为向量的长度无法从逻辑上推断，get 方法无法保证一定取到值，所以 get 方法的返回值是 Option 枚举类，有可能为空。
    println!(
        "{}",
        match v3.get(0) {
            Some(value) => value.to_string(),
            None => "None".to_string(),
        }
    );

    let v = vec![1, 2, 4, 8];
    println!("v[1]={}", v[1]);

    let v = vec![100, 32, 57];
    for i in &v {
        println!("{}", i);
    }
    //如果遍历过程中需要更改变量的值：
    let mut v4 = vec![100, 32, 57];
    for i in &mut v4 {
        *i += 50;
    }
    println!("v[0]={}", v4[0]);

    println!("\n************ Vec End **********\n");

    println!("\n************ String Start **********\n");

    let mut s = String::from("run");
    s.push_str("oob"); // 追加字符串切片
    s.push('!'); // 追加字符

    let s1 = String::from("Hello, ");
    let s2 = String::from("world!");
    let s3 = s1 + &s2; //此时s1已经没了 s2还在，s1由s3代替
    println!("s2={} s3={}", s2, s3);

    let s1 = String::from("tic");
    let s2 = String::from("tac");
    let s3 = String::from("toe");
    let sx = s1 + "-" + &s2 + "-" + &s3;
    println!("sx={}", sx);

    let s1 = String::from("tic");
    let s2 = String::from("tac");
    let s3 = String::from("toe");

    let sx2 = format!("{}-{}-{}", s1, s2, s3);
    println!("sx2={}", sx2);
    //中文是 UTF-8 编码的，每个字符长 3 字节
    let ss = "hello你好";
    let lenss = ss.len();//11 统计字节
    let lenss2 = ss.chars().count();//7 如果想统计字符数量可以先取字符串为字符集合
    println!("lenss={} lenss2={}", lenss,lenss2);

    let s = String::from("hello中文");
    for c in s.chars() {
        println!("{}", c);
    }
    //从字符串中取单个字符 
    //nth 函数是从迭代器中取出某值的方法，不要在遍历中这样使用！因为 UTF-8 每个字符的长度不一定相等！
    let s = String::from("EN中文");
    let a = s.chars().nth(2);
    println!("{:?}", a);
    //如果想截取字符串字串：
    let s = String::from("EN中文");
    let sub = &s[0..2];
    println!("{}", sub);
    //但是注意此用法有可能肢解一个 UTF-8 字符！那样会报错：
    //thread 'main' panicked at 'byte index 3 is not a char boundary; it is inside '中' (bytes 2..5) of `EN中文`'
    // let sub = &s[0..3];
    // println!("{}", sub);

    println!("\n************ String End **********\n");
    println!("\n************ HashMap Start **********\n");
    let mut map = HashMap::new();

    map.insert("color", "red");
    map.insert("size", "10 m^2");
    
    println!("{}", map.get("color").unwrap());

    for p in map.iter() {
        println!("{:?}", p);
    }

    //如果没有键为 "color" 的键值对就添加它并设定值为 "red"，否则将跳过
    map.entry("color").or_insert("red");

    //在已经确定有某个键的情况下如果想直接修改对应的值
    let mut map = HashMap::new();
    map.insert(1, "a");
    if let Some(x) = map.get_mut(&1) {
        *x = "b";
    }

    println!("\n************ HashMap End **********\n");
    println!("\n************ Trait Start **********\n");
    let cali = Person {
        name: String::from("Cali"),
        age: 24
    };
    println!("{}", cali.describe());
    println!("\n************ Trait End **********\n");
    println!("\n************ Thread Start **********\n");
   //子线程还没运行完5次，就随主线程停止了
    thread::spawn(|| {
        for i in 0..5 {
            println!("spawned thread print {}", i);
            thread::sleep(Duration::from_millis(1));
        }
    });
    
    for i in 0..3 {
        println!("main thread print {}", i);
        thread::sleep(Duration::from_millis(1));
    }
    //join 方法可以使子线程运行结束后再停止运行程序。
    println!("\n Use join：");
    let handle = thread::spawn(|| {
        for i in 0..5 {
            println!("spawned thread print {}", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 0..3 {
        println!("main thread print {}", i);
        thread::sleep(Duration::from_millis(1));
    }

    handle.join().unwrap();

    //闭包是可以保存进变量或作为参数传递给其他函数的匿名函数。闭包相当于 Rust 中的 Lambda 表达式
    let inc = |num: i32| -> i32 {
        num + 1
    };
    println!("inc(5) = {}", inc(5));
    //闭包可以省略类型声明使用 Rust 自动类型判断机制:
    let inc = |num| {
        num + 1
    };
    println!("inc(5) = {}", inc(5));

    //子线程用主线程变量：
    //在子线程中尝试使用当前函数的资源，这一定是错误的！因为所有权机制禁止这种危险情况的产生，它将破坏所有权机制销毁资源的一定性。我们可以使用闭包的 move 关键字来处理：
    let s = "hello";
    let handle = thread::spawn(move || {
        println!("{}", s);
    });
    handle.join().unwrap();

    //子线程发送消息给主线程：
    //Rust 中一个实现消息传递并发的主要工具是通道（channel），通道有两部分组成，一个发送者（transmitter）和一个接收者（receiver）。std::sync::mpsc 包含了消息传递的方法：
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let val = String::from("hi");
        tx.send(val).unwrap();
    });

    let received = rx.recv().unwrap();
    println!("Got: {}", received);


    println!("\n************ Thread End **********\n");
    println!("\n\n******************** Test End *************************");
    //test end
/***************************************************************************************************************************************************/
    // Extract order of curve
    let mut q = BIG::new_ints(&rom::CURVE_ORDER);
    
    let mut raw2: [u8; 50] = [0; 50];
    let mut rng2 = RAND::new();
    rng2.clean();
    for i in 0..50 {
        raw2[i] = i as u8
    }
    rng2.seed(50, &raw2);

    println!("\n\n******************** BBS+ Signature Test Start *************************");
    println!("\n\n******************** Key Gen *************************");

    let attributes = vec!["name=alice", "age=122", "address=X"];

    let mut bbs_plus_key = BBSPlusKey::new(attributes.len(), &q, &mut rng2);

    println!("BBSPK={:?}",bbs_plus_key.pk.w.tostring());
    println!("PK h0={:?}",bbs_plus_key.pk.h0.tostring());
    println!("PK h1={:?}",bbs_plus_key.pk.h[1].tostring());
    println!("PK h2={:?}",bbs_plus_key.pk.h[2].tostring());

    println!("\n\n******************** Sign *************************");
    let signature = bbs_plus_key.sign(attributes, &q, &mut rng2);

    let test = vec!["name=alice", "age=122", "address=X"];

    println!("\n\n******************** Verify *************************");
    let verified = signature.verify(test, &bbs_plus_key.pk, &q);

    println!("\n attributes == test, Should be true, Verified : {} ", verified);

    println!("\n\n******************** BBS+ Signature Test End *************************");

    let test2 = vec!["name", "dob", "address"];

    println!("PS Signature");
    println!("Key Gen");
    let (ps_pk, ps_sk) = key_generation(test2.len(), &q, &mut rng2);

    println!("Sign");
    let ps_signature = Signature::new(test2, &ps_sk, &q, &mut rng2);

    let test3 = vec!["name", "dob", "address"];

    println!("Verify");
    let ps_verified = ps_pk.verify(&ps_signature, test3, &q, &mut rng2);

    println!("test2 == test3, Should be true,Verified : {} ", ps_verified);
}
