EasyBitcoin
===========

is intended to become a simple to use C++03 Bitcoin library.

[![Build Status](https://travis-ci.org/sgeisler/EasyBitcoin.svg?branch=master)](https://travis-ci.org/sgeisler/EasyBitcoin)


Why C++03
---------
I want to build a native BlackBerry(R) Bitcoin wallet. The Momentics IDE and the qnx version of gcc does not support
C++11 yet, so I can't use libbitcoin by unsystem.net. 


Planned features:
-----------------

* easy import of encoded private keys and addresses
* easy conversion between base58, base58check and hex data
* signing of standard BTC transactions

*to be continued*


Features that are not intended (but might be implemented in a separate library):
--------------------------------------------------------------------------------

* full node with block database etc.
