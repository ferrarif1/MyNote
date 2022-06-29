const fs = require("fs")
const readline  = require('readline');
 
// fs.readFile("./address.txt","utf8",function(err,dataStr){
//     console.log(err)
//     console.log("------")
//     console.log(dataStr)
// })


// let rl = readline.createInterface({
//   input: fs.createReadStream("./address.txt")
// })

// var arr = []
//  rl.on('line', line => {
   
//   arr.push(line)
//   console.log(arr)
// })

var min    = 1;                       
var max    = 3;   
var range  = max - min;                        

                       
let arr = []
for(i = 0; i < 99; i++ ){
    const random = Math.random();                    
    const result = min + Math.round(random * range);  
    arr.push(result)
}

console.log(arr)
