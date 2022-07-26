# Upgradeable smart contrat with proxy - Solidity

Even though smart contracts cannot be changed once deployed to the blockchain, there is a method to develop upgradeable contracts. Ethereum provides a function named DelegateCall, which allows a contract to use code in other contracts, and all storage changes are made in the caller’s value. In this case, developers can develop two contracts, A and B. A is the proxy contract, which controls all the storage values, contract states, and Ethers. All the logic code is stored in contract B

# Downsides:
- New versions need to inherit storage contracts that may contain many state variables that they don’t use.
- New versions become tightly coupled to specific proxy contracts and cannot be used by other proxy contracts that declare different state variables.
- Implementing this pattern we then later on will hit the problem that bytecode size exceeding the allowed limit of 24 KB, due to adding numerous new features.


![alt text](https://github.com/dunghoang74/proxy-solidity-smart-contract/blob/master/Screenshot%20at%20Aug%2014%2000-23-26.png)


