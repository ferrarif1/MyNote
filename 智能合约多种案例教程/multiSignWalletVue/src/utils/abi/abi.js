export let ABI = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "tokenAddress",
        "type": "address"
      },
      {
        "internalType": "address[]",
        "name": "_owners",
        "type": "address[]"
      },
      {
        "internalType": "uint256",
        "name": "_threshold",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor",
    "signature": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "txHash",
        "type": "bytes32"
      }
    ],
    "name": "ExecutionFailure",
    "type": "event",
    "signature": "0xdbe42d02a4e07d7eeff2874efe172540c93b297d206f6d691c9782a257323e32"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "txHash",
        "type": "bytes32"
      }
    ],
    "name": "ExecutionSuccess",
    "type": "event",
    "signature": "0xdc29884a71d2bb98d3c53dc09718be05c7bfd142b7773a5c5cf2517629290ac0"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "buyTokenVipLog",
    "type": "event",
    "signature": "0x7f8de4b618d82a1a8d118dcc047f43fd3561f02fcfaaf20f39f86532c619a99f"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "name": "tLog",
    "type": "event",
    "signature": "0x3717cb68ea4ca1b1c8eb406b50802335b5cb8968b6de4951989feb2701d6bb8f"
  },
  {
    "inputs": [],
    "name": "chainId",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true,
    "signature": "0x9a8a0592"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "dataHash",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "signatures",
        "type": "bytes"
      }
    ],
    "name": "checkSignOwers",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "signOwers",
        "type": "address[]"
      }
    ],
    "stateMutability": "pure",
    "type": "function",
    "constant": true,
    "signature": "0x055fadf7"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "dataHash",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "signatures",
        "type": "bytes"
      }
    ],
    "name": "checkSignatures",
    "outputs": [],
    "stateMutability": "view",
    "type": "function",
    "constant": true,
    "signature": "0xed516d51"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "internalType": "uint256",
        "name": "_nonce",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "tx_type",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "chainid",
        "type": "uint256"
      }
    ],
    "name": "encodeTransactionData",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "pure",
    "type": "function",
    "constant": true,
    "signature": "0x62f94d4f"
  },
  {
    "inputs": [],
    "name": "enter",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function",
    "payable": true,
    "signature": "0xe97dcb62"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "internalType": "uint256",
        "name": "tx_type",
        "type": "uint256"
      },
      {
        "internalType": "bytes",
        "name": "signatures",
        "type": "bytes"
      }
    ],
    "name": "execTransaction",
    "outputs": [
      {
        "internalType": "bool",
        "name": "success",
        "type": "bool"
      }
    ],
    "stateMutability": "payable",
    "type": "function",
    "payable": true,
    "signature": "0xb9a70800"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "heightTx",
    "outputs": [
      {
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "fHeight",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      },
      {
        "internalType": "bool",
        "name": "isThaw",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true,
    "signature": "0x81504d0b"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_to",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "registeredMember",
    "outputs": [
      {
        "internalType": "bool",
        "name": "res",
        "type": "bool"
      }
    ],
    "stateMutability": "payable",
    "type": "function",
    "payable": true,
    "signature": "0x12104b2d"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "proportion",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "spaceHeight",
        "type": "uint256"
      }
    ],
    "name": "setVipConf",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function",
    "signature": "0xd2eea6f2"
  },
  {
    "inputs": [],
    "name": "signConfig",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "ownerCount",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "threshold",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "nonce",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true,
    "signature": "0xe42f4909"
  },
  {
    "inputs": [],
    "name": "thawAmount",
    "outputs": [
      {
        "internalType": "bool",
        "name": "success",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function",
    "signature": "0x00f14b6c"
  },
  {
    "stateMutability": "payable",
    "type": "receive",
    "payable": true
  }
]
