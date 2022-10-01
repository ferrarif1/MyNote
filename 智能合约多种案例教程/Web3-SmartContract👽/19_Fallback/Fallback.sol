// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Fallback {
    /*fallback() receive()?
            ETH
              |
         msg.data
            /  \
             
          /      \
receive()   fallback()
        / \
       
      /     \
receive()  fallback   
    */

    
    event receivedCalled(address Sender, uint Value);
    event fallbackCalled(address Sender, uint Value, bytes Data);

    // ETH eceived
    receive() external payable {
        emit receivedCalled(msg.sender, msg.value);
    }

    // fallback
    fallback() external payable{
        emit fallbackCalled(msg.sender, msg.value, msg.data);
    }
}
