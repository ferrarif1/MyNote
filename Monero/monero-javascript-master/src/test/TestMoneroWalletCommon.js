const assert = require("assert");
const StartMining = require("./utils/StartMining");
const TestUtils = require("./utils/TestUtils");
const monerojs = require("../../index");
const Filter = monerojs.Filter; // TODO: don't export filter
const LibraryUtils = monerojs.LibraryUtils;
const MoneroError = monerojs.MoneroError;
const MoneroTxPriority = monerojs.MoneroTxPriority;
const MoneroWalletRpc = monerojs.MoneroWalletRpc;
const MoneroWalletKeys = monerojs.MoneroWalletKeys;
const MoneroWallet = monerojs.MoneroWallet;
const MoneroWalletListener = monerojs.MoneroWalletListener;
const MoneroWalletConfig = monerojs.MoneroWalletConfig;
const MoneroUtils = monerojs.MoneroUtils;
const GenUtils = monerojs.GenUtils;
const MoneroSyncResult = monerojs.MoneroSyncResult;
const BigInteger = monerojs.BigInteger;
const MoneroRpcConnection = monerojs.MoneroRpcConnection;
const MoneroTxQuery = monerojs.MoneroTxQuery;
const MoneroTransfer = monerojs.MoneroTransfer;
const MoneroIncomingTransfer = monerojs.MoneroIncomingTransfer;
const MoneroTransferQuery = monerojs.MoneroTransferQuery;
const MoneroOutputQuery = monerojs.MoneroOutputQuery;
const MoneroOutputWallet = monerojs.MoneroOutputWallet;
const MoneroTxConfig = monerojs.MoneroTxConfig;
const MoneroTxWallet = monerojs.MoneroTxWallet;
const MoneroDestination = monerojs.MoneroDestination;
const MoneroSubaddress = monerojs.MoneroSubaddress;
const MoneroKeyImage = monerojs.MoneroKeyImage;
const MoneroTx = monerojs.MoneroTx;
const MoneroMessageSignatureType = monerojs.MoneroMessageSignatureType;
const MoneroMessageSignatureResult = monerojs.MoneroMessageSignatureResult;

// test constants
const SEND_DIVISOR = 10;
const SEND_MAX_DIFF = 60;
const MAX_TX_PROOFS = 25; // maximum number of transactions to check for each proof, undefined to check all
const NUM_BLOCKS_LOCKED = 10;

/**
 * Test a wallet for common functionality.
 */
class TestMoneroWalletCommon {
  
  /**
   * Construct the tester.
   * 
   * @param {object} testConfig - test configuration
   */
  constructor(testConfig) {
    this.testConfig = testConfig;
  }
  
  /**
   * Called before all wallet tests.
   */
  async beforeAll() {
    console.log("Before all");
    this.wallet = await this.getTestWallet();
    this.daemon = await this.getTestDaemon();
    TestUtils.WALLET_TX_TRACKER.reset(); // all wallets need to wait for txs to confirm to reliably sync
    await LibraryUtils.loadKeysModule(); // for wasm dependents like address validation
  }
  
  /**
   * Called before each wallet test.
   * 
   @param {object} currentTest - invoked with Mocha current test
   */
  async beforeEach(currentTest) {
    console.log("Before test \"" + currentTest.title + "\"");
  }
  
  /**
   * Called after all wallet tests.
   */
  async afterAll() {
    console.log("After all");
    
    // try to stop mining
    try { await this.daemon.stopMining(); }
    catch (err) { }
    
    // close wallet
    await this.wallet.close(true);
  }
  
  /**
   * Called after each wallet test.
   * 
   @param {object} currentTest - invoked with Mocha current test
   */
  async afterEach(currentTest) {
    console.log("After test \"" + currentTest.title + "\"");
  }
  
  /**
   * Get the daemon to test.
   * 
   * @return the daemon to test
   */
  async getTestDaemon() {
    return TestUtils.getDaemonRpc();
  }
  
  /**
   * Get the main wallet to test.
   * 
   * @return the wallet to test
   */
  async getTestWallet() {
    throw new Error("Subclass must implement");
  }
  
  /**
   * Open a test wallet with default configuration for each wallet type.
   * 
   * @param config - configures the wallet to open
   * @return MoneroWallet is the opened wallet
   */
  async openWallet(config) {
    throw new Error("Subclass must implement");
  }
  
  /**
   * Create a test wallet with default configuration for each wallet type.
   * 
   * @param config - configures the wallet to create
   * @return MoneroWallet is the created wallet
   */
  async createWallet(config) {
    throw new Error("Subclass must implement");
  }
  
  /**
   * Close a test wallet with customization for each wallet type. 
   * 
   * @param {MoneroWallet} wallet - the wallet to close
   * @param {bool} save - whether or not to save the wallet
   */
   async closeWallet(wallet, save) {
    throw new Error("Subclass must implement");
   }
  
  /**
   * Get the wallet's supported languages for the mnemonic phrase.  This is an
   * instance method for wallet rpc and a static utility for other wallets.
   * 
   * @return {string[]} the wallet's supported languages
   */
  async getMnemonicLanguages() {
    throw new Error("Subclass must implement");
  }
  
  // ------------------------------ BEGIN TESTS -------------------------------
  
  runCommonTests() {
    let that = this;
    let testConfig = this.testConfig;
    describe("Common Wallet Tests" + (testConfig.liteMode ? " (lite mode)" : ""), function() {
      
      // start tests by sending to multiple addresses
      if (testConfig.testRelays)
      it("Can send to multiple addresses in a single transaction", async function() {
        for (let i = 0; i < 3; i++) {
          await testSendToMultiple(5, 3, false);
        }
      });
      
      //  --------------------------- TEST NON RELAYS -------------------------
      
      if (testConfig.testNonRelays)
      it("Can create a random wallet", async function() {
        let e1 = undefined;
        try {
          let wallet = await that.createWallet();
          let path; try { path = await wallet.getPath(); } catch(e) { }  // TODO: factor out keys-only tests?
          let e2 = undefined;
          try {
            await MoneroUtils.validateAddress(await wallet.getPrimaryAddress(), TestUtils.NETWORK_TYPE);
            await MoneroUtils.validatePrivateViewKey(await wallet.getPrivateViewKey());
            await MoneroUtils.validatePrivateSpendKey(await wallet.getPrivateSpendKey());
            await MoneroUtils.validateMnemonic(await wallet.getMnemonic());
            if (!(wallet instanceof MoneroWalletRpc)) assert.equal(await wallet.getMnemonicLanguage(), MoneroWallet.DEFAULT_LANGUAGE); // TODO monero-wallet-rpc: get mnemonic language
          } catch (e) {
            e2 = e;
          }
          await that.closeWallet(wallet);
          if (e2 !== undefined) throw e2;
          
          // attempt to create wallet at same path
          if (path) {
            try {
              await that.createWallet({path: path});
              throw new Error("Should have thrown error");
            } catch(e) {
              assert.equal(e.message, "Wallet already exists: " + path);
            }
          }
          
          // attempt to create wallet with unknown language
          try {
            await that.createWallet({language: "english"}); // TODO: support lowercase?
            throw new Error("Should have thrown error");
          } catch (e) {
            assert.equal(e.message, "Unknown language: english");
          }
        } catch (e) {
          e1 = e;
        }
        
        if (e1 !== undefined) throw e1;
      });
      
      if (testConfig.testNonRelays)
      it("Can create a wallet from a mnemonic phrase.", async function() {
        let e1 = undefined;
        try {
          
          // save for comparison
          let primaryAddress = await that.wallet.getPrimaryAddress();
          let privateViewKey = await that.wallet.getPrivateViewKey();
          let privateSpendKey = await that.wallet.getPrivateSpendKey();
          
          // recreate test wallet from mnemonic
          let wallet = await that.createWallet({mnemonic: TestUtils.MNEMONIC, restoreHeight: TestUtils.FIRST_RECEIVE_HEIGHT});
          let path; try { path = await wallet.getPath(); } catch(e) { }  // TODO: factor out keys-only tests?
          let e2 = undefined;
          try {
            assert.equal(await wallet.getPrimaryAddress(), primaryAddress);
            assert.equal(await wallet.getPrivateViewKey(), privateViewKey);
            assert.equal(await wallet.getPrivateSpendKey(), privateSpendKey);
            if (!(wallet instanceof MoneroWalletRpc)) assert.equal(await wallet.getMnemonicLanguage(), MoneroWallet.DEFAULT_LANGUAGE);
          } catch (e) {
            e2 = e;
          }
          await that.closeWallet(wallet);
          if (e2 !== undefined) throw e2;
          
          // attempt to create wallet with two missing words
          try {
            let invalidMnemonic = "memoir desk algebra inbound innocent unplugs fully okay five inflamed giant factual ritual toyed topic snake unhappy guarded tweezers haunted inundate giant";
            await that.createWallet(new MoneroWalletConfig().setMnemonic(invalidMnemonic).setRestoreHeight(TestUtils.FIRST_RECEIVE_HEIGHT));
          } catch(err) {
            assert.equal("Invalid mnemonic", err.message);
          }
          
          // attempt to create wallet at same path
          if (path) {
            try {
              await that.createWallet({path: path});
              throw new Error("Should have thrown error");
            } catch (e) {
              assert.equal(e.message, "Wallet already exists: " + path);
            }
          }
        } catch (e) {
          e1 = e;
        }
        
        if (e1 !== undefined) throw e1;
      });
      
      if (testConfig.testNonRelays)
      it("Can create a wallet from a mnemonic phrase with a seed offset", async function() {
        let e1 = undefined;
        try {
          
          // create test wallet with offset
          let wallet = await that.createWallet({mnemonic: TestUtils.MNEMONIC, restoreHeight: TestUtils.FIRST_RECEIVE_HEIGHT, seedOffset: "my secret offset!"});
          let e2 = undefined;
          try {
            await MoneroUtils.validateMnemonic(await wallet.getMnemonic());
            assert.notEqual(await wallet.getMnemonic(), TestUtils.MNEMONIC);
            await MoneroUtils.validateAddress(await wallet.getPrimaryAddress(), TestUtils.NETWORK_TYPE);
            assert.notEqual(await wallet.getPrimaryAddress(), TestUtils.ADDRESS);
            if (!(wallet instanceof MoneroWalletRpc)) assert.equal(await wallet.getMnemonicLanguage(), MoneroWallet.DEFAULT_LANGUAGE);  // TODO monero-wallet-rpc: support
          } catch (e) {
            e2 = e;
          }
          await that.closeWallet(wallet);
          if (e2 !== undefined) throw e2;
        } catch (e) {
          e1 = e;
        }
        
        if (e1 !== undefined) throw e1;
      });
      
      if (testConfig.testNonRelays)
      it("Can create a wallet from keys", async function() {
        let e1 = undefined;
        try {
          
          // save for comparison
          let primaryAddress = await that.wallet.getPrimaryAddress();
          let privateViewKey = await that.wallet.getPrivateViewKey();
          let privateSpendKey = await that.wallet.getPrivateSpendKey();
          
          // recreate test wallet from keys
          let wallet = await that.createWallet({primaryAddress: primaryAddress, privateViewKey: privateViewKey, privateSpendKey: privateSpendKey, restoreHeight: await that.daemon.getHeight()});
          let path; try { path = await wallet.getPath(); } catch(e) { } // TODO: factor out keys-only tests?
          let e2 = undefined;
          try {
            assert.equal(await wallet.getPrimaryAddress(), primaryAddress);
            assert.equal(await wallet.getPrivateViewKey(), privateViewKey);
            assert.equal(await wallet.getPrivateSpendKey(), privateSpendKey);
            if (!(wallet instanceof MoneroWalletKeys) && !await wallet.isConnectedToDaemon()) console.log("WARNING: wallet created from keys is not connected to authenticated daemon");  // TODO monero-project: keys wallets not connected
            if (!(wallet instanceof MoneroWalletRpc)) {
              assert.equal(await wallet.getMnemonic(), TestUtils.MNEMONIC); // TODO monero-wallet-rpc: cannot get mnemonic from wallet created from keys?
              assert.equal(await wallet.getMnemonicLanguage(), MoneroWallet.DEFAULT_LANGUAGE);
            }
          } catch (e) {
            e2 = e;
          }
          await that.closeWallet(wallet);
          if (e2 !== undefined) throw e2;
          
          // recreate test wallet from spend key
          if (!(wallet instanceof MoneroWalletRpc)) { // TODO monero-wallet-rpc: cannot create wallet from spend key?
            wallet = await that.createWallet({privateSpendKey: privateSpendKey, restoreHeight: await that.daemon.getHeight()});
            try { path = await wallet.getPath(); } catch(e) { } // TODO: factor out keys-only tests?
            e2 = undefined;
            try {
              assert.equal(await wallet.getPrimaryAddress(), primaryAddress);
              assert.equal(await wallet.getPrivateViewKey(), privateViewKey);
              assert.equal(await wallet.getPrivateSpendKey(), privateSpendKey);
              if (!(wallet instanceof MoneroWalletKeys) && !await wallet.isConnectedToDaemon()) console.log("WARNING: wallet created from keys is not connected to authenticated daemon"); // TODO monero-project: keys wallets not connected
              if (!(wallet instanceof MoneroWalletRpc)) {
                assert.equal(await wallet.getMnemonic(), TestUtils.MNEMONIC); // TODO monero-wallet-rpc: cannot get mnemonic from wallet created from keys?
                assert.equal(await wallet.getMnemonicLanguage(), MoneroWallet.DEFAULT_LANGUAGE);
              }
            } catch (e) {
              e2 = e;
            }
            await that.closeWallet(wallet);
            if (e2 !== undefined) throw e2;
          }
          
          // attempt to create wallet at same path
          if (path) {
            try {
              await that.createWallet({path: path});
              throw new Error("Should have thrown error");
            } catch(e) {
              assert.equal(e.message, "Wallet already exists: " + path);
            }
          }
        } catch (e) {
          e1 = e;
        }
        
        if (e1 !== undefined) throw e1;
      });
      
      if (testConfig.testRelays)
      it("Can create wallets with subaddress lookahead", async function() {
        let err;
        let receiver;
        try {
          
         // create wallet with high subaddress lookahead
         receiver = await that.createWallet({
            accountLookahead: 1,
            subaddressLookahead: 100000
         });
         
         // transfer funds to subaddress with high index
         await that.wallet.createTx(new MoneroTxConfig()
                 .setAccountIndex(0)
                 .addDestination((await receiver.getSubaddress(0, 85000)).getAddress(), TestUtils.MAX_FEE)
                 .setRelay(true));
         
         // observe unconfirmed funds
         await GenUtils.waitFor(1000);
         await receiver.sync();
         assert((await receiver.getBalance()).compare(new BigInteger("0")) > 0);
        } catch (e) {
          err = e;
        }
        
        // close wallet and throw if error occurred
        if (receiver) await that.closeWallet(receiver);
        if (err) throw err;
      });
      
      
      if (testConfig.testNonRelays)
      it("Can get the wallet's version", async function() {
        let version = await that.wallet.getVersion();
        assert.equal(typeof version.getNumber(), "number");
        assert(version.getNumber() > 0);
        assert.equal(typeof version.isRelease(), "boolean");
      });
      
      if (testConfig.testNonRelays)
      it("Can get the wallet's path", async function() {
        
        // create random wallet
        let wallet = await that.createWallet();
        
        // set a random attribute
        let uuid = GenUtils.getUUID();
        await wallet.setAttribute("uuid", uuid);
        
        // record the wallet's path then save and close
        let path = await wallet.getPath();
        await that.closeWallet(wallet, true);
        
        // re-open the wallet using its path
        wallet = await that.openWallet({path: path});
        
        // test the attribute
        assert.equal(await wallet.getAttribute("uuid"), uuid);
        await that.closeWallet(wallet);
      });
      
      if (testConfig.testNonRelays)
      it("Can set the daemon connection", async function() {
        let err;
        let wallet;
        try {
          
          // create random wallet with default daemon connection
          wallet = await that.createWallet({serverUri: ""});
          if (wallet instanceof MoneroWalletRpc) {
            assert.deepEqual(await wallet.getDaemonConnection(), new MoneroRpcConnection(TestUtils.DAEMON_RPC_CONFIG));
            assert.equal(await wallet.isConnectedToDaemon(), true);
          } else {
            assert.equal(await wallet.getDaemonConnection(), undefined);
            assert(!await wallet.isConnectedToDaemon());
          }
          
          // set empty server uri
          await wallet.setDaemonConnection("");
          assert.equal(await wallet.getDaemonConnection(), undefined);
          assert.equal(await wallet.isConnectedToDaemon(), false);
          
          // set offline server uri
          await wallet.setDaemonConnection(TestUtils.OFFLINE_SERVER_URI);
          assert.deepEqual(await wallet.getDaemonConnection(), new MoneroRpcConnection(TestUtils.OFFLINE_SERVER_URI));
          assert.equal(await wallet.isConnectedToDaemon(), false);
          
          // set daemon with wrong credentials
          await wallet.setDaemonConnection({uri: TestUtils.DAEMON_RPC_CONFIG.uri, username: "wronguser", password: "wrongpass"});
          assert.deepEqual((await wallet.getDaemonConnection()).getConfig(), new MoneroRpcConnection(TestUtils.DAEMON_RPC_CONFIG.uri, "wronguser", "wrongpass").getConfig());
          if (!TestUtils.DAEMON_RPC_CONFIG.username) assert.equal(await wallet.isConnectedToDaemon(), true); // TODO: monerod without authentication works with bad credentials?
          else assert.equal(await wallet.isConnectedToDaemon(), false);
          
          // set daemon with authentication
          await wallet.setDaemonConnection(TestUtils.DAEMON_RPC_CONFIG);
          assert.deepEqual(await wallet.getDaemonConnection(), new MoneroRpcConnection(TestUtils.DAEMON_RPC_CONFIG.uri, TestUtils.DAEMON_RPC_CONFIG.username, TestUtils.DAEMON_RPC_CONFIG.password));
          assert(await wallet.isConnectedToDaemon());
          
          // nullify daemon connection
          await wallet.setDaemonConnection(undefined);
          assert.equal(await wallet.getDaemonConnection(), undefined);
          await wallet.setDaemonConnection(TestUtils.DAEMON_RPC_CONFIG.uri);
          assert.deepEqual((await wallet.getDaemonConnection()).getConfig(), new MoneroRpcConnection(TestUtils.DAEMON_RPC_CONFIG.uri).getConfig());
          await wallet.setDaemonConnection(undefined);
          assert.equal(await wallet.getDaemonConnection(), undefined);
          
          // set daemon uri to non-daemon
          await wallet.setDaemonConnection("www.getmonero.org");
          assert.deepEqual((await wallet.getDaemonConnection()).getConfig(), new MoneroRpcConnection("www.getmonero.org").getConfig());
          assert(!await wallet.isConnectedToDaemon());
          
          // set daemon to invalid uri
          await wallet.setDaemonConnection("abc123");
          assert(!await wallet.isConnectedToDaemon());
          
          // attempt to sync
          try {
            await wallet.sync();
            throw new Error("Exception expected");
          } catch (e1) {
            assert.equal(e1.message, "Wallet is not connected to daemon");
          }
        } catch (e) {
          err = e;
        }
        
        // close wallet and throw if error occurred
        await that.closeWallet(wallet);
        if (err) throw err;
      });
      
      if (testConfig.testNonRelays)
      it("Can get the mnemonic phrase", async function() {
        let mnemonic = await that.wallet.getMnemonic();
        await MoneroUtils.validateMnemonic(mnemonic);
        assert.equal(mnemonic, TestUtils.MNEMONIC);
      });
      
      if (testConfig.testNonRelays)
      it("Can get the language of the mnemonic phrase", async function() {
        let language = await that.wallet.getMnemonicLanguage();
        assert.equal(language, "English");
      });
      
      if (testConfig.testNonRelays)
      it("Can get a list of supported languages for the mnemonic phrase", async function() {
        let languages = await that.getMnemonicLanguages();
        assert(Array.isArray(languages));
        assert(languages.length);
        for (let language of languages) assert(language);
      });
      
      if (testConfig.testNonRelays)
      it("Can get the private view key", async function() {
        let privateViewKey = await that.wallet.getPrivateViewKey()
        await MoneroUtils.validatePrivateViewKey(privateViewKey);
      });
      
      if (testConfig.testNonRelays)
      it("Can get the private spend key", async function() {
        let privateSpendKey = await that.wallet.getPrivateSpendKey()
        await MoneroUtils.validatePrivateSpendKey(privateSpendKey);
      });
      
      if (testConfig.testNonRelays)
      it("Can get the public view key", async function() {
        let publicViewKey = await that.wallet.getPublicViewKey()
        await MoneroUtils.validatePublicViewKey(publicViewKey);
      });
      
      if (testConfig.testNonRelays)
      it("Can get the public spend key", async function() {
        let publicSpendKey = await that.wallet.getPublicSpendKey()
        await MoneroUtils.validatePublicSpendKey(publicSpendKey);
      });
      
      if (testConfig.testNonRelays)
      it("Can get the primary address", async function() {
        let primaryAddress = await that.wallet.getPrimaryAddress();
        await MoneroUtils.validateAddress(primaryAddress, TestUtils.NETWORK_TYPE);
        assert.equal(primaryAddress, await that.wallet.getAddress(0, 0));
      });
      
      if (testConfig.testNonRelays)
      it("Can get the address of a subaddress at a specified account and subaddress index", async function() {
        assert.equal((await that.wallet.getSubaddress(0, 0)).getAddress(), await that.wallet.getPrimaryAddress());
        for (let account of await that.wallet.getAccounts(true)) {
          for (let subaddress of account.getSubaddresses()) {
            assert.equal(await that.wallet.getAddress(account.getIndex(), subaddress.getIndex()), subaddress.getAddress());
          }
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get addresses out of range of used accounts and subaddresses", async function() {
        await that._testGetSubaddressAddressOutOfRange();
      });
      
      if (testConfig.testNonRelays)
      it("Can get the account and subaddress indices of an address", async function() {
        
        // get last subaddress to test
        let accounts = await that.wallet.getAccounts(true);
        let accountIdx = accounts.length - 1;
        let subaddressIdx = accounts[accountIdx].getSubaddresses().length - 1;
        let address = await that.wallet.getAddress(accountIdx, subaddressIdx);
        assert(address);
        assert.equal(typeof address, "string");
        
        // get address index
        let subaddress = await that.wallet.getAddressIndex(address);
        assert.equal(subaddress.getAccountIndex(), accountIdx);
        assert.equal(subaddress.getIndex(), subaddressIdx);

        // test valid but unfound address
        let nonWalletAddress = await TestUtils.getExternalWalletAddress();
        try {
          subaddress = await that.wallet.getAddressIndex(nonWalletAddress);
          throw new Error("fail");
        } catch (e) {
          assert.equal(e.message, "Address doesn't belong to the wallet");
        }
        
        // test invalid address
        try {
          subaddress = await that.wallet.getAddressIndex("this is definitely not an address");
          throw new Error("fail");
        } catch (e) {
          assert.equal(e.message, "Invalid address");
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get an integrated address given a payment id", async function() {
        
        // save address for later comparison
        let address = await that.wallet.getPrimaryAddress();
        
        // test valid payment id
        let paymentId = "03284e41c342f036";
        let integratedAddress = await that.wallet.getIntegratedAddress(undefined, paymentId);
        assert.equal(integratedAddress.getStandardAddress(), address);
        assert.equal(integratedAddress.getPaymentId(), paymentId);
        
        // test undefined payment id which generates a new one
        integratedAddress = await that.wallet.getIntegratedAddress();
        assert.equal(integratedAddress.getStandardAddress(), address);
        assert(integratedAddress.getPaymentId().length);
        
        // test with primary address
        let primaryAddress = await that.wallet.getPrimaryAddress();
        integratedAddress = await that.wallet.getIntegratedAddress(primaryAddress, paymentId);
        assert.equal(integratedAddress.getStandardAddress(), primaryAddress);
        assert.equal(integratedAddress.getPaymentId(), paymentId);
        
        // test with subaddress
        if ((await that.wallet.getSubaddresses(0)).length < 2) await that.wallet.createSubaddress(0);
        let subaddress = (await that.wallet.getSubaddress(0, 1)).getAddress();
        try {
          integratedAddress = await that.wallet.getIntegratedAddress(subaddress);
          throw new Error("Getting integrated address from subaddress should have failed");
        } catch (e) {
          assert.equal(e.message, "Subaddress shouldn't be used");
        }
        
        // test invalid payment id
        let invalidPaymentId = "invalid_payment_id_123456";
        try {
          integratedAddress = await that.wallet.getIntegratedAddress(undefined, invalidPaymentId);
          throw new Error("Getting integrated address with invalid payment id " + invalidPaymentId + " should have thrown a RPC exception");
        } catch (e) {
          //assert.equal(e.getCode(), -5);  // TODO: error codes part of rpc only?
          assert.equal(e.message, "Invalid payment ID: " + invalidPaymentId);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can decode an integrated address", async function() {
        let integratedAddress = await that.wallet.getIntegratedAddress(undefined, "03284e41c342f036");
        let decodedAddress = await that.wallet.decodeIntegratedAddress(integratedAddress.toString());
        assert.deepEqual(decodedAddress, integratedAddress);
        
        // decode invalid address
        try {
          console.log(await that.wallet.decodeIntegratedAddress("bad address"));
          throw new Error("Should have failed decoding bad address");
        } catch (err) {
          assert.equal(err.message, "Invalid address");
        }
      });
      
      // TODO: test syncing from start height
      if (testConfig.testNonRelays)
      it("Can sync (without progress)", async function() {
        let numBlocks = 100;
        let chainHeight = await that.daemon.getHeight();
        assert(chainHeight >= numBlocks);
        let result = await that.wallet.sync(chainHeight - numBlocks);  // sync to end of chain
        assert(result instanceof MoneroSyncResult);
        assert(result.getNumBlocksFetched() >= 0);
        assert.equal(typeof result.getReceivedMoney(), "boolean");
      });
      
      if (testConfig.testNonRelays)
      it("Can get the current height that the wallet is synchronized to", async function() {
        let height = await that.wallet.getHeight();
        assert(height >= 0);
      });
      
      if (testConfig.testNonRelays)
      it("Can get a blockchain height by date", async function() {
        
        // collect dates to test starting 100 days ago
        const DAY_MS = 24 * 60 * 60 * 1000;
        let yesterday = new Date(new Date().getTime() - DAY_MS); // TODO monero-project: today's date can throw exception as "in future" so we test up to yesterday
        let dates = [];
        for (let i = 99; i >= 0; i--) {
          dates.push(new Date(yesterday.getTime() - DAY_MS * i)); // subtract i days
        }
    
        // test heights by date
        let lastHeight = undefined;
        for (let date of dates) {
          let height = await that.wallet.getHeightByDate(date.getYear() + 1900, date.getMonth() + 1, date.getDate());
          assert(height >= 0);
          if (lastHeight != undefined) assert(height >= lastHeight);
          lastHeight = height;
        }
        assert(lastHeight >= 0);
        let height = await that.wallet.getHeight();
        assert(height >= 0);
        
        // test future date
        try {
          let tomorrow = new Date(yesterday.getTime() + DAY_MS * 2);
          await that.wallet.getHeightByDate(tomorrow.getYear() + 1900, tomorrow.getMonth() + 1, tomorrow.getDate());
          throw new Error("Expected exception on future date");
        } catch (err) {
          assert.equal(err.message, "specified date is in the future");
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get the locked and unlocked balances of the wallet, accounts, and subaddresses", async function() {
        
        // fetch accounts with all info as reference
        let accounts = await that.wallet.getAccounts(true);
        
        // test that balances add up between accounts and wallet
        let accountsBalance = new BigInteger(0);
        let accountsUnlockedBalance = new BigInteger(0);
        for (let account of accounts) {
          accountsBalance = accountsBalance.add(account.getBalance());
          accountsUnlockedBalance = accountsUnlockedBalance.add(account.getUnlockedBalance());
          
          // test that balances add up between subaddresses and accounts
          let subaddressesBalance = new BigInteger(0);
          let subaddressesUnlockedBalance = new BigInteger(0);
          for (let subaddress of account.getSubaddresses()) {
            subaddressesBalance = subaddressesBalance.add(subaddress.getBalance());
            subaddressesUnlockedBalance = subaddressesUnlockedBalance.add(subaddress.getUnlockedBalance());
            
            // test that balances are consistent with getAccounts() call
            assert.equal((await that.wallet.getBalance(subaddress.getAccountIndex(), subaddress.getIndex())).toString(), subaddress.getBalance().toString());
            assert.equal((await that.wallet.getUnlockedBalance(subaddress.getAccountIndex(), subaddress.getIndex())).toString(), subaddress.getUnlockedBalance().toString());
          }
          assert.equal((await that.wallet.getBalance(account.getIndex())).toString(), subaddressesBalance.toString());
          assert.equal((await that.wallet.getUnlockedBalance(account.getIndex())).toString(), subaddressesUnlockedBalance.toString());
        }
        TestUtils.testUnsignedBigInteger(accountsBalance);
        TestUtils.testUnsignedBigInteger(accountsUnlockedBalance);
        assert.equal((await that.wallet.getBalance()).toString(), accountsBalance.toString());
        assert.equal((await that.wallet.getUnlockedBalance()).toString(), accountsUnlockedBalance.toString());
        
        // test invalid input
        try {
          await that.wallet.getBalance(undefined, 0);
          throw new Error("Should have failed");
        } catch(e) {
          assert.notEqual(e.message, "Should have failed");
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get accounts without subaddresses", async function() {
        let accounts = await that.wallet.getAccounts();
        assert(accounts.length > 0);
        accounts.map(async (account) => {
          await testAccount(account)
          assert(account.getSubaddresses() === undefined);
        });
      });
      
      if (testConfig.testNonRelays)
      it("Can get accounts with subaddresses", async function() {
        let accounts = await that.wallet.getAccounts(true);
        assert(accounts.length > 0);
        accounts.map(async (account) => {
          await testAccount(account);
          assert(account.getSubaddresses().length > 0);
        });
      });
      
      if (testConfig.testNonRelays)
      it("Can get an account at a specified index", async function() {
        let accounts = await that.wallet.getAccounts();
        assert(accounts.length > 0);
        for (let account of accounts) {
          await testAccount(account);
          
          // test without subaddresses
          let retrieved = await that.wallet.getAccount(account.getIndex());
          assert(retrieved.getSubaddresses() === undefined);
          
          // test with subaddresses
          retrieved = await that.wallet.getAccount(account.getIndex(), true);
          assert(retrieved.getSubaddresses().length > 0);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can create a new account without a label", async function() {
        let accountsBefore = await that.wallet.getAccounts();
        let createdAccount = await that.wallet.createAccount();
        await testAccount(createdAccount);
        assert.equal((await that.wallet.getAccounts()).length - 1, accountsBefore.length);
      });
      
      if (testConfig.testNonRelays)
      it("Can create a new account with a label", async function() {
        
        // create account with label
        let accountsBefore = await that.wallet.getAccounts();
        let label = GenUtils.getUUID();
        let createdAccount = await that.wallet.createAccount(label);
        await testAccount(createdAccount);
        assert.equal((await that.wallet.getAccounts()).length - 1, accountsBefore.length);
        assert.equal((await that.wallet.getSubaddress(createdAccount.getIndex(), 0)).getLabel(), label);
        
        // fetch and test account
        createdAccount = await that.wallet.getAccount(createdAccount.getIndex());
        await testAccount(createdAccount);
        
        // create account with same label
        createdAccount = await that.wallet.createAccount(label);
        await testAccount(createdAccount);
        assert.equal((await that.wallet.getAccounts()).length - 2, accountsBefore.length);
        assert.equal((await that.wallet.getSubaddress(createdAccount.getIndex(), 0)).getLabel(), label);
        
        // fetch and test account
        createdAccount = await that.wallet.getAccount(createdAccount.getIndex());
        await testAccount(createdAccount);
      });
      
      if (testConfig.testNonRelays)
      it("Can get subaddresses at a specified account index", async function() {
        let accounts = await that.wallet.getAccounts();
        assert(accounts.length > 0);
        for (let account of accounts) {
          let subaddresses = await that.wallet.getSubaddresses(account.getIndex());
          assert(subaddresses.length > 0);
          subaddresses.map(subaddress => {
            testSubaddress(subaddress);
            assert(account.getIndex() === subaddress.getAccountIndex());
          });
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get subaddresses at specified account and subaddress indices", async function() {
        let accounts = await that.wallet.getAccounts();
        assert(accounts.length > 0);
        for (let account of accounts) {
          
          // get subaddresses
          let subaddresses = await that.wallet.getSubaddresses(account.getIndex());
          assert(subaddresses.length > 0);
          
          // remove a subaddress for query if possible
          if (subaddresses.length > 1) subaddresses.splice(0, 1);
          
          // get subaddress indices
          let subaddressIndices = subaddresses.map(subaddress => subaddress.getIndex());
          assert(subaddressIndices.length > 0);
          
          // fetch subaddresses by indices
          let fetchedSubaddresses = await that.wallet.getSubaddresses(account.getIndex(), subaddressIndices);
          
          // original subaddresses (minus one removed if applicable) is equal to fetched subaddresses
          assert.deepEqual(fetchedSubaddresses, subaddresses);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get a subaddress at a specified account and subaddress index", async function() {
        let accounts = await that.wallet.getAccounts();
        assert(accounts.length > 0);
        for (let account of accounts) {
          let subaddresses = await that.wallet.getSubaddresses(account.getIndex());
          assert(subaddresses.length > 0);
          for (let subaddress of subaddresses) {
            testSubaddress(subaddress);
            assert.deepEqual(await that.wallet.getSubaddress(account.getIndex(), subaddress.getIndex()), subaddress);
            assert.deepEqual((await that.wallet.getSubaddresses(account.getIndex(), subaddress.getIndex()))[0], subaddress); // test plural call with single subaddr number
          }
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can create a subaddress with and without a label", async function() {
        
        // create subaddresses across accounts
        let accounts = await that.wallet.getAccounts();
        if (accounts.length < 2) await that.wallet.createAccount();
        accounts = await that.wallet.getAccounts();
        assert(accounts.length > 1);
        for (let accountIdx = 0; accountIdx < 2; accountIdx++) {
          
          // create subaddress with no label
          let subaddresses = await that.wallet.getSubaddresses(accountIdx);
          let subaddress = await that.wallet.createSubaddress(accountIdx);
          assert.equal(subaddress.getLabel(), undefined);
          testSubaddress(subaddress);
          let subaddressesNew = await that.wallet.getSubaddresses(accountIdx);
          assert.equal(subaddressesNew.length - 1, subaddresses.length);
          assert.deepEqual(subaddressesNew[subaddressesNew.length - 1].toString(), subaddress.toString());
          
          // create subaddress with label
          subaddresses = await that.wallet.getSubaddresses(accountIdx);
          let uuid = GenUtils.getUUID();
          subaddress = await that.wallet.createSubaddress(accountIdx, uuid);
          assert.equal(uuid, subaddress.getLabel());
          testSubaddress(subaddress);
          subaddressesNew = await that.wallet.getSubaddresses(accountIdx);
          assert.equal(subaddressesNew.length - 1, subaddresses.length);
          assert.deepEqual(subaddressesNew[subaddressesNew.length - 1].toString(), subaddress.toString());
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get transactions in the wallet", async function() {
        let nonDefaultIncoming = false;
        let txs = await that._getAndTestTxs(that.wallet, undefined, true);
        assert(txs.length > 0, "Wallet has no txs to test");
        assert.equal(txs[0].getHeight(), TestUtils.FIRST_RECEIVE_HEIGHT, "First tx's restore height must match the restore height in TestUtils");
        
        // test each tranasction
        let blocksPerHeight = {};
        for (let i = 0; i < txs.length; i++) {
          await that._testTxWallet(txs[i], {wallet: that.wallet});
          await that._testTxWallet(txs[i], {wallet: that.wallet});
          assert.equal(txs[i].toString(), txs[i].toString());
          
          // test merging equivalent txs
          let copy1 = txs[i].copy();
          let copy2 = txs[i].copy();
          if (copy1.isConfirmed()) copy1.setBlock(txs[i].getBlock().copy().setTxs([copy1]));
          if (copy2.isConfirmed()) copy2.setBlock(txs[i].getBlock().copy().setTxs([copy2]));
          let merged = copy1.merge(copy2);
          await that._testTxWallet(merged, {wallet: that.wallet});
          
          // find non-default incoming
          if (txs[i].getIncomingTransfers()) {
            for (let transfer of txs[i].getIncomingTransfers()) {
              if (transfer.getAccountIndex() !== 0 && transfer.getSubaddressIndex() !== 0) nonDefaultIncoming = true;
            }
          }
          
          // ensure unique block reference per height
          if (txs[i].isConfirmed()) {
            let block = blocksPerHeight[txs[i].getHeight()];
            if (block === undefined) blocksPerHeight[txs[i].getHeight()] = txs[i].getBlock();
            else assert(block === txs[i].getBlock(), "Block references for same height must be same");
          }
        }
        
        // ensure non-default account and subaddress tested
        assert(nonDefaultIncoming, "No incoming transfers found to non-default account and subaddress; run send-to-multiple tests first");
      });
      
      if (testConfig.testNonRelays)
      it("Can get transactions by hash", async function() {
        
        let maxNumTxs = 10;  // max number of txs to test
        
        // fetch all txs for testing
        let txs = await that.wallet.getTxs();
        assert(txs.length > 1, "Test requires at least 2 txs to fetch by hash");
        
        // randomly pick a few for fetching by hash
        GenUtils.shuffle(txs);
        txs = txs.slice(0, Math.min(txs.length, maxNumTxs));
        
        // test fetching by hash
        let fetchedTx = await that.wallet.getTx(txs[0].getHash());
        assert.equal(fetchedTx.getHash(), txs[0].getHash());
        await that._testTxWallet(fetchedTx);
        
        // test fetching by hashes
        let txId1 = txs[0].getHash();
        let txId2 = txs[1].getHash();
        let fetchedTxs = await that.wallet.getTxs([txId1, txId2]);
        assert.equal(2, fetchedTxs.length);
        
        // test fetching by hashes as collection
        let txHashes = [];
        for (let tx of txs) txHashes.push(tx.getHash());
        fetchedTxs = await that.wallet.getTxs(txHashes);
        assert.equal(fetchedTxs.length, txs.length);
        for (let i = 0; i < txs.length; i++) {
          assert.equal(fetchedTxs[i].getHash(), txs[i].getHash());
          await that._testTxWallet(fetchedTxs[i]);
        }
        
        // test fetching with missing tx hashes
        let missingTxHash = "d01ede9cde813b2a693069b640c4b99c5adbdb49fbbd8da2c16c8087d0c3e320";
        txHashes.push(missingTxHash);
        let missingTxHashes = [];
        fetchedTxs = await that.wallet.getTxs(txHashes, missingTxHashes);
        assert.equal(1, missingTxHashes.length);
        assert.equal(missingTxHash, missingTxHashes[0]);
        assert.equal(txs.length, fetchedTxs.length);
        for (let i = 0; i < txs.length; i++) {
          assert.equal(txs[i].getHash(), fetchedTxs[i].getHash());
          await that._testTxWallet(fetchedTxs[i]);
        }
      });
      
      if (testConfig.testNonRelays && !testConfig.liteMode)
      it("Can get transactions with additional configuration", async function() {
        
        // get random transactions for testing
        let randomTxs = await getRandomTransactions(that.wallet, undefined, 3, 5);
        for (let randomTx of randomTxs) await that._testTxWallet(randomTx);
        
        // get transactions by hash
        let txHashes = [];
        for (let randomTx of randomTxs) {
          txHashes.push(randomTx.getHash());
          let txs = await that._getAndTestTxs(that.wallet, {hash: randomTx.getHash()}, true);
          assert.equal(txs.length, 1);
          let merged = txs[0].merge(randomTx.copy()); // txs change with chain so check mergeability
          await that._testTxWallet(merged);
        }
        
        // get transactions by hashes
        let txs = await that._getAndTestTxs(that.wallet, {hashes: txHashes});
        assert.equal(txs.length, randomTxs.length);
        for (let tx of txs) assert(txHashes.includes(tx.getHash()));
        
        // get transactions with an outgoing transfer
        txs = await that._getAndTestTxs(that.wallet, {isOutgoing: true}, true);
        for (let tx of txs) {
          assert(tx.isOutgoing());
          assert(tx.getOutgoingTransfer() instanceof MoneroTransfer);
          await testTransfer(tx.getOutgoingTransfer());
        }
        
        // get transactions without an outgoing transfer
        txs = await that._getAndTestTxs(that.wallet, {isOutgoing: false}, true);
        for (let tx of txs) assert.equal(tx.getOutgoingTransfer(), undefined);
        
        // get transactions with incoming transfers
        txs = await that._getAndTestTxs(that.wallet, {isIncoming: true}, true);
        for (let tx of txs) {
          assert(tx.getIncomingTransfers().length > 0);
          for (let transfer of tx.getIncomingTransfers()) assert(transfer instanceof MoneroTransfer);
        }
        
        // get transactions without incoming transfers
        txs = await that._getAndTestTxs(that.wallet, {isIncoming: false}, true);
        for (let tx of txs) assert.equal(tx.getIncomingTransfers(), undefined);
        
        // get transactions associated with an account
        let accountIdx = 1;
        txs = await that.wallet.getTxs({transferQuery: {accountIndex: accountIdx}});
        for (let tx of txs) {
          let found = false;
          if (tx.getOutgoingTransfer() && tx.getOutgoingTransfer().getAccountIndex() === accountIdx) found = true;
          else if (tx.getIncomingTransfers()) {
            for (let transfer of tx.getIncomingTransfers()) {
              if (transfer.getAccountIndex() === accountIdx) {
                found = true;
                break;
              }
            }
          }
          assert(found, ("Transaction is not associated with account " + accountIdx + ":\n" + tx.toString()));
        }
        
        // get transactions with incoming transfers to an account
        txs = await that.wallet.getTxs({transferQuery: {isIncoming: true, accountIndex: accountIdx}});
        for (let tx of txs) {
          assert(tx.getIncomingTransfers().length > 0);
          let found = false;
          for (let transfer of tx.getIncomingTransfers()) {
            if (transfer.getAccountIndex() === accountIdx) {
              found = true;
              break;
            }
          }
          assert(found, "No incoming transfers to account " + accountIdx + " found:\n" + tx.toString());
        }
        
        // get txs with manually built query that are confirmed and have an outgoing transfer from account 0
        let txQuery = new MoneroTxQuery();
        txQuery.setIsConfirmed(true);
        txQuery.setTransferQuery(new MoneroTransferQuery().setAccountIndex(0).setIsOutgoing(true));
        txs = await that._getAndTestTxs(that.wallet, txQuery, true);
        for (let tx of txs) {
          if (!tx.isConfirmed()) console.log(tx.toString());
          assert.equal(tx.isConfirmed(), true);
          assert(tx.getOutgoingTransfer());
          assert.equal(tx.getOutgoingTransfer().getAccountIndex(), 0);
        }
        
        // get txs with outgoing transfers that have destinations to account 1
        txs = await that._getAndTestTxs(that.wallet, {transferQuery: {hasDestinations: true, accountIndex: 0}});
        for (let tx of txs) {
          assert(tx.getOutgoingTransfer());
          assert(tx.getOutgoingTransfer().getDestinations().length > 0);
        }
        
        // include outputs with transactions
        txs = await that._getAndTestTxs(that.wallet, {includeOutputs: true}, true);
        let found = false;
        for (let tx of txs) {
          if (tx.getOutputs()) {
            assert(tx.getOutputs().length > 0);
            found = true;
          } else {
            assert(tx.isOutgoing() || (tx.isIncoming() && !tx.isConfirmed())); // TODO: monero-wallet-rpc: return outputs for unconfirmed txs
          }
        }
        assert(found, "No outputs found in txs");
        
        // get txs with input query // TODO: no inputs returned to filter
        
        // get txs with output query
        let outputQuery = new MoneroOutputQuery().setIsSpent(false).setAccountIndex(1).setSubaddressIndex(2);
        txs = await that.wallet.getTxs(new MoneroTxQuery().setOutputQuery(outputQuery));
        assert(txs.length > 0);
        for (let tx of txs) {
          assert(tx.getOutputs().length > 0);
          found = false;
          for (let output of tx.getOutputs()) {
            if (output.isSpent() === false && output.getAccountIndex() === 1 && output.getSubaddressIndex() === 2) {
              found = true;
              break;
            }
          }
          if (!found) throw new Error("Tx does not contain specified output");
        }
        
        // get unlocked txs
        txs = await that.wallet.getTxs(new MoneroTxQuery().setIsLocked(false));
        assert(txs.length > 0);
        for (let tx of txs) {
          assert.equal(tx.isLocked(), false);
        }
        
        // get confirmed transactions sent from/to same wallet with a transfer with destinations
        txs = await that.wallet.getTxs({isIncoming: true, isOutgoing: true, isConfirmed: true, includeOutputs: true, transferQuery: { hasDestinations: true }});
        for (let tx of txs) {
          assert(tx.isIncoming());
          assert(tx.isOutgoing());
          assert(tx.isConfirmed());
          assert(tx.getOutputs().length > 0);
          assert.notEqual(tx.getOutgoingTransfer(), undefined);
          assert.notEqual(tx.getOutgoingTransfer().getDestinations(), undefined);
          assert(tx.getOutgoingTransfer().getDestinations().length > 0);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get transactions by height", async function() {
        
        // get all confirmed txs for testing
        let txs = await that._getAndTestTxs(that.wallet, new MoneroTxQuery().setIsConfirmed(true));
        assert(txs.length > 0, "Wallet has no confirmed txs; run send tests");
        
        // collect all tx heights
        let txHeights = [];
        for (let tx of txs) txHeights.push(tx.getHeight());
        
        // get height that most txs occur at
        let heightCounts = countNumInstances(txHeights);
        let heightModes = getModes(heightCounts);
        let modeHeight = heightModes.values().next().value;
        
        // fetch txs at mode height
        let modeTxs = await that._getAndTestTxs(that.wallet, new MoneroTxQuery().setHeight(modeHeight));
        assert.equal(modeTxs.length, heightCounts.get(modeHeight));
        
        // fetch txs at mode height by range
        let modeTxsByRange = await that._getAndTestTxs(that.wallet, new MoneroTxQuery().setMinHeight(modeHeight).setMaxHeight(modeHeight));
        assert.equal(modeTxsByRange.length, modeTxs.length);
        assert.deepEqual(modeTxsByRange, modeTxs);
        
        // fetch all txs by range
        let fetched = await that._getAndTestTxs(that.wallet, new MoneroTxQuery().setMinHeight(txs[0].getHeight()).setMaxHeight(txs[txs.length - 1].getHeight()));
        assert.deepEqual(txs, fetched);
        
        // test some filtered by range  // TODO: these are separated in Java?
        {
          txs = await that.wallet.getTxs({isConfirmed: true});
          assert(txs.length > 0, "No transactions; run send to multiple test");
            
          // get and sort block heights in ascending order
          let heights = [];
          for (let tx of txs) {
            heights.push(tx.getBlock().getHeight());
          }
          GenUtils.sort(heights);
          
          // pick minimum and maximum heights for filtering
          let minHeight = -1;
          let maxHeight = -1;
          if (heights.length == 1) {
            minHeight = 0;
            maxHeight = heights[0] - 1;
          } else {
            minHeight = heights[0] + 1;
            maxHeight = heights[heights.length - 1] - 1;
          }
          
          // assert some transactions filtered
          let unfilteredCount = txs.length;
          txs = await that._getAndTestTxs(that.wallet, {minHeight: minHeight, maxHeight: maxHeight}, true);
          assert(txs.length < unfilteredCount);
          for (let tx of txs) {
            let height = tx.getBlock().getHeight();
            assert(height >= minHeight && height <= maxHeight);
          }
        }
      });
      
      // NOTE: payment hashes are deprecated so this test will require an old wallet to pass
      if (testConfig.testNonRelays)
      it("Can get transactions by payment ids", async function() {
        
        // get random transactions with payment hashes for testing
        let randomTxs = await getRandomTransactions(that.wallet, {hasPaymentId: true}, 3, 5);
        for (let randomTx of randomTxs) {
          assert(randomTx.getPaymentId());
        }
        
        // get transactions by payment id
        let paymentIds = randomTxs.map(tx => tx.getPaymentId());
        assert(paymentIds.length > 1);
        for (let paymentId of paymentIds) {
          let txs = await that._getAndTestTxs(that.wallet, {paymentId: paymentId});
          assert(txs.length > 0);
          assert(txs[0].getPaymentId());
          await MoneroUtils.validatePaymentId(txs[0].getPaymentId());
        }
        
        // get transactions by payment hashes
        let txs = await that._getAndTestTxs(that.wallet, {paymentIds: paymentIds});
        for (let tx of txs) {
          assert(paymentIds.includes(tx.getPaymentId()));
        }
      });
      
      if (testConfig.testNonRelays)
      it("Returns all known fields of txs regardless of filtering", async function() {
        
        // fetch wallet txs
        let txs = await that.wallet.getTxs({isConfirmed: true});
        for (let tx of txs) {
          
          // find tx sent to same wallet with incoming transfer in different account than src account
          if (!tx.getOutgoingTransfer() || !tx.getIncomingTransfers()) continue;
          for (let transfer of tx.getIncomingTransfers()) {
            if (transfer.getAccountIndex() === tx.getOutgoingTransfer().getAccountIndex()) continue;
            
            // fetch tx with filtering
            let filteredTxs = await that.wallet.getTxs({transferQuery: {isIncoming: true, accountIndex: transfer.getAccountIndex()}});
            let filteredTx = Filter.apply(new MoneroTxQuery().setHashes([tx.getHash()]), filteredTxs)[0];
            
            // txs should be the same (mergeable)
            assert.equal(filteredTx.getHash(), tx.getHash());
            tx.merge(filteredTx);
            
            // test is done
            return;
          }
        }
        
        // test did not fully execute
        throw new Error("Test requires tx sent from/to different accounts of same wallet but none found; run send tests");
      });
      
      if (testConfig.testNonRelays && !testConfig.liteMode)
      it("Validates inputs when getting transactions", async function() {
        
        // fetch random txs for testing
        let randomTxs = await getRandomTransactions(that.wallet, undefined, 3, 5);
        
        // valid, invalid, and unknown tx hashes for tests
        let txHash = randomTxs[0].getHash();
        let invalidHash = "invalid_id";
        let unknownHash1 = "6c4982f2499ece80e10b627083c4f9b992a00155e98bcba72a9588ccb91d0a61";
        let unknownHash2 = "ff397104dd875882f5e7c66e4f852ee134f8cf45e21f0c40777c9188bc92e943";
        
        // fetch unknown tx hash
        try {
          await that.wallet.getTx(unknownHash1);
          throw new Error("Should have thrown error getting tx hash unknown to wallet");
        } catch (e) {
          assert.equal(e.message, "Wallet missing requested tx hashes: " + [unknownHash1]);
        }
        
        // fetch unknown tx hash using query
        try {
          await that.wallet.getTxs(new MoneroTxQuery().setHash(unknownHash1));
          throw new Error("Should have thrown error getting tx hash unknown to wallet");
        } catch (e) {
          assert.equal(e.message, "Wallet missing requested tx hashes: " + [unknownHash1]);
        }
        
        // fetch unknown tx hash in collection
        try {
          await that.wallet.getTxs([txHash, unknownHash1]);
          throw new Error("Should have thrown error getting tx hash unknown to wallet");
        } catch (e) {
          assert.equal(e.message, "Wallet missing requested tx hashes: " + [unknownHash1]);
        }
        
        // fetch unknown tx hashes in collection
        try {
          await that.wallet.getTxs([txHash, unknownHash1, unknownHash2]);
          throw new Error("Should have thrown error getting tx hash unknown to wallet");
        } catch (e) {
          assert.equal(e.message, "Wallet missing requested tx hashes: " + [unknownHash1, unknownHash2]);
        }
        
        // fetch invalid hash
        try {
          await that.wallet.getTx(invalidHash);
          throw new Error("Should have thrown error getting tx hash unknown to wallet");
        } catch (e) {
          assert.equal(e.message, "Wallet missing requested tx hashes: " + [invalidHash]);
        }
        
        // fetch invalid hash collection
        try {
          await that.wallet.getTxs([txHash, invalidHash]);
          throw new Error("Should have thrown error getting tx hash unknown to wallet");
        } catch (e) {
          assert.equal(e.message, "Wallet missing requested tx hashes: " + [invalidHash]);
        }
        
        // fetch invalid hashes in collection
        try {
          await that.wallet.getTxs([txHash, invalidHash, "invalid_hash_2"]);
          throw new Error("Should have thrown error getting tx hash unknown to wallet");
        } catch (e) {
          assert.equal(e.message, "Wallet missing requested tx hashes: " + [invalidHash, "invalid_hash_2"]);
        }
        
        // test collection of invalid hashes
        let missingTxHashes = [];
        let txs = await that.wallet.getTxs(new MoneroTxQuery().setHashes([txHash, invalidHash, "invalid_hash_2"]), missingTxHashes);
        assert.equal(1, txs.length);
        for (let tx of txs) await that._testTxWallet(tx);
        assert.deepEqual([invalidHash, "invalid_hash_2"], missingTxHashes);
      });

      if (testConfig.testNonRelays)
      it("Can get transfers in the wallet, accounts, and subaddresses", async function() {
        
        // get all transfers
        await that._getAndTestTransfers(that.wallet, undefined, true);
        
        // get transfers by account index
        let nonDefaultIncoming = false;
        for (let account of await that.wallet.getAccounts(true)) {
          let accountTransfers = await that._getAndTestTransfers(that.wallet, {accountIndex: account.getIndex()});
          for (let transfer of accountTransfers) assert.equal(transfer.getAccountIndex(), account.getIndex());
          
          // get transfers by subaddress index
          let subaddressTransfers = [];
          for (let subaddress of account.getSubaddresses()) {
            let transfers = await that._getAndTestTransfers(that.wallet, {accountIndex: subaddress.getAccountIndex(), subaddressIndex: subaddress.getIndex()});
            for (let transfer of transfers) {
              
              // test account and subaddress indices
              assert.equal(transfer.getAccountIndex(), subaddress.getAccountIndex());
              if (transfer.isIncoming()) {
                assert.equal(transfer.getSubaddressIndex(), subaddress.getIndex());
                if (transfer.getAccountIndex() !== 0 && transfer.getSubaddressIndex() !== 0) nonDefaultIncoming = true;
              } else {
                assert(transfer.getSubaddressIndices().includes(subaddress.getIndex()));
                if (transfer.getAccountIndex() !== 0) {
                  for (let subaddrIdx of transfer.getSubaddressIndices()) {
                    if (subaddrIdx > 0) {
                      nonDefaultIncoming = true;
                      break;
                    }
                  }
                }
              }
              
              // don't add duplicates TODO monero-wallet-rpc: duplicate outgoing transfers returned for different subaddress indices, way to return outgoing subaddress indices?
              let found = false;
              for (let subaddressTransfer of subaddressTransfers) {
                if (transfer.toString() === subaddressTransfer.toString() && transfer.getTx().getHash() === subaddressTransfer.getTx().getHash()) {
                  found = true;
                  break;
                }
              }
              if (!found) subaddressTransfers.push(transfer);
            }
          }
          assert.equal(subaddressTransfers.length, accountTransfers.length);
          
          // collect unique subaddress indices
          let subaddressIndices = new Set();
          for (let transfer of subaddressTransfers) {
            if (transfer.isIncoming()) subaddressIndices.add(transfer.getSubaddressIndex());
            else for (let subaddressIdx of transfer.getSubaddressIndices()) subaddressIndices.add(subaddressIdx);
          }
          
          // get and test transfers by subaddress indices
          let transfers = await that._getAndTestTransfers(that.wallet, new MoneroTransferQuery().setAccountIndex(account.getIndex()).setSubaddressIndices(Array.from(subaddressIndices)), undefined, undefined);
          //if (transfers.length !== subaddressTransfers.length) console.log("WARNING: outgoing transfers always from subaddress 0 (monero-wallet-rpc #5171)");
          assert.equal(transfers.length, subaddressTransfers.length); // TODO monero-wallet-rpc: these may not be equal because outgoing transfers are always from subaddress 0 (#5171) and/or incoming transfers from/to same account are occluded (#4500)
          for (let transfer of transfers) {
            assert.equal(account.getIndex(), transfer.getAccountIndex());
            if (transfer.isIncoming()) assert(subaddressIndices.has(transfer.getSubaddressIndex()));
            else {
              let overlaps = false;
              for (let subaddressIdx of subaddressIndices) {
                for (let outSubaddressIdx of transfer.getSubaddressIndices()) {
                  if (subaddressIdx === outSubaddressIdx) {
                    overlaps = true;
                    break;
                  }
                }
              }
              assert(overlaps, "Subaddresses must overlap");
            }
          }
        }
        
        // ensure transfer found with non-zero account and subaddress indices
        assert(nonDefaultIncoming, "No transfers found in non-default account and subaddress; run send-to-multiple tests");
      });
      
      if (testConfig.testNonRelays && !testConfig.liteMode)
      it("Can get transfers with additional configuration", async function() {
        
        // get incoming transfers
        let transfers = await that._getAndTestTransfers(that.wallet, {isIncoming: true}, true);
        for (let transfer of transfers) assert(transfer.isIncoming());
        
        // get outgoing transfers
        transfers = await that._getAndTestTransfers(that.wallet, {isOutgoing: true}, true);
        for (let transfer of transfers) assert(transfer.isOutgoing());
        
        // get confirmed transfers to account 0
        transfers = await that._getAndTestTransfers(that.wallet, {accountIndex: 0, txQuery: {isConfirmed: true}}, true);
        for (let transfer of transfers) {
          assert.equal(transfer.getAccountIndex(), 0);
          assert(transfer.getTx().isConfirmed());
        }
        
        // get confirmed transfers to [1, 2]
        transfers = await that._getAndTestTransfers(that.wallet, {accountIndex: 1, subaddressIndex: 2, txQuery: {isConfirmed: true}}, true);
        for (let transfer of transfers) {
          assert.equal(transfer.getAccountIndex(), 1);
          if (transfer.isIncoming()) assert.equal(transfer.getSubaddressIndex(), 2);
          else assert(transfer.getSubaddressIndices().includes(2));
          assert(transfer.getTx().isConfirmed());
        }
        
        // get transfers in the tx pool
        transfers = await that._getAndTestTransfers(that.wallet, {txQuery: {inTxPool: true}});
        for (let transfer of transfers) {
          assert.equal(transfer.getTx().inTxPool(), true);
        }
        
        // get random transactions
        let txs = await getRandomTransactions(that.wallet, undefined, 3, 5);
        
        // get transfers with a tx hash
        let txHashes = [];
        for (let tx of txs) {
          txHashes.push(tx.getHash());
          transfers = await that._getAndTestTransfers(that.wallet, {txQuery: {hash: tx.getHash()}}, true);
          for (let transfer of transfers) assert.equal(transfer.getTx().getHash(), tx.getHash());
        }
        
        // get transfers with tx hashes
        transfers = await that._getAndTestTransfers(that.wallet, {txQuery: {hashes: txHashes}}, true);
        for (let transfer of transfers) assert(txHashes.includes(transfer.getTx().getHash()));
        
        // TODO: test that transfers with the same tx hash have the same tx reference
        
        // TODO: test transfers destinations
        
        // get transfers with pre-built query that are confirmed and have outgoing destinations
        let transferQuery = new MoneroTransferQuery();
        transferQuery.setIsOutgoing(true);
        transferQuery.setHasDestinations(true);
        transferQuery.setTxQuery(new MoneroTxQuery().setIsConfirmed(true));
        transfers = await that._getAndTestTransfers(that.wallet, transferQuery);
        for (let transfer of transfers) {
          assert.equal(transfer.isOutgoing(), true);
          assert(transfer.getDestinations().length > 0);
          assert.equal(transfer.getTx().isConfirmed(), true);
        }
        
        // get incoming transfers to account 0 which has outgoing transfers (i.e. originated from the same wallet)
        transfers = await that.wallet.getTransfers({accountIndex: 1, isIncoming: true, txQuery: {isOutgoing: true}})
        assert(transfers.length > 0);
        for (let transfer of transfers) {
          assert(transfer.isIncoming());
          assert.equal(transfer.getAccountIndex(), 1);
          assert(transfer.getTx().isOutgoing());
          assert.equal(transfer.getTx().getOutgoingTransfer(), undefined);
        }
        
        // get incoming transfers to a specific address
        let subaddress = await that.wallet.getAddress(1, 0);
        transfers = await that.wallet.getTransfers({isIncoming: true, address: subaddress});
        assert(transfers.length > 0);
        for (let transfer of transfers) {
          assert(transfer instanceof MoneroIncomingTransfer);
          assert.equal(1, transfer.getAccountIndex());
          assert.equal(0, transfer.getSubaddressIndex());
          assert.equal(subaddress, transfer.getAddress());
        }
      });
      
      if (testConfig.testNonRelays && !testConfig.liteMode)
      it("Validates inputs when getting transfers", async function() {
        
        // test with invalid hash
        let transfers = await that.wallet.getTransfers({txQuery: {hash: "invalid_id"}});
        assert.equal(transfers.length, 0);
        
        // test invalid hash in collection
        let randomTxs = await getRandomTransactions(that.wallet, undefined, 3, 5);
        transfers = await that.wallet.getTransfers({txQuery: {hashes: [randomTxs[0].getHash(), "invalid_id"]}});
        assert(transfers.length > 0);
        let tx = transfers[0].getTx();
        for (let transfer of transfers) assert(tx === transfer.getTx());
        
        // test unused subaddress indices
        transfers = await that.wallet.getTransfers({accountIndex: 0, subaddressIndices: [1234907]});
        assert(transfers.length === 0);
        
        // test invalid subaddress index
        try {
          let transfers = await that.wallet.getTransfers({accountIndex: 0, subaddressIndex: -1});
          throw new Error("Should have failed");
        } catch (e) {
          assert.notEqual(e.message, "Should have failed");
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get incoming and outgoing transfers using convenience methods", async function() {
        
        // get incoming transfers
        let inTransfers = await that.wallet.getIncomingTransfers();
        assert(inTransfers.length > 0);
        for (let transfer of inTransfers) {
          assert(transfer.isIncoming());
          await testTransfer(transfer, undefined);
        }
        
        // get incoming transfers with query
        let amount = inTransfers[0].getAmount();
        let accountIdx = inTransfers[0].getAccountIndex();
        let subaddressIdx = inTransfers[0].getSubaddressIndex();
        inTransfers = await that.wallet.getIncomingTransfers({amount: amount, accountIndex: accountIdx, subaddressIndex: subaddressIdx});
        assert(inTransfers.length > 0);
        for (let transfer of inTransfers) {
          assert(transfer.isIncoming());
          assert.equal(transfer.getAmount().toString(), amount.toString());
          assert.equal(transfer.getAccountIndex(), accountIdx);
          assert.equal(transfer.getSubaddressIndex(), subaddressIdx);
          await testTransfer(transfer, undefined);
        }
        
        // get incoming transfers with contradictory query
        try {
          inTransfers = await that.wallet.getIncomingTransfers(new MoneroTransferQuery().setIsIncoming(false));
        } catch (e) {
          assert.equal(e.message, "Transfer query contradicts getting incoming transfers");
        }
        
        // get outgoing transfers
        let outTransfers = await that.wallet.getOutgoingTransfers();
        assert(outTransfers.length > 0);
        for (let transfer of outTransfers) {
          assert(transfer.isOutgoing());
          await testTransfer(transfer, undefined);
        }
        
        // get outgoing transfers with query
        outTransfers = await that.wallet.getOutgoingTransfers({accountIndex: accountIdx, subaddressIndex: subaddressIdx});
        assert(outTransfers.length > 0);
        for (let transfer of outTransfers) {
          assert(transfer.isOutgoing());
          assert.equal(transfer.getAccountIndex(), accountIdx);
          assert(transfer.getSubaddressIndices().includes(subaddressIdx));
          await testTransfer(transfer, undefined);
        }
        
        // get outgoing transfers with contradictory query
        try {
          outTransfers = await that.wallet.getOutgoingTransfers(new MoneroTransferQuery().setIsOutgoing(false));
        } catch (e) {
          assert.equal(e.message, "Transfer query contradicts getting outgoing transfers");
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get outputs in the wallet, accounts, and subaddresses", async function() {

        // get all outputs
        await that._getAndTestOutputs(that.wallet, undefined, true);
        
        // get outputs for each account
        let nonDefaultIncoming = false;
        let accounts = await that.wallet.getAccounts(true);
        for (let account of accounts) {
          
          // determine if account is used
          let isUsed = false;
          for (let subaddress of account.getSubaddresses()) if (subaddress.isUsed()) isUsed = true;
          
          // get outputs by account index
          let accountOutputs = await that._getAndTestOutputs(that.wallet, {accountIndex: account.getIndex()}, isUsed);
          for (let output of accountOutputs) assert.equal(output.getAccountIndex(), account.getIndex());
          
          // get outputs by subaddress index
          let subaddressOutputs = [];
          for (let subaddress of account.getSubaddresses()) {
            let outputs = await that._getAndTestOutputs(that.wallet, {accountIndex: account.getIndex(), subaddressIndex: subaddress.getIndex()}, subaddress.isUsed());
            for (let output of outputs) {
              assert.equal(output.getAccountIndex(), subaddress.getAccountIndex());
              assert.equal(output.getSubaddressIndex(), subaddress.getIndex());
              if (output.getAccountIndex() !== 0 && output.getSubaddressIndex() !== 0) nonDefaultIncoming = true;
              subaddressOutputs.push(output);
            }
          }
          assert.equal(subaddressOutputs.length, accountOutputs.length);
          
          // get outputs by subaddress indices
          let subaddressIndices = Array.from(new Set(subaddressOutputs.map(output => output.getSubaddressIndex())));
          let outputs = await that._getAndTestOutputs(that.wallet, {accountIndex: account.getIndex(), subaddressIndices: subaddressIndices}, isUsed);
          assert.equal(outputs.length, subaddressOutputs.length);
          for (let output of outputs) {
            assert.equal(output.getAccountIndex(), account.getIndex());
            assert(subaddressIndices.includes(output.getSubaddressIndex()));
          }
        }
        
        // ensure output found with non-zero account and subaddress indices
        assert(nonDefaultIncoming, "No outputs found in non-default account and subaddress; run send-to-multiple tests");
      });

      if (testConfig.testNonRelays && !testConfig.liteMode)
      it("Can get outputs with additional configuration", async function() {
        
        // get unspent outputs to account 0
        let outputs = await that._getAndTestOutputs(that.wallet, {accountIndex: 0, isSpent: false});
        for (let output of outputs) {
          assert.equal(output.getAccountIndex(), 0);
          assert.equal(output.isSpent(), false);
        }
        
        // get spent outputs to account 1
        outputs = await that._getAndTestOutputs(that.wallet, {accountIndex: 1, isSpent: true}, true);
        for (let output of outputs) {
          assert.equal(output.getAccountIndex(), 1);
          assert.equal(output.isSpent(), true);
        }
        
        // get random transactions
        let txs = await getRandomTransactions(that.wallet, {isConfirmed: true}, 3, 5);
        
        // get outputs with a tx hash
        let txHashes = [];
        for (let tx of txs) {
          txHashes.push(tx.getHash());
          outputs = await that._getAndTestOutputs(that.wallet, {txQuery: {hash: tx.getHash()}}, true);
          for (let output of outputs) assert.equal(output.getTx().getHash(), tx.getHash());
        }
        
        // get outputs with tx hashes
        outputs = await that._getAndTestOutputs(that.wallet, {txQuery: {hashes: txHashes}}, true);
        for (let output of outputs) assert(txHashes.includes(output.getTx().getHash()));
        
        // get confirmed outputs to specific subaddress with pre-built query
        let accountIdx = 0;
        let subaddressIdx = 1;
        let query = new MoneroOutputQuery();
        query.setAccountIndex(accountIdx).setSubaddressIndex(subaddressIdx);
        query.setTxQuery(new MoneroTxQuery().setIsConfirmed(true));
        query.setMinAmount(TestUtils.MAX_FEE);
        outputs = await that._getAndTestOutputs(that.wallet, query, true);
        for (let output of outputs) {
          assert.equal(output.getAccountIndex(), accountIdx);
          assert.equal(output.getSubaddressIndex(), subaddressIdx);
          assert.equal(output.getTx().isConfirmed(), true);
          assert(output.getAmount().compare(TestUtils.MAX_FEE) >= 0);
        }
        
        // get output by key image
        let keyImage = outputs[0].getKeyImage().getHex();
        outputs = await that.wallet.getOutputs(new MoneroOutputQuery().setKeyImage(new MoneroKeyImage(keyImage)));
        assert.equal(outputs.length, 1);
        assert.equal(outputs[0].getKeyImage().getHex(), keyImage);
        
        // get outputs whose transaction is confirmed and has incoming and outgoing transfers
        outputs = await that.wallet.getOutputs({txQuery: {isConfirmed: true, isIncoming: true, isOutgoing: true, includeOutputs: true}});
        assert(outputs.length > 0);
        for (let output of outputs) {
          assert(output.getTx().isIncoming());
          assert(output.getTx().isOutgoing());
          assert(output.getTx().isConfirmed());
          assert(output.getTx().getOutputs().length > 0);
          assert(GenUtils.arrayContains(output.getTx().getOutputs(), output, true));
        }
      });
      
      if (testConfig.testNonRelays && !testConfig.liteMode)
      it("Validates inputs when getting outputs", async function() {
        
        // test with invalid hash
        let outputs = await that.wallet.getOutputs({txQuery: {hash: "invalid_id"}});
        assert.equal(outputs.length, 0);
        
        // test invalid hash in collection
        let randomTxs = await getRandomTransactions(that.wallet, {isConfirmed: true, includeOutputs: true}, 3, 5);
        outputs = await that.wallet.getOutputs({txQuery: {hashes: [randomTxs[0].getHash(), "invalid_id"]}});
        assert(outputs.length > 0);
        assert.equal(randomTxs[0].getOutputs().length, outputs.length);
        let tx = outputs[0].getTx();
        for (let output of outputs) assert(tx === output.getTx());
      });
      
      if (testConfig.testNonRelays)
      it("Can export outputs in hex format", async function() {
        let outputsHex = await that.wallet.exportOutputs();
        assert.equal(typeof outputsHex, "string");  // TODO: this will fail if wallet has no outputs; run these tests on new wallet
        assert(outputsHex.length > 0);
        
        // wallet exports outputs since last export by default
        outputsHex = await that.wallet.exportOutputs();
        let outputsHexAll = await that.wallet.exportOutputs(true);
        assert(outputsHexAll.length > outputsHex.length);
      });
      
      if (testConfig.testNonRelays)
      it("Can import outputs in hex format", async function() {
        
        // export outputs hex
        let outputsHex = await that.wallet.exportOutputs();
        
        // import outputs hex
        if (outputsHex !== undefined) {
          let numImported = await that.wallet.importOutputs(outputsHex);
          assert(numImported >= 0);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Has correct accounting across accounts, subaddresses, txs, transfers, and outputs", async function() {
        
        // pre-fetch wallet balances, accounts, subaddresses, and txs
        let walletBalance = await that.wallet.getBalance();
        let walletUnlockedBalance = await that.wallet.getUnlockedBalance();
        let accounts = await that.wallet.getAccounts(true);  // includes subaddresses
        
        // test wallet balance
        TestUtils.testUnsignedBigInteger(walletBalance);
        TestUtils.testUnsignedBigInteger(walletUnlockedBalance);
        assert(walletBalance.compare(walletUnlockedBalance) >= 0);
        
        // test that wallet balance equals sum of account balances
        let accountsBalance = new BigInteger(0);
        let accountsUnlockedBalance = new BigInteger(0);
        for (let account of accounts) {
          await testAccount(account); // test that account balance equals sum of subaddress balances
          accountsBalance = accountsBalance.add(account.getBalance());
          accountsUnlockedBalance = accountsUnlockedBalance.add(account.getUnlockedBalance());
        }
        assert.equal(walletBalance.compare(accountsBalance), 0);
        assert.equal(walletUnlockedBalance.compare(accountsUnlockedBalance), 0);
        
//        // test that wallet balance equals net of wallet's incoming and outgoing tx amounts
//        // TODO monero-wallet-rpc: these tests are disabled because incoming transfers are not returned when sent from the same account, so doesn't balance #4500
//        // TODO: test unlocked balance based on txs, requires e.g. tx.isLocked()
//        let outgoingSum = new BigInteger(0);
//        let incomingSum = new BigInteger(0);
//        for (let tx of txs) {
//          if (tx.getOutgoingAmount()) outgoingSum = outgoingSum.add(tx.getOutgoingAmount());
//          if (tx.getIncomingAmount()) incomingSum = incomingSum.add(tx.getIncomingAmount());
//        }
//        assert.equal(incomingSum.subtract(outgoingSum).toString(), walletBalance.toString());
//        
//        // test that each account's balance equals net of account's incoming and outgoing tx amounts
//        for (let account of accounts) {
//          if (account.getIndex() !== 1) continue; // find 1
//          outgoingSum = new BigInteger(0);
//          incomingSum = new BigInteger(0);
//          let filter = new MoneroTxQuery();
//          filter.setAccountIndex(account.getIndex());
//          for (let tx of txs.filter(tx => filter.meetsCriteria(tx))) { // normally we'd call wallet.getTxs(filter) but we're using pre-fetched txs
//            if (tx.getHash() === "8d3919d98dd5a734da8c52eddc558db3fbf059ad55d432f0052ecd59ef122ecb") console.log(tx.toString(0));
//            
//            //console.log((tx.getOutgoingAmount() ? tx.getOutgoingAmount().toString() : "") + ", " + (tx.getIncomingAmount() ? tx.getIncomingAmount().toString() : ""));
//            if (tx.getOutgoingAmount()) outgoingSum = outgoingSum.add(tx.getOutgoingAmount());
//            if (tx.getIncomingAmount()) incomingSum = incomingSum.add(tx.getIncomingAmount());
//          }
//          assert.equal(incomingSum.subtract(outgoingSum).toString(), account.getBalance().toString());
//        }
        
        // balance may not equal sum of unspent outputs if unconfirmed txs
        // TODO monero-wallet-rpc: reason not to return unspent outputs on unconfirmed txs? then this isn't necessary
        let txs = await that.wallet.getTxs();
        let hasUnconfirmedTx = false;
        for (let tx of txs) if (tx.inTxPool()) hasUnconfirmedTx = true;
        
        // wallet balance is sum of all unspent outputs
        let walletSum = new BigInteger(0);
        for (let output of await that.wallet.getOutputs({isSpent: false})) walletSum = walletSum.add(output.getAmount());
        if (walletBalance.compare(walletSum) !== 0) {
          
          // txs may have changed in between calls so retry test
          walletSum = new BigInteger(0);
          for (let output of await that.wallet.getOutputs({isSpent: false})) walletSum = walletSum.add(output.getAmount());
          if (walletBalance.compare(walletSum) !== 0) assert(hasUnconfirmedTx, "Wallet balance must equal sum of unspent outputs if no unconfirmed txs");
        }
        
        // account balances are sum of their unspent outputs
        for (let account of accounts) {
          let accountSum = new BigInteger(0);
          let accountOutputs = await that.wallet.getOutputs({accountIndex: account.getIndex(), isSpent: false});
          for (let output of accountOutputs) accountSum = accountSum.add(output.getAmount());
          if (account.getBalance().toString() !== accountSum.toString()) assert(hasUnconfirmedTx, "Account balance must equal sum of its unspent outputs if no unconfirmed txs");
          
          // subaddress balances are sum of their unspent outputs
          for (let subaddress of account.getSubaddresses()) {
            let subaddressSum = new BigInteger(0);
            let subaddressOutputs = await that.wallet.getOutputs({accountIndex: account.getIndex(), subaddressIndex: subaddress.getIndex(), isSpent: false});
            for (let output of subaddressOutputs) subaddressSum = subaddressSum.add(output.getAmount());
            if (subaddress.getBalance().toString() !== subaddressSum.toString()) assert(hasUnconfirmedTx, "Subaddress balance must equal sum of its unspent outputs if no unconfirmed txs");
          }
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can get and set a transaction note", async function() {
        let txs = await getRandomTransactions(that.wallet, undefined, 1, 5);
        
        // set notes
        let uuid = GenUtils.getUUID();
        for (let i = 0; i < txs.length; i++) {
          await that.wallet.setTxNote(txs[i].getHash(), uuid + i);
        }
        
        // get notes
        for (let i = 0; i < txs.length; i++) {
          assert.equal(await that.wallet.getTxNote(txs[i].getHash()), uuid + i);
        }
      });
      
      // TODO: why does getting cached txs take 2 seconds when should already be cached?
      if (testConfig.testNonRelays)
      it("Can get and set multiple transaction notes", async function() {
        
        // set tx notes
        let uuid = GenUtils.getUUID();
        let txs = await that.wallet.getTxs();
        assert(txs.length >= 3, "Test requires 3 or more wallet transactions; run send tests");
        let txHashes = [];
        let txNotes = [];
        for (let i = 0; i < txHashes.length; i++) {
          txHashes.push(txs[i].getHash());
          txNotes.push(uuid + i);
        }
        await that.wallet.setTxNotes(txHashes, txNotes);
        
        // get tx notes
        txNotes = await that.wallet.getTxNotes(txHashes);
        for (let i = 0; i < txHashes.length; i++) {
          assert.equal(uuid + i, txNotes[i]);
        }
        
        // TODO: test that get transaction has note
      });
      
      if (testConfig.testNonRelays)
      it("Can check a transfer using the transaction's secret key and the destination", async function() {
        
        // wait for pool txs to confirm if no confirmed txs with destinations
        if ((await that.wallet.getTxs({isConfirmed: true, isOutgoing: true, transferQuery: {hasDestinations: true}})).length === 0) {
          TestUtils.WALLET_TX_TRACKER.reset();
          await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        }
        
        // get random txs that are confirmed and have outgoing destinations
        let txs;
        try {
          txs = await getRandomTransactions(that.wallet, {isConfirmed: true, isOutgoing: true, transferQuery: {hasDestinations: true}}, 1, MAX_TX_PROOFS);
        } catch (e) {
          if (e.message.indexOf("found with") >= 0) throw new Error("No txs with outgoing destinations found; run send tests")
          throw e;
        }
        
        // test good checks
        assert(txs.length > 0, "No transactions found with outgoing destinations");
        for (let tx of txs) {
          let key = await that.wallet.getTxKey(tx.getHash());
          assert(key, "No tx key returned for tx hash");
          assert(tx.getOutgoingTransfer().getDestinations().length > 0);
          for (let destination of tx.getOutgoingTransfer().getDestinations()) {
            let check = await that.wallet.checkTxKey(tx.getHash(), key, destination.getAddress());
            if (destination.getAmount().compare(new BigInteger()) > 0) {
              // TODO monero-wallet-rpc: indicates amount received amount is 0 despite transaction with transfer to this address
              // TODO monero-wallet-rpc: returns 0-4 errors, not consistent
//            assert(check.getReceivedAmount().compare(new BigInteger(0)) > 0);
              if (check.getReceivedAmount().compare(new BigInteger(0)) === 0) {
                console.log("WARNING: key proof indicates no funds received despite transfer (txid=" + tx.getHash() + ", key=" + key + ", address=" + destination.getAddress() + ", amount=" + destination.getAmount() + ")");
              }
            }
            else assert(check.getReceivedAmount().compare(new BigInteger(0)) === 0);
            testCheckTx(tx, check);
          }
        }
        
        // test get tx key with invalid hash
        try {
          await that.wallet.getTxKey("invalid_tx_id");
          throw new Error("Should throw exception for invalid key");
        } catch (e) {
          that._testInvalidTxHashError(e);
        }
        
        // test check with invalid tx hash
        let tx = txs[0];
        let key = await that.wallet.getTxKey(tx.getHash());
        let destination = tx.getOutgoingTransfer().getDestinations()[0];
        try {
          await that.wallet.checkTxKey("invalid_tx_id", key, destination.getAddress());
          throw new Error("Should have thrown exception");
        } catch (e) {
          that._testInvalidTxHashError(e);
        }
        
        // test check with invalid key
        try {
          await that.wallet.checkTxKey(tx.getHash(), "invalid_tx_key", destination.getAddress());
          throw new Error("Should have thrown exception");
        } catch (e) {
          that._testInvalidTxKeyError(e);
        }
        
        // test check with invalid address
        try {
          await that.wallet.checkTxKey(tx.getHash(), key, "invalid_tx_address");
          throw new Error("Should have thrown exception");
        } catch (e) {
          that._testInvalidAddressError(e);
        }
        
        // test check with different address
        let differentAddress;
        for (let aTx of await that.wallet.getTxs()) {
          if (!aTx.getOutgoingTransfer() || !aTx.getOutgoingTransfer().getDestinations()) continue;
          for (let aDestination of aTx.getOutgoingTransfer().getDestinations()) {
            if (aDestination.getAddress() !== destination.getAddress()) {
              differentAddress = aDestination.getAddress();
              break;
            }
          }
        }
        assert(differentAddress, "Could not get a different outgoing address to test; run send tests");
        let check = await that.wallet.checkTxKey(tx.getHash(), key, differentAddress);
        assert(check.isGood());
        assert(check.getReceivedAmount().compare(new BigInteger(0)) >= 0);
        testCheckTx(tx, check);
      });
      
      if (testConfig.testNonRelays)
      it("Can prove a transaction by getting its signature", async function() {
        
        // get random txs with outgoing destinations
        let txs;
        try {
          txs = await getRandomTransactions(that.wallet, {transferQuery: {hasDestinations: true}}, 2, MAX_TX_PROOFS);
        } catch (e) {
          if (e.message.indexOf("found with") >= 0) throw new Error("No txs with outgoing destinations found; run send tests")
          throw e;
        }
        
        // test good checks with messages
        for (let tx of txs) {
          for (let destination of tx.getOutgoingTransfer().getDestinations()) {
            let signature = await that.wallet.getTxProof(tx.getHash(), destination.getAddress(), "This transaction definitely happened.");
            assert(signature, "No signature returned from getTxProof()");
            let check = await that.wallet.checkTxProof(tx.getHash(), destination.getAddress(), "This transaction definitely happened.", signature);
            testCheckTx(tx, check);
          }
        }
        
        // test good check without message
        let tx = txs[0];
        let destination = tx.getOutgoingTransfer().getDestinations()[0];
        let signature = await that.wallet.getTxProof(tx.getHash(), destination.getAddress());
        let check = await that.wallet.checkTxProof(tx.getHash(), destination.getAddress(), undefined, signature);
        testCheckTx(tx, check);
        
        // test get proof with invalid hash
        try {
          await that.wallet.getTxProof("invalid_tx_id", destination.getAddress());
          throw new Error("Should throw exception for invalid key");
        } catch (e) {
          that._testInvalidTxHashError(e);
        }
        
        // test check with invalid tx hash
        try {
          await that.wallet.checkTxProof("invalid_tx_id", destination.getAddress(), undefined, signature);
          throw new Error("Should have thrown exception");
        } catch (e) {
          that._testInvalidTxHashError(e);
        }
        
        // test check with invalid address
        try {
          await that.wallet.checkTxProof(tx.getHash(), "invalid_tx_address", undefined, signature);
          throw new Error("Should have thrown exception");
        } catch (e) {
          that._testInvalidAddressError(e);
        }
        
        // test check with wrong message
        signature = await that.wallet.getTxProof(tx.getHash(), destination.getAddress(), "This is the right message");
        check = await that.wallet.checkTxProof(tx.getHash(), destination.getAddress(), "This is the wrong message", signature);
        assert.equal(check.isGood(), false);
        testCheckTx(tx, check);
        
        // test check with wrong signature
        let wrongSignature = await that.wallet.getTxProof(txs[1].getHash(), txs[1].getOutgoingTransfer().getDestinations()[0].getAddress(), "This is the right message");
        try {
          check = await that.wallet.checkTxProof(tx.getHash(), destination.getAddress(), "This is the right message", wrongSignature);  
          assert.equal(check.isGood(), false);
        } catch (e) {
          that._testInvalidSignatureError(e);
        }
        
        // test check with empty signature
        try {
          check = await that.wallet.checkTxProof(tx.getHash(), destination.getAddress(), "This is the right message", "");  
          assert.equal(check.isGood(), false);
        } catch (e) {
          assert.equal("Must provide signature to check tx proof", e.message);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can prove a spend using a generated signature and no destination public address", async function() {
        
        // get random confirmed outgoing txs
        let txs = await getRandomTransactions(that.wallet, {isIncoming: false, inTxPool: false, isFailed: false}, 2, MAX_TX_PROOFS);
        for (let tx of txs) {
          assert.equal(tx.isConfirmed(), true);
          assert.equal(tx.getIncomingTransfers(), undefined);
          assert(tx.getOutgoingTransfer());
        }
        
        // test good checks with messages
        for (let tx of txs) {
          let signature = await that.wallet.getSpendProof(tx.getHash(), "I am a message.");
          assert(signature, "No signature returned for spend proof");
          assert(await that.wallet.checkSpendProof(tx.getHash(), "I am a message.", signature));
        }
        
        // test good check without message
        let tx = txs[0];
        let signature = await that.wallet.getSpendProof(tx.getHash());
        assert(await that.wallet.checkSpendProof(tx.getHash(), undefined, signature));
        
        // test get proof with invalid hash
        try {
          await that.wallet.getSpendProof("invalid_tx_id");
          throw new Error("Should throw exception for invalid key");
        } catch (e) {
          that._testInvalidTxHashError(e);
        }
        
        // test check with invalid tx hash
        try {
          await that.wallet.checkSpendProof("invalid_tx_id", undefined, signature);
          throw new Error("Should have thrown exception");
        } catch (e) {
          that._testInvalidTxHashError(e);
        }
        
        // test check with invalid message
        signature = await that.wallet.getSpendProof(tx.getHash(), "This is the right message");
        assert.equal(await that.wallet.checkSpendProof(tx.getHash(), "This is the wrong message", signature), false);
        
        // test check with wrong signature
        signature = await that.wallet.getSpendProof(txs[1].getHash(), "This is the right message");
        assert.equal(await that.wallet.checkSpendProof(tx.getHash(), "This is the right message", signature), false);
      });
      
      if (testConfig.testNonRelays)
      it("Can prove reserves in the wallet", async function() {
        
        // get proof of entire wallet
        let signature = await that.wallet.getReserveProofWallet("Test message");
        assert(signature, "No signature returned for wallet reserve proof");
        
        // check proof of entire wallet
        let check = await that.wallet.checkReserveProof(await that.wallet.getPrimaryAddress(), "Test message", signature);
        assert(check.isGood());
        testCheckReserve(check);
        let balance = await that.wallet.getBalance();
        if (balance.compare(check.getTotalAmount()) !== 0) {  // TODO monero-wallet-rpc: this check fails with unconfirmed txs
          let unconfirmedTxs = await that.wallet.getTxs({inTxPool: true});
          assert(unconfirmedTxs.length > 0, "Reserve amount must equal balance unless wallet has unconfirmed txs");
        }
        
        // test different wallet address
        let differentAddress = await TestUtils.getExternalWalletAddress();
        try {
          await that.wallet.checkReserveProof(differentAddress, "Test message", signature);
          throw new Error("Should have thrown exception");
        } catch (e) {
          that._testNoSubaddressError(e);
        }
        
        // test subaddress
        try {
          await that.wallet.checkReserveProof((await that.wallet.getSubaddress(0, 1)).getAddress(), "Test message", signature);
          throw new Error("Should have thrown exception");
        } catch (e) {
          that._testNoSubaddressError(e);
        }
        
        // test wrong message
        check = await that.wallet.checkReserveProof(await that.wallet.getPrimaryAddress(), "Wrong message", signature);
        assert.equal(check.isGood(), false);  // TODO: specifically test reserve checks, probably separate objects
        testCheckReserve(check);
        
        // test wrong signature
        try {
          await that.wallet.checkReserveProof(await that.wallet.getPrimaryAddress(), "Test message", "wrong signature");
          throw new Error("Should have thrown exception");
        } catch (e) {
          that._testSignatureHeaderCheckError(e);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can prove reserves in an account", async function() {
        
        // test proofs of accounts
        let numNonZeroTests = 0;
        let msg = "Test message";
        let accounts = await that.wallet.getAccounts();
        let signature;
        for (let account of accounts) {
          if (account.getBalance().compare(new BigInteger(0)) > 0) {
            let checkAmount = (await account.getBalance()).divide(new BigInteger(2));
            signature = await that.wallet.getReserveProofAccount(account.getIndex(), checkAmount, msg);
            let check = await that.wallet.checkReserveProof(await that.wallet.getPrimaryAddress(), msg, signature);
            assert(check.isGood());
            testCheckReserve(check);
            assert(check.getTotalAmount().compare(checkAmount) >= 0);
            numNonZeroTests++;
          } else {
            try {
              await that.wallet.getReserveProofAccount(account.getIndex(), account.getBalance(), msg);
              throw new Error("Should have thrown exception");
            } catch (e) {
              assert.equal(e.getCode(), -1);
              try {
                await that.wallet.getReserveProofAccount(account.getIndex(), TestUtils.MAX_FEE, msg);
                throw new Error("Should have thrown exception");
              } catch (e2) {
                assert.equal(e2.getCode(), -1);
              }
            }
          }
        }
        assert(numNonZeroTests > 1, "Must have more than one account with non-zero balance; run send-to-multiple tests");
        
        // test error when not enough balance for requested minimum reserve amount
        try {
          let reserveProof = await that.wallet.getReserveProofAccount(0, accounts[0].getBalance().add(TestUtils.MAX_FEE), "Test message");
          throw new Error("should have thrown error");
        } catch (e) {
          if (e.message === "should have thrown error") throw new Error("Should have thrown exception but got reserve proof: https://github.com/monero-project/monero/issues/6595");
          assert.equal(e.getCode(), -1);
        }
        
        // test different wallet address
        let differentAddress = await TestUtils.getExternalWalletAddress();
        try {
          await that.wallet.checkReserveProof(differentAddress, "Test message", signature);
          throw new Error("Should have thrown exception");
        } catch (e) {
          assert.equal(e.getCode(), -1);
        }
        
        // test subaddress
        try {
          await that.wallet.checkReserveProof((await that.wallet.getSubaddress(0, 1)).getAddress(), "Test message", signature);
          throw new Error("Should have thrown exception");
        } catch (e) {
          assert.equal(e.getCode(), -1);
        }
        
        // test wrong message
        let check = await that.wallet.checkReserveProof(await that.wallet.getPrimaryAddress(), "Wrong message", signature);
        assert.equal(check.isGood(), false); // TODO: specifically test reserve checks, probably separate objects
        testCheckReserve(check);
        
        // test wrong signature
        try {
          await that.wallet.checkReserveProof(await that.wallet.getPrimaryAddress(), "Test message", "wrong signature");
          throw new Error("Should have thrown exception");
        } catch (e) {
          assert.equal(e.getCode(), -1);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can export key images", async function() {
        let images = await that.wallet.exportKeyImages(true);
        assert(Array.isArray(images));
        assert(images.length > 0, "No signed key images in wallet");
        for (let image of images) {
          assert(image instanceof MoneroKeyImage);
          assert(image.getHex());
          assert(image.getSignature());
        }
        
        // wallet exports key images since last export by default
        images = await that.wallet.exportKeyImages();
        let imagesAll = await that.wallet.exportKeyImages(true);
        assert(imagesAll.length > images.length);
      });
      
      if (testConfig.testNonRelays)
      it("Can get new key images from the last import", async function() {
        
        // get outputs hex
        let outputsHex = await that.wallet.exportOutputs();
        
        // import outputs hex
        if (outputsHex !== undefined) {
          let numImported = await that.wallet.importOutputs(outputsHex);
          assert(numImported > 0);
        }
        
        // get and test new key images from last import
        let images = await that.wallet.getNewKeyImagesFromLastImport();
        assert(Array.isArray(images));
        assert(images.length > 0, "No new key images in last import");  // TODO: these are already known to the wallet, so no new key images will be imported
        for (let image of images) {
          assert(image.getHex());
          assert(image.getSignature());
        }
      });
      
      if (testConfig.testNonRelays && false)  // TODO monero-project: importing key images can cause erasure of incoming transfers per wallet2.cpp:11957
      it("Can import key images", async function() {
        let images = await that.wallet.exportKeyImages();
        assert(Array.isArray(images));
        assert(images.length > 0, "Wallet does not have any key images; run send tests");
        let result = await that.wallet.importKeyImages(images);
        assert(result.getHeight() > 0);
        
        // determine if non-zero spent and unspent amounts are expected
        let txs = await that.wallet.getTxs({isConfirmed: true, transferQuery: {isOutgoing: true}});
        let balance = await that.wallet.getBalance();
        let hasSpent = txs.length > 0;
        let hasUnspent = balance.toJSValue() > 0;
        
        // test amounts
        TestUtils.testUnsignedBigInteger(result.getSpentAmount(), hasSpent);
        TestUtils.testUnsignedBigInteger(result.getUnspentAmount(), hasUnspent);
      });
      
      if (testConfig.testNonRelays)
      it("Can sign and verify messages", async function() {
        
        // message to sign and subaddresses to test
        let msg = "This is a super important message which needs to be signed and verified.";
        let subaddresses = [new MoneroSubaddress(undefined, 0, 0), new MoneroSubaddress(undefined, 0, 1), new MoneroSubaddress(undefined, 1, 0)];
        
        // test signing message with subaddresses
        for (let subaddress of subaddresses) {
          
          // sign and verify message with spend key
          let signature = await that.wallet.signMessage(msg, MoneroMessageSignatureType.SIGN_WITH_SPEND_KEY, subaddress.getAccountIndex(), subaddress.getIndex());
          let result = await that.wallet.verifyMessage(msg, await that.wallet.getAddress(subaddress.getAccountIndex(), subaddress.getIndex()), signature);
          assert.deepEqual(result, new MoneroMessageSignatureResult(true, false, MoneroMessageSignatureType.SIGN_WITH_SPEND_KEY, 2));
          
          // verify message with incorrect address
          result = await that.wallet.verifyMessage(msg, await that.wallet.getAddress(0, 2), signature);
          assert.deepEqual(result, new MoneroMessageSignatureResult(false));
          
          // verify message with external address
          result = await that.wallet.verifyMessage(msg, await TestUtils.getExternalWalletAddress(), signature);
          assert.deepEqual(result, new MoneroMessageSignatureResult(false));
          
          // verify message with invalid address
          result = await that.wallet.verifyMessage(msg, "invalid address", signature);
          assert.deepEqual(result, new MoneroMessageSignatureResult(false));
          
          // sign and verify message with view key
          signature = await that.wallet.signMessage(msg, MoneroMessageSignatureType.SIGN_WITH_VIEW_KEY, subaddress.getAccountIndex(), subaddress.getIndex());
          result = await that.wallet.verifyMessage(msg, await that.wallet.getAddress(subaddress.getAccountIndex(), subaddress.getIndex()), signature);
          assert.deepEqual(result, new MoneroMessageSignatureResult(true, false, MoneroMessageSignatureType.SIGN_WITH_VIEW_KEY, 2));
          
          // verify message with incorrect address
          result = await that.wallet.verifyMessage(msg, await that.wallet.getAddress(0, 2), signature);
          assert.deepEqual(result, new MoneroMessageSignatureResult(false));
          
          // verify message with external address
          result = await that.wallet.verifyMessage(msg, await TestUtils.getExternalWalletAddress(), signature);
          assert.deepEqual(result, new MoneroMessageSignatureResult(false));
          
          // verify message with invalid address
          result = await that.wallet.verifyMessage(msg, "invalid address", signature);
          assert.deepEqual(result, new MoneroMessageSignatureResult(false));
        }
      });
      
      if (testConfig.testNonRelays)
      it("Has an address book", async function() {
        
        // initial state
        let entries = await that.wallet.getAddressBookEntries();
        let numEntriesStart = entries.length
        for (let entry of entries) await testAddressBookEntry(entry);
        
        // test adding standard addresses
        const NUM_ENTRIES = 5;
        let address = (await that.wallet.getSubaddress(0, 0)).getAddress();
        let indices = [];
        for (let i = 0; i < NUM_ENTRIES; i++) {
          indices.push(await that.wallet.addAddressBookEntry(address, "hi there!"));
        }
        entries = await that.wallet.getAddressBookEntries();
        assert.equal(entries.length, numEntriesStart + NUM_ENTRIES);
        for (let idx of indices) {
          let found = false;
          for (let entry of entries) {
            if (idx === entry.getIndex()) {
              await testAddressBookEntry(entry);
              assert.equal(entry.getAddress(), address);
              assert.equal(entry.getDescription(), "hi there!");
              found = true;
              break;
            }
          }
          assert(found, "Index " + idx + " not found in address book indices");
        }
        
        // edit each address book entry
        for (let idx of indices) {
          await that.wallet.editAddressBookEntry(idx, false, undefined, true, "hello there!!");
        }
        entries = await that.wallet.getAddressBookEntries(indices);
        for (let entry of entries) {
          assert.equal(entry.getDescription(), "hello there!!");
        }
        
        // delete entries at starting index
        let deleteIdx = indices[0];
        for (let i = 0; i < indices.length; i++) {
          await that.wallet.deleteAddressBookEntry(deleteIdx);
        }
        entries = await that.wallet.getAddressBookEntries();
        assert.equal(entries.length, numEntriesStart);
        
        // test adding integrated addresses
        indices = [];
        let paymentId = "03284e41c342f03"; // payment id less one character
        let integratedAddresses = {};
        let integratedDescriptions = {};
        for (let i = 0; i < NUM_ENTRIES; i++) {
          let integratedAddress = await that.wallet.getIntegratedAddress(undefined, paymentId + i); // create unique integrated address
          let uuid = GenUtils.getUUID();
          let idx = await that.wallet.addAddressBookEntry(integratedAddress.toString(), uuid);
          indices.push(idx);
          integratedAddresses[idx] = integratedAddress;
          integratedDescriptions[idx] = uuid;
        }
        entries = await that.wallet.getAddressBookEntries();
        assert.equal(entries.length, numEntriesStart + NUM_ENTRIES);
        for (let idx of indices) {
          let found = false;
          for (let entry of entries) {
            if (idx === entry.getIndex()) {
              await testAddressBookEntry(entry);
              assert.equal(entry.getDescription(), integratedDescriptions[idx]);
              assert.equal(entry.getAddress(), integratedAddresses[idx].toString());
              assert.equal(entry.getPaymentId(), undefined);
              found = true;
              break;
            }
          }
          assert(found, "Index " + idx + " not found in address book indices");
        }
        
        // delete entries at starting index
        deleteIdx = indices[0];
        for (let i = 0; i < indices.length; i++) {
          await that.wallet.deleteAddressBookEntry(deleteIdx);
        }
        entries = await that.wallet.getAddressBookEntries();
        assert.equal(entries.length, numEntriesStart);
      });
      
      if (testConfig.testNonRelays)
      it("Can get and set arbitrary key/value attributes", async function() {
        
        // set attributes
        let attrs = {};
        for (let i = 0; i < 5; i++) {
          let key = "attr" + i;
          let val = GenUtils.getUUID();
          attrs[key] = val;
          await that.wallet.setAttribute(key, val);
        }
        
        // test attributes
        for (let key of Object.keys(attrs)) {
          assert.equal(attrs[key], await that.wallet.getAttribute(key));
        }
        
        // get an undefined attribute
        assert.equal(await that.wallet.getAttribute("unset_key"), undefined);
      });
      
      if (testConfig.testNonRelays)
      it("Can convert between a tx config and payment URI", async function() {
        
        // test with address and amount
        let config1 = new MoneroTxConfig({address: await that.wallet.getAddress(0, 0), amount: new BigInteger(0)});
        let uri = await that.wallet.getPaymentUri(config1);
        let config2 = await that.wallet.parsePaymentUri(uri);
        GenUtils.deleteUndefinedKeys(config1);
        GenUtils.deleteUndefinedKeys(config2);
        assert.deepEqual(JSON.parse(JSON.stringify(config2)), JSON.parse(JSON.stringify(config1)));
        
        // test with subaddress and all fields
        config1.getDestinations()[0].setAddress((await that.wallet.getSubaddress(0, 1)).getAddress());
        config1.getDestinations()[0].setAmount(BigInteger.parse("425000000000"));
        config1.setRecipientName("John Doe");
        config1.setNote("OMZG XMR FTW");
        uri = await that.wallet.getPaymentUri(config1.toJson());
        config2 = await that.wallet.parsePaymentUri(uri);
        GenUtils.deleteUndefinedKeys(config1);
        GenUtils.deleteUndefinedKeys(config2);
        assert.deepEqual(JSON.parse(JSON.stringify(config2)), JSON.parse(JSON.stringify(config1)));
        
        // test with undefined address
        let address = config1.getDestinations()[0].getAddress();
        config1.getDestinations()[0].setAddress(undefined);
        try {
          await that.wallet.getPaymentUri(config1);
          fail("Should have thrown exception with invalid parameters");
        } catch (e) {
          assert(e.message.indexOf("Cannot make URI from supplied parameters") >= 0);
        }
        config1.getDestinations()[0].setAddress(address);
        
        // test with standalone payment id
        config1.setPaymentId("03284e41c342f03603284e41c342f03603284e41c342f03603284e41c342f036");
        try {
          await that.wallet.getPaymentUri(config1);
          fail("Should have thrown exception with invalid parameters");
        } catch (e) {
          assert(e.message.indexOf("Cannot make URI from supplied parameters") >= 0);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can start and stop mining", async function() {
        let status = await that.daemon.getMiningStatus();
        if (status.isActive()) await that.wallet.stopMining();
        await that.wallet.startMining(2, false, true);
        await that.wallet.stopMining();
      });
      
      if (testConfig.testNonRelays)
      it("Can change the wallet password", async function() {
        
        // create random wallet
        let wallet = await that.createWallet(new MoneroWalletConfig().setPassword(TestUtils.WALLET_PASSWORD));
        let path = await wallet.getPath();
        
        // change password
        let newPassword = GenUtils.getUUID();
        await wallet.changePassword(TestUtils.WALLET_PASSWORD, newPassword);
        
        // close wallet without saving
        await that.closeWallet(wallet, true);
        
        // old password does not work (password change is auto saved)
        try {
          await that.openWallet(new MoneroWalletConfig().setPath(path).setPassword(TestUtils.WALLET_PASSWORD));
          throw new Error("Should have thrown");
        } catch (err) {
          assert(err.message === "Failed to open wallet" || err.message === "invalid password"); // TODO: different errors from rpc and wallet2
        }
        
        // open wallet with new password
        wallet = await that.openWallet(new MoneroWalletConfig().setPath(path).setPassword(newPassword));
        
        // change password with incorrect password
        try {
          await wallet.changePassword("badpassword", newPassword);
          throw new Error("Should have thrown");
        } catch (err) {
          assert.equal(err.message, "Invalid original password.");
        }
        
        // save and close
        await that.closeWallet(wallet, true);
        
        // open wallet
        wallet = await that.openWallet(new MoneroWalletConfig().setPath(path).setPassword(newPassword));
        
        // close wallet
        await that.closeWallet(wallet);
      });
      
      if (testConfig.testNonRelays)
      it("Can save and close the wallet in a single call", async function() {
        
        // create random wallet
        let wallet = await that.createWallet();
        let path = await wallet.getPath();
        
        // set an attribute
        let uuid = GenUtils.getUUID();
        await wallet.setAttribute("id", uuid);
        
        // close the wallet without saving
        await that.closeWallet(wallet);
        
        // re-open the wallet and ensure attribute was not saved
        wallet = await that.openWallet({path: path});
        assert.equal(await wallet.getAttribute("id"), undefined);
        
        // set the attribute and close with saving
        await wallet.setAttribute("id", uuid);
        await that.closeWallet(wallet, true);
        
        // re-open the wallet and ensure attribute was saved
        wallet = await that.openWallet({path: path});
        assert.equal(await wallet.getAttribute("id"), uuid);
        await that.closeWallet(wallet);
      });
      
      // ----------------------------- NOTIFICATION TESTS -------------------------
      
      if (testConfig.testNotifications)
      it("Can generate notifications sending to different wallet.", async function() {
        await testWalletNotifications("testNotificationsDifferentWallet", false, false, false, false, 0);
      });
      
      if (testConfig.testNotifications)
      it("Can generate notifications sending to different wallet when relayed", async function() {
        await testWalletNotifications("testNotificationsDifferentWalletWhenRelayed", false, false, false, true, 3);
      });
      
      if (testConfig.testNotifications)
      it("Can generate notifications sending to different account.", async function() {
        await testWalletNotifications("testNotificationsDifferentAccounts", true, false, false, false, 0);
      });
      
      if (testConfig.testNotifications)
      it("Can generate notifications sending to same account", async function() {
        await testWalletNotifications("testNotificationsSameAccount", true, true, false, false, 0);
      });
      
      if (testConfig.testNotifications)
      it("Can generate notifications sweeping output to different account", async function() {
        await testWalletNotifications("testNotificationsDifferentAccountSweepOutput", true, false, true, false, 0);
      });
      
      if (testConfig.testNotifications)
      it("Can generate notifications sweeping output to same account when relayed", async function() {
        await testWalletNotifications("testNotificationsSameAccountSweepOutputWhenRelayed", true, true, true, true, 0);
      });
      
      async function testWalletNotifications(testName, sameWallet, sameAccount, sweepOutput, createThenRelay, unlockDelay) {
        let issues = await testWalletNotificationsAux(sameWallet, sameAccount, sweepOutput, createThenRelay, unlockDelay);
        if (issues.length === 0) return;
        let msg = testName + "(" + sameWallet + ", " + sameAccount + ", " + sweepOutput + ", " + createThenRelay + ") generated " + issues.length + " issues:\n" + issuesToStr(issues);
        console.log(msg);
        if (msg.includes("ERROR:")) throw new Error(msg);
      }
      
      // TODO: test sweepUnlocked()
      async function testWalletNotificationsAux(sameWallet, sameAccount, sweepOutput, createThenRelay, unlockDelay) {
        let MAX_POLL_TIME = 5000; // maximum time granted for wallet to poll
        
        // collect issues as test runs
        let issues = [];
        
        // set sender and receiver
        let sender = that.wallet;
        let receiver = sameWallet ? sender : await that.createWallet(new MoneroWalletConfig());
        
        // create receiver accounts if necessary
        let numAccounts = (await receiver.getAccounts()).length;
        for (let i = 0; i < 4 - numAccounts; i++) await receiver.createAccount();
        
        // wait for unlocked funds in source account
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(sender);
        await TestUtils.WALLET_TX_TRACKER.waitForUnlockedBalance(sender, 0, undefined, TestUtils.MAX_FEE.multiply(new BigInteger("10")));
        
        // get balances to compare after sending
        let senderBalanceBefore = await sender.getBalance();
        let senderUnlockedBalanceBefore = await sender.getUnlockedBalance();
        let receiverBalanceBefore = await receiver.getBalance();
        let receiverUnlockedBalanceBefore = await receiver.getUnlockedBalance();
        let lastHeight = await that.daemon.getHeight();
        
        // start collecting notifications from sender and receiver
        let senderNotificationCollector = new WalletNotificationCollector();
        let receiverNotificationCollector = new WalletNotificationCollector();
        await sender.addListener(senderNotificationCollector);
        await GenUtils.waitFor(TestUtils.SYNC_PERIOD_IN_MS / 2); // TODO: remove this, should be unnecessary
        await receiver.addListener(receiverNotificationCollector);
        
        // send funds
        let ctx = {wallet: sender, isSendResponse: true};
        let senderTx;
        let destinationAccounts = sameAccount ? (sweepOutput ? [0] : [0, 1, 2]) : (sweepOutput ? [1] : [1, 2, 3]);
        let expectedOutputs = [];
        if (sweepOutput) {
          ctx.isSweepResponse = true;
          ctx.isSweepOutputResponse = true;
          let outputs = await sender.getOutputs({isSpent: false, accountIndex: 0, minAmount: TestUtils.MAX_FEE.multiply(new BigInteger("5")), txQuery: {isLocked: false}});
          if (outputs.length === 0) {
            issues.push("ERROR: No outputs available to sweep from account 0");
            return issues;
          }
          let config = {address: await receiver.getAddress(destinationAccounts[0], 0), keyImage: outputs[0].getKeyImage().getHex(), relay: !createThenRelay};
          senderTx = await sender.sweepOutput(config);
          expectedOutputs.push(new MoneroOutputWallet().setAmount(senderTx.getOutgoingTransfer().getDestinations()[0].getAmount()).setAccountIndex(destinationAccounts[0]).setSubaddressIndex(0));
          ctx.config = new MoneroTxConfig(config);
        } else {
          let config = new MoneroTxConfig().setAccountIndex(0).setRelay(!createThenRelay);
          for (let destinationAccount of destinationAccounts) {
            config.addDestination(await receiver.getAddress(destinationAccount, 0), TestUtils.MAX_FEE); // TODO: send and check random amounts?
            expectedOutputs.push(new MoneroOutputWallet().setAmount(TestUtils.MAX_FEE).setAccountIndex(destinationAccount).setSubaddressIndex(0));
          }
          senderTx = await sender.createTx(config);
          ctx.config = config;
        }
        if (createThenRelay) await sender.relayTx(senderTx);
        
        // start timer to measure end of sync period
        let startTime = Date.now(); // timestamp in ms
        
        // test send tx
        await that._testTxWallet(senderTx, ctx);
        
        // test sender after sending
        let outputQuery = new MoneroOutputQuery().setTxQuery(new MoneroTxQuery().setHash(senderTx.getHash())); // query for outputs from sender tx
        if (sameWallet) {
          if (senderTx.getIncomingAmount() === undefined) issues.push("WARNING: sender tx incoming amount is null when sent to same wallet");
          else if (senderTx.getIncomingAmount().compare(new BigInteger("0")) === 0) issues.push("WARNING: sender tx incoming amount is 0 when sent to same wallet");
          else if (senderTx.getIncomingAmount().compare(senderTx.getOutgoingAmount().subtract(senderTx.getFee())) !== 0) issues.push("WARNING: sender tx incoming amount != outgoing amount - fee when sent to same wallet");
        } else {
          if (senderTx.getIncomingAmount() !== undefined) issues.push("ERROR: tx incoming amount should be undefined"); // TODO: should be 0? then can remove undefined checks in this method
        }
        senderTx = (await sender.getTxs(new MoneroTxQuery().setHash(senderTx.getHash()).setIncludeOutputs(true)))[0];
        if ((await sender.getBalance()).compare(senderBalanceBefore.subtract(senderTx.getFee()).subtract(senderTx.getOutgoingAmount()).add(senderTx.getIncomingAmount() === undefined ? new BigInteger("0") : senderTx.getIncomingAmount())) !== 0) issues.push("ERROR: sender balance after send != balance before - tx fee - outgoing amount + incoming amount (" + toStringBI(await sender.getBalance()) + " != " + toStringBI(senderBalanceBefore) + " - " + toStringBI(senderTx.getFee()) + " - " + toStringBI(senderTx.getOutgoingAmount()) + " + " + toStringBI(senderTx.getIncomingAmount()) + ")");
        if ((await sender.getUnlockedBalance()).compare(senderUnlockedBalanceBefore) >= 0) issues.push("ERROR: sender unlocked balance should have decreased after sending");
        if (senderNotificationCollector.getBalanceNotifications().length === 0) issues.push("ERROR: sender did not notify balance change after sending");
        else {
          if ((await sender.getBalance()).compare(senderNotificationCollector.getBalanceNotifications()[senderNotificationCollector.getBalanceNotifications().length - 1].balance) !== 0) issues.push("ERROR: sender balance != last notified balance after sending (" + toStringBI(await sender.getBalance()) + " != " + toStringBI(senderNotificationCollector.getBalanceNotifications()[senderNotificationCollector.getBalanceNotifications().length - 1][0]) + ")");
          if ((await sender.getUnlockedBalance()).compare(senderNotificationCollector.getBalanceNotifications()[senderNotificationCollector.getBalanceNotifications().length - 1].unlockedBalance) !== 0) issues.push("ERROR: sender unlocked balance != last notified unlocked balance after sending (" + toStringBI(await sender.getUnlockedBalance()) + " != " + toStringBI(senderNotificationCollector.getBalanceNotifications()[senderNotificationCollector.getBalanceNotifications().length - 1][1]) + ")");
        }
        if (senderNotificationCollector.getOutputsSpent(outputQuery).length === 0) issues.push("ERROR: sender did not announce unconfirmed spent output");
        
        // test receiver after 2 sync periods
        await GenUtils.waitFor(TestUtils.SYNC_PERIOD_IN_MS * 2 - (Date.now() - startTime));
        startTime = Date.now(); // reset timer
        let receiverTx = await receiver.getTx(senderTx.getHash());
        if (senderTx.getOutgoingAmount().compare(receiverTx.getIncomingAmount()) !== 0) {
          if (sameAccount) issues.push("WARNING: sender tx outgoing amount != receiver tx incoming amount when sent to same account (" + toStringBI(senderTx.getOutgoingAmount()) + " != " + toStringBI(receiverTx.getIncomingAmount()) + ")");
          else issues.push("ERROR: sender tx outgoing amount != receiver tx incoming amount (" + toStringBI(senderTx.getOutgoingAmount()) + " != " + toStringBI(receiverTx.getIncomingAmount()) + ")");
        }
        if ((await receiver.getBalance()).compare(receiverBalanceBefore.add(receiverTx.getIncomingAmount() === undefined ? new BigInteger("0") : receiverTx.getIncomingAmount()).subtract(receiverTx.getOutgoingAmount() === undefined ? new BigInteger("0") : receiverTx.getOutgoingAmount()).subtract(sameWallet ? receiverTx.getFee() : new BigInteger("0"))) !== 0) {
          if (sameAccount) issues.push("WARNING: after sending, receiver balance != balance before + incoming amount - outgoing amount - tx fee when sent to same account (" + toStringBI(await receiver.getBalance()) + " != " + toStringBI(receiverBalanceBefore) + " + " + toStringBI(receiverTx.getIncomingAmount()) + " - " + toStringBI(receiverTx.getOutgoingAmount()) + " - " + (sameWallet ? receiverTx.getFee() : new BigInteger("0")).toString() + ")");
          else issues.push("ERROR: after sending, receiver balance != balance before + incoming amount - outgoing amount - tx fee (" + toStringBI(await receiver.getBalance()) + " != " + toStringBI(receiverBalanceBefore) + " + " + toStringBI(receiverTx.getIncomingAmount()) + " - " + toStringBI(receiverTx.getOutgoingAmount()) + " - " + (sameWallet ? receiverTx.getFee() : new BigInteger("0")).toString() + ")");
        }
        if (!sameWallet && (await receiver.getUnlockedBalance()).compare(receiverUnlockedBalanceBefore) !== 0) issues.push("ERROR: receiver unlocked balance should not have changed after sending");
        if (receiverNotificationCollector.getBalanceNotifications().length === 0) issues.push("ERROR: receiver did not notify balance change when funds received");
        else {
          if ((await receiver.getBalance()).compare(receiverNotificationCollector.getBalanceNotifications()[receiverNotificationCollector.getBalanceNotifications().length - 1].balance) !== 0) issues.push("ERROR: receiver balance != last notified balance after funds received");
          if ((await receiver.getUnlockedBalance()).compare(receiverNotificationCollector.getBalanceNotifications()[receiverNotificationCollector.getBalanceNotifications().length - 1].unlockedBalance) !== 0) issues.push("ERROR: receiver unlocked balance != last notified unlocked balance after funds received");
        }
        if (receiverNotificationCollector.getOutputsReceived(outputQuery).length === 0) issues.push("ERROR: receiver did not announce unconfirmed received output");
        else {
          for (let output of getMissingOutputs(expectedOutputs, receiverNotificationCollector.getOutputsReceived(outputQuery), true)) {
            issues.push("ERROR: receiver did not announce received output for amount " + toStringBI(output.getAmount()) + " to subaddress [" + output.getAccountIndex() + ", " + output.getSubaddressIndex() + "]");
          }
        }
        
        // mine until test completes
        await StartMining.startMining();
        
        // loop every sync period until unlock tested
        let threads = [];
        let expectedUnlockHeight = lastHeight + unlockDelay;
        let confirmHeight = undefined;
        while (true) {
          
          // test height notifications
          let height = await that.daemon.getHeight();
          if (height > lastHeight) {
            let testStartHeight = lastHeight;
            lastHeight = height;
            let threadFn = async function() {
              await GenUtils.waitFor(TestUtils.SYNC_PERIOD_IN_MS * 2 + MAX_POLL_TIME); // wait 2 sync periods + poll time for notifications
              let senderBlockNotifications = senderNotificationCollector.getBlockNotifications();
              let receiverBlockNotifications = receiverNotificationCollector.getBlockNotifications();
              for (let i = testStartHeight; i < height; i++) {
                if (!GenUtils.arrayContains(senderBlockNotifications, i)) issues.push("ERROR: sender did not announce block " + i);
                if (!GenUtils.arrayContains(receiverBlockNotifications, i)) issues.push("ERROR: receiver did not announce block " + i);
              }
            }
            threads.push(threadFn());
          }
          
          // check if tx confirmed
          if (confirmHeight === undefined) {
            
            // get updated tx
            let tx = await receiver.getTx(senderTx.getHash());
            
            // break if tx fails
            if (tx.isFailed()) {
              issues.push("ERROR: tx failed in tx pool");
              break;
            }
            
            // test confirm notifications
            if (tx.isConfirmed() && confirmHeight === undefined) {
              confirmHeight = tx.getHeight();
              expectedUnlockHeight = Math.max(confirmHeight + NUM_BLOCKS_LOCKED, expectedUnlockHeight); // exact unlock height known
              let threadFn = async function() {
                await GenUtils.waitFor(TestUtils.SYNC_PERIOD_IN_MS * 2 + MAX_POLL_TIME); // wait 2 sync periods + poll time for notifications
                let confirmedQuery = outputQuery.getTxQuery().copy().setIsConfirmed(true).setIsLocked(true).getOutputQuery();
                if (senderNotificationCollector.getOutputsSpent(confirmedQuery).length === 0) issues.push("ERROR: sender did not announce confirmed spent output"); // TODO: test amount
                if (receiverNotificationCollector.getOutputsReceived(confirmedQuery).length === 0) issues.push("ERROR: receiver did not announce confirmed received output");
                else for (let output of getMissingOutputs(expectedOutputs, receiverNotificationCollector.getOutputsReceived(confirmedQuery), true)) issues.push("ERROR: receiver did not announce confirmed received output for amount " + output.getAmount() + " to subaddress [" + output.getAccountIndex() + ", " + output.getSubaddressIndex() + "]");
                
                // if same wallet, net amount spent = tx fee = outputs spent - outputs received
                if (sameWallet) {
                  let netAmount = new BigInteger("0");
                  for (let outputSpent of senderNotificationCollector.getOutputsSpent(confirmedQuery)) netAmount = netAmount.add(outputSpent.getAmount());
                  for (let outputReceived of senderNotificationCollector.getOutputsReceived(confirmedQuery)) netAmount = netAmount.subtract(outputReceived.getAmount());
                  if (tx.getFee().compare(netAmount) !== 0) {
                    if (sameAccount) issues.push("WARNING: net output amount != tx fee when funds sent to same account: " + netAmount + " vs " + tx.getFee());
                    else if (sender instanceof MoneroWalletRpc) issues.push("WARNING: net output amount != tx fee when funds sent to same wallet because monero-wallet-rpc does not provide tx inputs: " + netAmount + " vs " + tx.getFee()); // TODO (monero-project): open issue to provide tx inputs
                    else issues.push("ERROR: net output amount must equal tx fee when funds sent to same wallet: " + netAmount + " vs " + tx.getFee());
                  }
                }
              }
              threads.push(threadFn());
            }
          }
          
          // otherwise test unlock notifications
          else if (height >= expectedUnlockHeight) {
            let threadFn = async function() {
              await GenUtils.waitFor(TestUtils.SYNC_PERIOD_IN_MS * 2 + MAX_POLL_TIME); // wait 2 sync periods + poll time for notifications
              let unlockedQuery = outputQuery.getTxQuery().copy().setIsLocked(false).getOutputQuery();
              if (senderNotificationCollector.getOutputsSpent(unlockedQuery).length === 0) issues.push("ERROR: sender did not announce unlocked spent output"); // TODO: test amount?
              for (let output of getMissingOutputs(expectedOutputs, receiverNotificationCollector.getOutputsReceived(unlockedQuery), true)) issues.push("ERROR: receiver did not announce unlocked received output for amount " + output.getAmount() + " to subaddress [" + output.getAccountIndex() + ", " + output.getSubaddressIndex() + "]");
              if (!sameWallet && (await receiver.getBalance()).compare(await receiver.getUnlockedBalance()) !== 0) issues.push("ERROR: receiver balance != unlocked balance after funds unlocked");
              if (senderNotificationCollector.getBalanceNotifications().length === 0) issues.push("ERROR: sender did not announce any balance notifications");
              else {
                if ((await sender.getBalance()).compare(senderNotificationCollector.getBalanceNotifications()[senderNotificationCollector.getBalanceNotifications().length - 1].balance) !== 0) issues.push("ERROR: sender balance != last notified balance after funds unlocked");
                if ((await sender.getUnlockedBalance()).compare(senderNotificationCollector.getBalanceNotifications()[senderNotificationCollector.getBalanceNotifications().length - 1].unlockedBalance) !== 0) issues.push("ERROR: sender unlocked balance != last notified unlocked balance after funds unlocked");
              }
              if (receiverNotificationCollector.getBalanceNotifications().length === 0) issues.push("ERROR: receiver did not announce any balance notifications");
              else {
                if ((await receiver.getBalance()).compare(receiverNotificationCollector.getBalanceNotifications()[receiverNotificationCollector.getBalanceNotifications().length - 1].balance) !== 0) issues.push("ERROR: receiver balance != last notified balance after funds unlocked");
                if ((await receiver.getUnlockedBalance()).compare(receiverNotificationCollector.getBalanceNotifications()[receiverNotificationCollector.getBalanceNotifications().length - 1].unlockedBalance) !== 0) issues.push("ERROR: receiver unlocked balance != last notified unlocked balance after funds unlocked");
              }
            }
            threads.push(threadFn());
            break;
          }
          
          // wait for end of sync period
          await GenUtils.waitFor(TestUtils.SYNC_PERIOD_IN_MS - (Date.now() - startTime));
          startTime = Date.now(); // reset timer
        }
        
        // wait for test threads
        await Promise.all(threads);

        // test notified outputs
        for (let output of senderNotificationCollector.getOutputsSpent(outputQuery)) testNotifiedOutput(output, true, issues);
        for (let output of senderNotificationCollector.getOutputsReceived(outputQuery)) testNotifiedOutput(output, false, issues);
        for (let output of receiverNotificationCollector.getOutputsSpent(outputQuery)) testNotifiedOutput(output, true, issues);
        for (let output of receiverNotificationCollector.getOutputsReceived(outputQuery)) testNotifiedOutput(output, false, issues);
        
        // clean up
        if ((await that.daemon.getMiningStatus()).isActive()) await that.daemon.stopMining();
        await sender.removeListener(senderNotificationCollector);
        senderNotificationCollector.setListening(false);
        await receiver.removeListener(receiverNotificationCollector);
        receiverNotificationCollector.setListening(false);
        if (sender !== receiver) await that.closeWallet(receiver);
        return issues;
      }
      
      function getMissingOutputs(expectedOutputs, actualOutputs, matchSubaddress) {
        let missing = [];
        let used = [];
        for (let expectedOutput of expectedOutputs) {
          let found = false;
          for (let actualOutput of actualOutputs) {
            if (GenUtils.arrayContains(used, actualOutput, true)) continue;
            if (actualOutput.getAmount().compare(expectedOutput.getAmount()) === 0 && (!matchSubaddress || (actualOutput.getAccountIndex() === expectedOutput.getAccountIndex() && actualOutput.getSubaddressIndex() === expectedOutput.getSubaddressIndex()))) {
              used.push(actualOutput);
              found = true;
              break;
            }
          }
          if (!found) missing.push(expectedOutput);
        }
        return missing;
      }
      
      function issuesToStr(issues) {
        if (issues.length === 0) return undefined;
        let str = "";
        for (let i = 0; i < issues.length; i++) {
          str += (i + 1) + ": " + issues[i];
          if (i < issues.length - 1) str += "\n";
        }
        return str;
      }
      
      function testNotifiedOutput(output, isTxInput, issues) {
        
        // test tx link
        assert.notEqual(undefined, output.getTx());
        if (isTxInput) assert(output.getTx().getInputs().includes(output));
        else assert(output.getTx().getOutputs().includes(output));
        
        // test output values
        TestUtils.testUnsignedBigInteger(output.getAmount());
        if (output.getAccountIndex() !== undefined) assert(output.getAccountIndex() >= 0);
        else {
          if (isTxInput) issues.push("WARNING: notification of " + getOutputState(output) + " spent output missing account index"); // TODO (monero-project): account index not provided when output swept by key image.  could retrieve it but slows tx creation significantly
          else issues.push("ERROR: notification of " + getOutputState(output) + " received output missing account index");
        }
        if (output.getSubaddressIndex() !== undefined) assert(output.getSubaddressIndex() >= 0);
        else {
          if (isTxInput) issues.push("WARNING: notification of " + getOutputState(output) + " spent output missing subaddress index"); // TODO (monero-project): because inputs are not provided, creating fake input from outgoing transfer, which can be sourced from multiple subaddress indices, whereas an output can only come from one subaddress index; need to provide tx inputs to resolve this
          else issues.push("ERROR: notification of " + getOutputState(output) + " received output missing subaddress index");
        }
      }
      
      function getOutputState(output) {
        if (false === output.getTx().isLocked()) return "unlocked";
        if (true === output.getTx().isConfirmed()) return "confirmed";
        if (false === output.getTx().isConfirmed()) return "unconfirmed";
        throw new Error("Unknown output state: " + output.toString());
      }
      
      function toStringBI(bi) {
        return bi ? bi.toString() : bi + "";
      }
      
      it("Can stop listening", async function() {
        
        // create offline wallet
        let wallet = await that.createWallet(new MoneroWalletConfig().setServerUri(TestUtils.OFFLINE_SERVER_URI));
        
        // add listener
        let listener = new WalletNotificationCollector();
        await wallet.addListener(listener);
        await wallet.setDaemonConnection(await that.daemon.getRpcConnection());
        await new Promise(function(resolve) { setTimeout(resolve, 1000); });
        
        // remove listener and close
        await wallet.removeListener(listener);
        await that.closeWallet(wallet);
      });
      
      if (testConfig.testNotifications)
      it("Can be created and receive funds", async function() {
        
        // create a random wallet
        let receiver = await that.createWallet({password: "mysupersecretpassword123"});
        let err;
        try {
          
          // listen for received outputs
          let myListener = new WalletNotificationCollector(receiver);
          await receiver.addListener(myListener);
          
          // wait for txs to confirm and for sufficient unlocked balance
          await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
          await TestUtils.WALLET_TX_TRACKER.waitForUnlockedBalance(that.wallet, 0, undefined, TestUtils.MAX_FEE);
          
          // send funds to the created wallet
          let sentTx = await that.wallet.createTx({accountIndex: 0, address: await receiver.getPrimaryAddress(), amount: TestUtils.MAX_FEE, relay: true});
          
          // wait for funds to confirm
          try { await StartMining.startMining(); } catch (e) { }
          while (!(await that.wallet.getTx(sentTx.getHash())).isConfirmed()) {
            if ((await that.wallet.getTx(sentTx.getHash())).isFailed()) throw new Error("Tx failed in mempool: " + sentTx.getHash());
            await that.daemon.waitForNextBlockHeader();
          }
          
          // receiver should have notified listeners of received outputs
          await new Promise(function(resolve) { setTimeout(resolve, 1000); }); // TODO: this lets block slip, okay?
          assert(myListener.getOutputsReceived().length > 0, "Listener did not receive outputs");
        } catch (e) {
          err = e;
        }
        
        // final cleanup
        await that.closeWallet(receiver);
        try { await that.daemon.stopMining(); } catch (e) { }
        if (err) throw err;
      });
      
      // TODO: test sending to multiple accounts
      if (testConfig.testRelays && testConfig.testNotifications)
      it("Can update a locked tx sent from/to the same account as blocks are added to the chain", async function() {
        let config = new MoneroTxConfig({accountIndex: 0, address: await that.wallet.getPrimaryAddress(), amount: TestUtils.MAX_FEE, unlockHeight: await that.daemon.getHeight() + 3, canSplit: false, relay: true});
        await testSendAndUpdateTxs(config);
      });
      
      if (testConfig.testRelays && testConfig.testNotifications && !testConfig.liteMode)
      it("Can update split locked txs sent from/to the same account as blocks are added to the chain", async function() {
        let config = new MoneroTxConfig({accountIndex: 0, address: await that.wallet.getPrimaryAddress(), amount: TestUtils.MAX_FEE, unlockHeight: await that.daemon.getHeight() + 3, canSplit: true, relay: true});
        await testSendAndUpdateTxs(config);
      });
      
      if (testConfig.testRelays && testConfig.testNotifications && !testConfig.liteMode)
      it("Can update a locked tx sent from/to different accounts as blocks are added to the chain", async function() {
        let config = new MoneroTxConfig({accountIndex: 0, address: (await that.wallet.getSubaddress(1, 0)).getAddress(), amount: TestUtils.MAX_FEE, unlockHeight: await that.daemon.getHeight() + 3, canSplit: false, relay: true});
        await testSendAndUpdateTxs(config);
      });
      
      if (testConfig.testRelays && testConfig.testNotifications && !testConfig.liteMode)
      it("Can update locked, split txs sent from/to different accounts as blocks are added to the chain", async function() {
        let config = new MoneroTxConfig({accountIndex: 0, address: (await that.wallet.getSubaddress(1, 0)).getAddress(), amount: TestUtils.MAX_FEE, unlockHeight: await that.daemon.getHeight() + 3, relay: true});
        await testSendAndUpdateTxs(config);
      });
      
      /**
       * Tests sending a tx with an unlock height then tracking and updating it as
       * blocks are added to the chain.
       * 
       * TODO: test wallet accounting throughout this; dedicated method? probably.
       * 
       * Allows sending to and from the same account which is an edge case where
       * incoming txs are occluded by their outgoing counterpart (issue #4500)
       * and also where it is impossible to discern which incoming output is
       * the tx amount and which is the change amount without wallet metadata.
       * 
       * @param config - tx configuration to send and test
       */
      async function testSendAndUpdateTxs(config) {
        if (!config) config = new MoneroTxConfig();
        
        // wait for txs to confirm and for sufficient unlocked balance
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        assert(!config.getSubaddressIndices());
        await TestUtils.WALLET_TX_TRACKER.waitForUnlockedBalance(that.wallet, config.getAccountIndex(), undefined, TestUtils.MAX_FEE.multiply(BigInteger.parse("2")));
        
        // this test starts and stops mining, so it's wrapped in order to stop mining if anything fails
        let err;
        try {
          
          // send transactions
          let sentTxs = config.getCanSplit() !== false ? await that.wallet.createTxs(config) : [await that.wallet.createTx(config)];
          
          // test sent transactions
          for (let tx of sentTxs) {
            await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: true});
            assert.equal(tx.isConfirmed(), false);
            assert.equal(tx.inTxPool(), true);
          }
          
          // track resulting outgoing and incoming txs as blocks are added to the chain
          let updatedTxs;
          
          // start mining
          try { await StartMining.startMining(); }
          catch (e) { console.log("WARNING: could not start mining: " + e.message); } // not fatal
          
          // loop to update txs through confirmations
          let numConfirmations = 0;
          const numConfirmationsTotal = 2; // number of confirmations to test
          while (numConfirmations < numConfirmationsTotal) {
            
            // wait for a block
            let header = await that.daemon.waitForNextBlockHeader();
            console.log("*** Block " + header.getHeight() + " added to chain ***");
            
            // give wallet time to catch up, otherwise incoming tx may not appear
            await new Promise(function(resolve) { setTimeout(resolve, TestUtils.SYNC_PERIOD_IN_MS); }); // TODO: this lets block slip, okay?
            
            // get incoming/outgoing txs with sent hashes
            let txQuery = new MoneroTxQuery();
            txQuery.setHashes(sentTxs.map(sentTx => sentTx.getHash())); // TODO: convenience methods wallet.getTxById(), getTxsById()?
            let fetchedTxs = await that._getAndTestTxs(that.wallet, txQuery, true);
            assert(fetchedTxs.length > 0);
            
            // test fetched txs
            await testOutInPairs(that.wallet, fetchedTxs, config, false);

            // merge fetched txs into updated txs and original sent txs
            for (let fetchedTx of fetchedTxs) {
              
              // merge with updated txs
              if (updatedTxs === undefined) updatedTxs = fetchedTxs;
              else {
                for (let updatedTx of updatedTxs) {
                  if (fetchedTx.getHash() !== updatedTx.getHash()) continue;
                  if (!!fetchedTx.getOutgoingTransfer() !== !!updatedTx.getOutgoingTransfer()) continue;  // skip if directions are different
                  updatedTx.merge(fetchedTx.copy());
                  if (!updatedTx.getBlock() && fetchedTx.getBlock()) updatedTx.setBlock(fetchedTx.getBlock().copy().setTxs([updatedTx]));  // copy block for testing
                }
              }
              
              // merge with original sent txs
              for (let sentTx of sentTxs) {
                if (fetchedTx.getHash() !== sentTx.getHash()) continue;
                if (!!fetchedTx.getOutgoingTransfer() !== !!sentTx.getOutgoingTransfer()) continue; // skip if directions are different
                sentTx.merge(fetchedTx.copy());  // TODO: it's mergeable but tests don't account for extra info from send (e.g. hex) so not tested; could specify in test context
              }
            }
            
            // test updated txs
            testGetTxsStructure(updatedTxs, config);
            await testOutInPairs(that.wallet, updatedTxs, config, false);
            
            // update confirmations in order to exit loop
            numConfirmations = fetchedTxs[0].getNumConfirmations();
          }
        } catch (e) {
          err = e;
        }
        
        // stop mining
        try { await that.wallet.stopMining(); }
        catch (e) { }
        
        // throw error if there was one
        if (err) throw err;
      }
      
      async function testOutInPairs(wallet, txs, config, isSendResponse) {
        
        // for each out tx
        let txOut;
        for (let tx of txs) {
          await testUnlockTx(that.wallet, tx, config, isSendResponse);
          if (!tx.getOutgoingTransfer()) continue;
          let txOut = tx;
          
          // find incoming counterpart
          let txIn;
          for (let tx2 of txs) {
            if (tx2.getIncomingTransfers() && tx.getHash() === tx2.getHash()) {
              txIn = tx2;
              break;
            }
          }
          
          // test out / in pair
          // TODO monero-wallet-rpc: incoming txs occluded by their outgoing counterpart #4500
          if (!txIn) {
            console.log("WARNING: outgoing tx " + txOut.getHash() + " missing incoming counterpart (issue #4500)");
          } else {
            await testOutInPair(txOut, txIn);
          }
        }
      }
      
      async function testOutInPair(txOut, txIn) {
        assert.equal(txIn.isConfirmed(), txOut.isConfirmed());
        assert.equal(txOut.getOutgoingAmount().compare(txIn.getIncomingAmount()), 0);
      }
      
      async function testUnlockTx(wallet, tx, config, isSendResponse) {
        try {
          await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: isSendResponse});
        } catch (e) {
          console.log(tx.toString());
          throw e;
        }
      }
      
      //  ----------------------------- TEST RELAYS ---------------------------
      
      if (testConfig.testNonRelays)
      it("Validates inputs when sending funds", async function() {
        
        // try sending with invalid address
        try {
          await that.wallet.createTx({address: "my invalid address", accountIndex: 0, amount: TestUtils.MAX_FEE});
          throw new Error("fail");
        } catch (err) {
          assert.equal(err.message, "Invalid destination address");
        }
        
        // try sending with invalid amount
        try {
          await that.wallet.createTx({address: await that.wallet.getPrimaryAddress(), accountIndex: 0, amount: "my invalid amount"});
          throw new Error("fail");
        } catch (err) {
          assert.equal(err.message, "Invalid destination amount: my invalid amount");
        }
        
        // try sending with js number
        try {
          await that.wallet.createTx({address: await that.wallet.getPrimaryAddress(), accountIndex: 0, amount: 12345});
          throw new Error("fail");
        } catch (err) {
          assert.equal(err.message, "Destination amount must be BigInteger or string");
        }
      });
      
      if (testConfig.testRelays)
      it("Can send to self", async function() {
        let err;
        let recipient;
        try {
          
          // wait for txs to confirm and for sufficient unlocked balance
          await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
          let amount = TestUtils.MAX_FEE.multiply(BigInteger.parse("3"));
          await TestUtils.WALLET_TX_TRACKER.waitForUnlockedBalance(that.wallet, 0, undefined, amount);
          
          // collect sender balances before
          let balance1 = await that.wallet.getBalance();
          let unlockedBalance1 = await that.wallet.getUnlockedBalance();
          
          // send funds to self
          let tx = await that.wallet.createTx({
            accountIndex: 0,
            address: (await that.wallet.getIntegratedAddress()).getIntegratedAddress(),
            amount: amount,
            relay: true
          });
          
          // test balances after
          let balance2 = await that.wallet.getBalance();
          let unlockedBalance2 = await that.wallet.getUnlockedBalance();
          assert(unlockedBalance2.compare(unlockedBalance1) < 0); // unlocked balance should decrease
          let expectedBalance = balance1.subtract(tx.getFee());
          assert.equal(expectedBalance.toString(), balance2.toString(), "Balance after send was not balance before - net tx amount - fee (5 - 1 != 4 test)");
        } catch (e) {
          err = e;
        }
        
        // finally 
        if (recipient && !await recipient.isClosed()) await that.closeWallet(recipient);
        if (err) throw err;
      });
      
      if (testConfig.testRelays)
      it("Can send to an external address", async function() {
        let err;
        let recipient;
        try {
          
          // wait for txs to confirm and for sufficient unlocked balance
          await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
          let amount = TestUtils.MAX_FEE.multiply(BigInteger.parse("3"));
          await TestUtils.WALLET_TX_TRACKER.waitForUnlockedBalance(that.wallet, 0, undefined, amount);
          
          // create recipient wallet
          recipient = await that.createWallet(new MoneroWalletConfig());
          
          // collect sender balances before
          let balance1 = await that.wallet.getBalance();
          let unlockedBalance1 = await that.wallet.getUnlockedBalance();
          
          // send funds to recipient
          let tx = await that.wallet.createTx({
            accountIndex: 0,
            address: await recipient.getPrimaryAddress(),
            amount: amount,
            relay: true
          });
          
          // test sender balances after
          let balance2 = await that.wallet.getBalance();
          let unlockedBalance2 = await that.wallet.getUnlockedBalance();
          assert(unlockedBalance2.compare(unlockedBalance1) < 0); // unlocked balance should decrease
          let expectedBalance = balance1.subtract(tx.getOutgoingAmount()).subtract(tx.getFee());
          assert.equal(expectedBalance.toString(), balance2.toString(), "Balance after send was not balance before - net tx amount - fee (5 - 1 != 4 test)");
          
          // test recipient balance after
          await recipient.sync();
          assert((await that.wallet.getTxs({isConfirmed: false})).length > 0);
          assert.equal(amount.toString(), (await recipient.getBalance()).toString());
        } catch (e) {
          err = e;
        }
        
        // finally 
        if (recipient && !await recipient.isClosed()) await that.closeWallet(recipient);
        if (err) throw err;
      });
      
      if (testConfig.testRelays)
      it("Can send from multiple subaddresses in a single transaction", async function() {
        await testSendFromMultiple();
      });
      
      if (testConfig.testRelays)
      it("Can send from multiple subaddresses in split transactions", async function() {
        await testSendFromMultiple(new MoneroTxConfig().setCanSplit(true));
      });
      
      async function testSendFromMultiple(config) {
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        if (!config) config = new MoneroTxConfig();
        
        let NUM_SUBADDRESSES = 2; // number of subaddresses to send from
        
        // get first account with (NUM_SUBADDRESSES + 1) subaddresses with unlocked balances
        let accounts = await that.wallet.getAccounts(true);
        assert(accounts.length >= 2, "This test requires at least 2 accounts; run send-to-multiple tests");
        let srcAccount;
        let unlockedSubaddresses = [];
        let hasBalance = false;
        for (let account of accounts) {
          unlockedSubaddresses = [];
          let numSubaddressBalances = 0;
          for (let subaddress of account.getSubaddresses()) {
            if (subaddress.getBalance().compare(TestUtils.MAX_FEE) > 0) numSubaddressBalances++;
            if (subaddress.getUnlockedBalance().compare(TestUtils.MAX_FEE) > 0) unlockedSubaddresses.push(subaddress);
          }
          if (numSubaddressBalances >= NUM_SUBADDRESSES + 1) hasBalance = true;
          if (unlockedSubaddresses.length >= NUM_SUBADDRESSES + 1) {
            srcAccount = account;
            break;
          }
        }
        assert(hasBalance, "Wallet does not have account with " + (NUM_SUBADDRESSES + 1) + " subaddresses with balances; run send-to-multiple tests");
        assert(unlockedSubaddresses.length >= NUM_SUBADDRESSES + 1, "Wallet is waiting on unlocked funds");
        
        // determine the indices of the first two subaddresses with unlocked balances
        let fromSubaddressIndices = [];
        for (let i = 0; i < NUM_SUBADDRESSES; i++) {
          fromSubaddressIndices.push(unlockedSubaddresses[i].getIndex());
        }
        
        // determine the amount to send
        let sendAmount = new BigInteger(0);
        for (let fromSubaddressIdx of fromSubaddressIndices) {
          sendAmount = sendAmount.add(srcAccount.getSubaddresses()[fromSubaddressIdx].getUnlockedBalance());
        }
        sendAmount = sendAmount.divide(new BigInteger(SEND_DIVISOR))
        
        // send from the first subaddresses with unlocked balances
        let address = await that.wallet.getPrimaryAddress();
        config.setDestinations([new MoneroDestination(address, sendAmount)]);
        config.setAccountIndex(srcAccount.getIndex());
        config.setSubaddressIndices(fromSubaddressIndices);
        config.setRelay(true);
        let configCopy = config.copy();
        let txs = [];
        if (config.getCanSplit() !== false) {
          for (let tx of await that.wallet.createTxs(config)) txs.push(tx);
        } else {
          txs.push(await that.wallet.createTx(config));
        }
        if (config.getCanSplit() === false) assert.equal(txs.length, 1);  // must have exactly one tx if no split
        
        // test that config is unchanged
        assert(configCopy !== config);
        assert.deepEqual(config, configCopy);
        
        // test that balances of intended subaddresses decreased
        let accountsAfter = await that.wallet.getAccounts(true);
        assert.equal(accountsAfter.length, accounts.length);
        let srcUnlockedBalanceDecreased = false;
        for (let i = 0; i < accounts.length; i++) {
          assert.equal(accountsAfter[i].getSubaddresses().length, accounts[i].getSubaddresses().length);
          for (let j = 0; j < accounts[i].getSubaddresses().length; j++) {
            let subaddressBefore = accounts[i].getSubaddresses()[j];
            let subaddressAfter = accountsAfter[i].getSubaddresses()[j];
            if (i === srcAccount.getIndex() && fromSubaddressIndices.includes(j)) {
              if (subaddressAfter.getUnlockedBalance().compare(subaddressBefore.getUnlockedBalance()) < 0) srcUnlockedBalanceDecreased = true; 
            } else {
              assert(subaddressAfter.getUnlockedBalance().compare(subaddressBefore.getUnlockedBalance()) === 0, "Subaddress [" + i + "," + j + "] unlocked balance should not have changed");          
            }
          }
        }
        assert(srcUnlockedBalanceDecreased, "Subaddress unlocked balances should have decreased");
        
        // test each transaction
        assert(txs.length > 0);
        let outgoingSum = new BigInteger(0);
        for (let tx of txs) {
          await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: true});
          outgoingSum = outgoingSum.add(tx.getOutgoingAmount());
          if (tx.getOutgoingTransfer() !== undefined && tx.getOutgoingTransfer().getDestinations()) {
            let destinationSum = new BigInteger(0);
            for (let destination of tx.getOutgoingTransfer().getDestinations()) {
              await testDestination(destination);
              assert.equal(destination.getAddress(), address);
              destinationSum = destinationSum.add(destination.getAmount());
            }
            assert(tx.getOutgoingAmount().compare(destinationSum) === 0);  // assert that transfers sum up to tx amount
          }
        }
        
        // assert that tx amounts sum up the amount sent within a small margin
        if (Math.abs(sendAmount.subtract(outgoingSum).toJSValue()) > SEND_MAX_DIFF) { // send amounts may be slightly different
          throw new Error("Tx amounts are too different: " + sendAmount + " - " + outgoingSum + " = " + sendAmount.subtract(outgoingSum));
        }
      }
      
      if (testConfig.testRelays)
      it("Can send to an address in a single transaction.", async function() {
        await testSendToSingle(new MoneroTxConfig().setCanSplit(false));
      });
      
      // NOTE: this test will be invalid when payment ids are fully removed
      if (testConfig.testRelays)
      it("Can send to an address in a single transaction with a payment id", async function() {
        let integratedAddress = await that.wallet.getIntegratedAddress();
        let paymentId = integratedAddress.getPaymentId();
        try {
          await testSendToSingle(new MoneroTxConfig().setCanSplit(false).setPaymentId(paymentId + paymentId + paymentId + paymentId));  // 64 character payment id
          throw new Error("fail");
        } catch (e) {
          assert.equal(e.message, "Standalone payment IDs are obsolete. Use subaddresses or integrated addresses instead");
        }
      });
      
      if (testConfig.testRelays)
      it("Can send to an address with split transactions", async function() {
        await testSendToSingle(new MoneroTxConfig().setCanSplit(true).setRelay(true));
      });
      
      if (testConfig.testRelays)
      it("Can create then relay a transaction to send to a single address", async function() {
        await testSendToSingle(new MoneroTxConfig().setCanSplit(false));
      });
      
      if (testConfig.testRelays)
      it("Can create then relay split transactions to send to a single address", async function() {
        await testSendToSingle(new MoneroTxConfig().setCanSplit(true));
      });
      
      async function testSendToSingle(config) {
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        if (!config) config = new MoneroTxConfig();
        
        // find a non-primary subaddress to send from
        let sufficientBalance = false;
        let fromAccount = undefined;
        let fromSubaddress = undefined;
        let accounts = await that.wallet.getAccounts(true);
        for (let account of accounts) {
          let subaddresses = account.getSubaddresses();
          for (let i = 1; i < subaddresses.length; i++) {
            if (subaddresses[i].getBalance().compare(TestUtils.MAX_FEE) > 0) sufficientBalance = true;
            if (subaddresses[i].getUnlockedBalance().compare(TestUtils.MAX_FEE) > 0) {
              fromAccount = account;
              fromSubaddress = subaddresses[i];
              break;
            }
          }
          if (fromAccount != undefined) break;
        }
        assert(sufficientBalance, "No non-primary subaddress found with sufficient balance");
        assert(fromSubaddress !== undefined, "Wallet is waiting on unlocked funds");
        
        // get balance before send
        let balanceBefore = fromSubaddress.getBalance();
        let unlockedBalanceBefore  = fromSubaddress.getUnlockedBalance();
        
        // init tx config
        let sendAmount = unlockedBalanceBefore.subtract(TestUtils.MAX_FEE).divide(new BigInteger(SEND_DIVISOR));
        let address = await that.wallet.getPrimaryAddress();
        let txs = []
        config.setDestinations([new MoneroDestination(address, sendAmount)]);
        config.setAccountIndex(fromAccount.getIndex());
        config.setSubaddressIndices([fromSubaddress.getIndex()]);
        let reqCopy = config.copy();
        
        // send to self
        if (config.getCanSplit() !== false) {
          for (let tx of await that.wallet.createTxs(config)) txs.push(tx);
        } else {
          txs.push(await that.wallet.createTx(config));
        }
        if (config.getCanSplit() === false) assert.equal(txs.length, 1);  // must have exactly one tx if no split
        
        // test that config is unchanged
        assert(reqCopy !== config);
        assert.deepEqual(config, reqCopy);
        
        // test common tx set among txs
        testCommonTxSets(txs, false, false, false);
        
        // handle non-relayed transaction
        if (config.getRelay() !== true) {
          
          // test transactions
          for (let tx of txs) {
            await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: true});
          }
          
          // txs are not in the pool
          for (let txCreated of txs) {
            for (let txPool of await that.daemon.getTxPool()) {
              assert(txPool.getHash() !== txCreated.getHash(), "Created tx should not be in the pool");
            }
          }
          
          // relay txs
          let txHashes;
          if (config.getCanSplit() !== true) txHashes = [await that.wallet.relayTx(txs[0])]; // test relayTx() with single transaction
          else {
            let txMetadatas = [];
            for (let tx of txs) txMetadatas.push(tx.getMetadata());
            txHashes = await that.wallet.relayTxs(txMetadatas); // test relayTxs() with potentially multiple transactions
          }  
          for (let txHash of txHashes) assert(typeof txHash === "string" && txHash.length === 64);
          
          // fetch txs for testing
          txs = await that.wallet.getTxs({hashes: txHashes});
        }
        
        // test that balance and unlocked balance decreased
        // TODO: test that other balances did not decrease
        let subaddress = await that.wallet.getSubaddress(fromAccount.getIndex(), fromSubaddress.getIndex());
        assert(subaddress.getBalance().compare(balanceBefore) < 0);
        assert(subaddress.getUnlockedBalance().compare(unlockedBalanceBefore) < 0);
        
        // query locked txs
        let lockedTxs = await that._getAndTestTxs(that.wallet, new MoneroTxQuery().setIsLocked(true), undefined, true);
        for (let lockedTx of lockedTxs) assert.equal(lockedTx.isLocked(), true);
        
        // test transactions
        assert(txs.length > 0);
        for (let tx of txs) {
          await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: config.getRelay() === true});
          assert.equal(tx.getOutgoingTransfer().getAccountIndex(), fromAccount.getIndex());
          assert.equal(tx.getOutgoingTransfer().getSubaddressIndices().length, 1);
          assert.equal(tx.getOutgoingTransfer().getSubaddressIndices()[0], fromSubaddress.getIndex());
          assert(sendAmount.compare(tx.getOutgoingAmount()) === 0);
          if (config.getPaymentId()) assert.equal(config.getPaymentId(), tx.getPaymentId());
          
          // test outgoing destinations
          if (tx.getOutgoingTransfer() && tx.getOutgoingTransfer().getDestinations()) {
            assert.equal(tx.getOutgoingTransfer().getDestinations().length, 1);
            for (let destination of tx.getOutgoingTransfer().getDestinations()) {
              await testDestination(destination);
              assert.equal(destination.getAddress(), address);
              assert(sendAmount.compare(destination.getAmount()) === 0);
            }
          }
          
          // tx is among locked txs
          let found = false;
          for (let lockedTx of lockedTxs) {
            if (lockedTx.getHash() === tx.getHash()) {
              found = true;
              break;
            }
          }
          assert(found, "Created txs should be among locked txs");
        }
        
        // if tx was relayed in separate step, all wallets will need to wait for tx to confirm in order to reliably sync
        if (config.getRelay() != true) {
          await TestUtils.WALLET_TX_TRACKER.reset(); // TODO: resetExcept(that.wallet), or does this test wallet also need to be waited on?
        }
      }
      
      if (testConfig.testRelays)
      it("Can send to multiple addresses in split transactions.", async function() {
        await testSendToMultiple(3, 15, true);
      });
      
      if (testConfig.testRelays)
      it("Can send to multiple addresses in split transactions using a JavaScript object for configuration", async function() {
        await testSendToMultiple(3, 15, true, undefined, true);
      });
      
      if (testConfig.testRelays)
      it("Can send dust to multiple addresses in split transactions", async function() {
        let dustAmt = (await that.daemon.getFeeEstimate()).divide(new BigInteger(2));
        await testSendToMultiple(5, 3, true, dustAmt);
      });
      
      /**
       * Sends funds from the first unlocked account to multiple accounts and subaddresses.
       * 
       * @param numAccounts is the number of accounts to receive funds
       * @param numSubaddressesPerAccount is the number of subaddresses per account to receive funds
       * @param canSplit specifies if the operation can be split into multiple transactions
       * @param sendAmountPerSubaddress is the amount to send to each subaddress (optional, computed if not given)
       * @param useJsConfig specifies if the api should be invoked with a JS object instead of a MoneroTxConfig
       */
      async function testSendToMultiple(numAccounts, numSubaddressesPerAccount, canSplit, sendAmountPerSubaddress, useJsConfig) {
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        
        // compute the minimum account unlocked balance needed in order to fulfill the request
        let minAccountAmount;
        let totalSubaddresses = numAccounts * numSubaddressesPerAccount;
        if (sendAmountPerSubaddress !== undefined) minAccountAmount = new BigInteger(totalSubaddresses).multiply(sendAmountPerSubaddress.add(TestUtils.MAX_FEE)); // min account amount must cover the total amount being sent plus the tx fee = numAddresses * (amtPerSubaddress + fee)
        else minAccountAmount = TestUtils.MAX_FEE.multiply(new BigInteger(totalSubaddresses)).multiply(new BigInteger(SEND_DIVISOR)).add(TestUtils.MAX_FEE); // account balance must be more than fee * numAddresses * divisor + fee so each destination amount is at least a fee's worth (so dust is not sent)
        
        // send funds from first account with sufficient unlocked funds
        let srcAccount;
        let hasBalance = false;
        for (let account of await that.wallet.getAccounts()) {
          if (account.getBalance().compare(minAccountAmount) > 0) hasBalance = true;
          if (account.getUnlockedBalance().compare(minAccountAmount) > 0) {
            srcAccount = account;
            break;
          }
        }
        assert(hasBalance, "Wallet does not have enough balance; load '" + TestUtils.WALLET_NAME + "' with XMR in order to test sending");
        assert(srcAccount, "Wallet is waiting on unlocked funds");
        let balance = srcAccount.getBalance();
        let unlockedBalance = srcAccount.getUnlockedBalance();
        
        // get amount to send total and per subaddress
        let sendAmount;
        if (sendAmountPerSubaddress === undefined) {
          sendAmount = TestUtils.MAX_FEE.multiply(new BigInteger("5")).multiply(new BigInteger(totalSubaddresses));
          sendAmountPerSubaddress = sendAmount.divide(new BigInteger(totalSubaddresses));
        } else {
          sendAmount = sendAmountPerSubaddress.multiply(new BigInteger(totalSubaddresses));
        }
        
        // create minimum number of accounts
        let accounts = await that.wallet.getAccounts();
        for (let i = 0; i < numAccounts - accounts.length; i++) {
          await that.wallet.createAccount();
        }
        
        // create minimum number of subaddresses per account and collect destination addresses
        let destinationAddresses = [];
        for (let i = 0; i < numAccounts; i++) {
          let subaddresses = await that.wallet.getSubaddresses(i);
          for (let j = 0; j < numSubaddressesPerAccount - subaddresses.length; j++) await that.wallet.createSubaddress(i);
          subaddresses = await that.wallet.getSubaddresses(i);
          assert(subaddresses.length >= numSubaddressesPerAccount);
          for (let j = 0; j < numSubaddressesPerAccount; j++) destinationAddresses.push(subaddresses[j].getAddress());
        }
        
        // build tx config using MoneroTxConfig
        let config = new MoneroTxConfig();
        config.setAccountIndex(srcAccount.getIndex());
        config.setDestinations([]);
        config.setCanSplit(canSplit);
        config.setPriority(MoneroTxPriority.NORMAL);
        config.setRelay(true);
        for (let i = 0; i < destinationAddresses.length; i++) {
          config.getDestinations().push(new MoneroDestination(destinationAddresses[i], sendAmountPerSubaddress));
        }
        let configCopy = config.copy();
        
        // build tx config with JS object
        let jsConfig;
        if (useJsConfig) {
          jsConfig = {};
          jsConfig.ringSize = MoneroUtils.RING_SIZE;
          jsConfig.accountIndex = srcAccount.getIndex();
          jsConfig.relay = true;
          jsConfig.destinations = [];
          for (let i = 0; i < destinationAddresses.length; i++) {
            jsConfig.destinations.push({address: destinationAddresses[i], amount: sendAmountPerSubaddress});
          }
        }
        
        // send tx(s) with config xor js object
        let txs = [];
        if (canSplit) {
          for (let tx of await that.wallet.createTxs(useJsConfig ? jsConfig : config)) txs.push(tx);
        } else {
          txs.push(await that.wallet.createTx(useJsConfig ? jsConfig : config));
        }
        
        // test that config is unchanged
        assert(configCopy !== config);
        assert.deepEqual(config, configCopy);
        
        // test that wallet balance decreased
        let account = await that.wallet.getAccount(srcAccount.getIndex());
        assert(account.getBalance().compare(balance) < 0);
        assert(account.getUnlockedBalance().compare(unlockedBalance) < 0);
        
        // test each transaction
        assert(txs.length > 0);
        let outgoingSum = new BigInteger(0);
        for (let tx of txs) {
          await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: true});
          outgoingSum = outgoingSum.add(tx.getOutgoingAmount());
          if (tx.getOutgoingTransfer() !== undefined && tx.getOutgoingTransfer().getDestinations()) {
            let destinationSum = new BigInteger(0);
            for (let destination of tx.getOutgoingTransfer().getDestinations()) {
              await testDestination(destination);
              assert(destinationAddresses.includes(destination.getAddress()));
              destinationSum = destinationSum.add(destination.getAmount());
            }
            assert(tx.getOutgoingAmount().compare(destinationSum) === 0);  // assert that transfers sum up to tx amount
          }
        }
        
        // assert that outgoing amounts sum up to the amount sent within a small margin
        if (Math.abs(sendAmount.subtract(outgoingSum).toJSValue()) > SEND_MAX_DIFF) { // send amounts may be slightly different
          throw new Error("Actual send amount is too different from requested send amount: " + sendAmount + " - " + outgoingSum + " = " + sendAmount.subtract(outgoingSum));
        }
      }
      
      if (!testConfig.liteMode && (testConfig.testNonRelays || testConfig.testRelays))
      it("Supports view-only and offline wallets to create, sign, and submit transactions", async function() {
        
        // create view-only and offline wallets
        let viewOnlyWallet = await that.createWallet({primaryAddress: await that.wallet.getPrimaryAddress(), privateViewKey: await that.wallet.getPrivateViewKey(), restoreHeight: TestUtils.FIRST_RECEIVE_HEIGHT});
        let offlineWallet = await that.createWallet({primaryAddress: await that.wallet.getPrimaryAddress(), privateViewKey: await that.wallet.getPrivateViewKey(), privateSpendKey: await that.wallet.getPrivateSpendKey(), serverUri: TestUtils.OFFLINE_SERVER_URI, restoreHeight: 0});
        await viewOnlyWallet.sync();
        
        // test tx signing with wallets
        let err;
        try {
          await that._testViewOnlyAndOfflineWallets(viewOnlyWallet, offlineWallet);
        } catch (e) {
          err = e;
        }
        
        // finally
        await that.closeWallet(viewOnlyWallet);
        await that.closeWallet(offlineWallet);
        if (err) throw err;
      });
      
      if (testConfig.testRelays)
      it("Can sweep individual outputs identified by their key images", async function() {
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        
        // test config
        let numOutputs = 3;
        
        // get outputs to sweep (not spent, unlocked, and amount >= fee)
        let spendableUnlockedOutputs = await that.wallet.getOutputs(new MoneroOutputQuery().setIsSpent(false).setTxQuery(new MoneroTxQuery().setIsLocked(false)));
        let outputsToSweep = [];
        for (let i = 0; i < spendableUnlockedOutputs.length && outputsToSweep.length < numOutputs; i++) {
          if (spendableUnlockedOutputs[i].getAmount().compare(TestUtils.MAX_FEE) > 0) outputsToSweep.push(spendableUnlockedOutputs[i]);  // output cannot be swept if amount does not cover fee
        }
        assert(outputsToSweep.length >= numOutputs, "Wallet does not have enough sweepable outputs; run send tests");
        
        // sweep each output by key image
        for (let output of outputsToSweep) {
          testOutputWallet(output);
          assert.equal(output.isSpent(), false);
          assert.equal(output.isLocked(), false);
          if (output.getAmount().compare(TestUtils.MAX_FEE) <= 0) continue;
          
          // sweep output to address
          let address = await that.wallet.getAddress(output.getAccountIndex(), output.getSubaddressIndex());
          let config = new MoneroTxConfig({address: address, keyImage: output.getKeyImage().getHex(), relay: true});
          let tx = await that.wallet.sweepOutput(config);
          
          // test resulting tx
          config.setCanSplit(false);
          await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: true, isSweepResponse: true, isSweepOutputResponse: true});
        }
        
        // get outputs after sweeping
        let afterOutputs = await that.wallet.getOutputs();
        
        // swept output are now spent
        for (let afterOutput of afterOutputs) {
          for (let output of outputsToSweep) {
            if (output.getKeyImage().getHex() === afterOutput.getKeyImage().getHex()) {
              assert(afterOutput.isSpent(), "Output should be spent");
            }
          }
        }
      });
      
      if (testConfig.testRelays)
      it("Can sweep dust without relaying", async function() {
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        
        // sweep dust which returns empty list if no dust to sweep (dust does not exist after rct)
        let txs = await that.wallet.sweepDust(false);
        if (txs.length == 0) return;
        
        // test txs
        let ctx = {config: new MoneroTxConfig(), isSendResponse: true, isSweepResponse: true};
        for (let tx of txs) {
          await that._testTxWallet(tx, ctx);
        }
        
        // relay txs
        let metadatas = [];
        for (let tx of txs) metadatas.push(tx.getMetadata());
        let txHashes = await that.wallet.relayTxs(metadatas);
        assert.equal(txs.length, txHashes.length);
        for (let txHash of txHashes) assert.equal(txHash.length, 64);
        
        // fetch and test txs
        txs = wallet.getTxs(new MoneroTxQuery().setHashes(txHashes));
        ctx.config.setRelay(true);
        for (let tx of txs) {
          await that._testTxWallet(tx, ctx);
        }
      });
      
      if (testConfig.testRelays)
      it("Can sweep dust", async function() {
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        
        // sweep dust which returns empty list if no dust to sweep (dust does not exist after rct)
        let txs = await that.wallet.sweepDust(true);
        
        // test any txs
        let ctx = {wallet: that.wallet, isSendResponse: true, isSweepResponse: true};
        for (let tx of txs) {
          await that._testTxWallet(tx, ctx);
        }
      });
      
      it("Supports multisig wallets", async function() {
        await that._testMultisig(2, 2, false); // n/n
        await that._testMultisig(2, 3, false); // (n-1)/n
        await that._testMultisig(2, 4, testConfig.testRelays && !testConfig.liteMode); // m/n
      });
      
      // ---------------------------- TEST RESETS -----------------------------
      
      if (testConfig.testResets)
      it("Can sweep subaddresses", async function() {
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        
        const NUM_SUBADDRESSES_TO_SWEEP = 2;
        
        // collect subaddresses with balance and unlocked balance
        let subaddresses = [];
        let subaddressesBalance = [];
        let subaddressesUnlocked = [];
        for (let account of await that.wallet.getAccounts(true)) {
          if (account.getIndex() === 0) continue;  // skip default account
          for (let subaddress of account.getSubaddresses()) {
            subaddresses.push(subaddress);
            if (subaddress.getBalance().compare(TestUtils.MAX_FEE) > 0) subaddressesBalance.push(subaddress);
            if (subaddress.getUnlockedBalance().compare(TestUtils.MAX_FEE) > 0) subaddressesUnlocked.push(subaddress);
          }
        }
        
        // test requires at least one more subaddresses than the number being swept to verify it does not change
        assert(subaddressesBalance.length >= NUM_SUBADDRESSES_TO_SWEEP + 1, "Test requires balance in at least " + (NUM_SUBADDRESSES_TO_SWEEP + 1) + " subaddresses from non-default acccount; run send-to-multiple tests");
        assert(subaddressesUnlocked.length >= NUM_SUBADDRESSES_TO_SWEEP + 1, "Wallet is waiting on unlocked funds");
        
        // sweep from first unlocked subaddresses
        for (let i = 0; i < NUM_SUBADDRESSES_TO_SWEEP; i++) {
          
          // sweep unlocked account
          let unlockedSubaddress = subaddressesUnlocked[i];
          let config = new MoneroTxConfig({
            address: await that.wallet.getPrimaryAddress(),
            accountIndex: unlockedSubaddress.getAccountIndex(),
            subaddressIndex: unlockedSubaddress.getIndex(),
            relay: true
          });
          let txs = await that.wallet.sweepUnlocked(config);
          
          // test transactions
          assert(txs.length > 0);
          for (let tx of txs) {
            assert(GenUtils.arrayContains(tx.getTxSet().getTxs(), tx));
            await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: true, isSweepResponse: true});
          }
          
          // assert unlocked balance is less than max fee
          let subaddress = await that.wallet.getSubaddress(unlockedSubaddress.getAccountIndex(), unlockedSubaddress.getIndex());
          assert(subaddress.getUnlockedBalance().compare(TestUtils.MAX_FEE) < 0);
        }
        
        // test subaddresses after sweeping
        let subaddressesAfter = [];
        for (let account of await that.wallet.getAccounts(true)) {
          if (account.getIndex() === 0) continue;  // skip default account
          for (let subaddress of account.getSubaddresses()) {
            subaddressesAfter.push(subaddress);
          }
        }
        assert.equal(subaddressesAfter.length, subaddresses.length);
        for (let i = 0; i < subaddresses.length; i++) {
          let subaddressBefore = subaddresses[i];
          let subaddressAfter = subaddressesAfter[i];
          
          // determine if subaddress was swept
          let swept = false;
          for (let j = 0; j < NUM_SUBADDRESSES_TO_SWEEP; j++) {
            if (subaddressesUnlocked[j].getAccountIndex() === subaddressBefore.getAccountIndex() && subaddressesUnlocked[j].getIndex() === subaddressBefore.getIndex()) {
              swept = true;
              break;
            }
          }
          
          // assert unlocked balance is less than max fee if swept, unchanged otherwise
          if (swept) {
            assert(subaddressAfter.getUnlockedBalance().compare(TestUtils.MAX_FEE) < 0);
          } else {
            assert(subaddressBefore.getUnlockedBalance().compare(subaddressAfter.getUnlockedBalance()) === 0);
          }
        }
      });
      
      if (testConfig.testResets)
      it("Can sweep accounts", async function() {
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        const NUM_ACCOUNTS_TO_SWEEP = 1;
        
        // collect accounts with sufficient balance and unlocked balance to cover the fee
        let accounts = await that.wallet.getAccounts(true);
        let accountsBalance = [];
        let accountsUnlocked = [];
        for (let account of accounts) {
          if (account.getIndex() === 0) continue; // skip default account
          if (account.getBalance().compare(TestUtils.MAX_FEE) > 0) accountsBalance.push(account);
          if (account.getUnlockedBalance().compare(TestUtils.MAX_FEE) > 0) accountsUnlocked.push(account);
        }
        
        // test requires at least one more accounts than the number being swept to verify it does not change
        assert(accountsBalance.length >= NUM_ACCOUNTS_TO_SWEEP + 1, "Test requires balance greater than the fee in at least " + (NUM_ACCOUNTS_TO_SWEEP + 1) + " non-default accounts; run send-to-multiple tests");
        assert(accountsUnlocked.length >= NUM_ACCOUNTS_TO_SWEEP + 1, "Wallet is waiting on unlocked funds");
        
        // sweep from first unlocked accounts
        for (let i = 0; i < NUM_ACCOUNTS_TO_SWEEP; i++) {
          
          // sweep unlocked account
          let unlockedAccount = accountsUnlocked[i];
          let config = new MoneroTxConfig().setAddress(await that.wallet.getPrimaryAddress()).setAccountIndex(unlockedAccount.getIndex()).setRelay(true);
          let txs = await that.wallet.sweepUnlocked(config);
          
          // test transactions
          assert(txs.length > 0);
          for (let tx of txs) {
            await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: true, isSweepResponse: true});
          }
          
          // assert unlocked account balance less than max fee
          let account = await that.wallet.getAccount(unlockedAccount.getIndex());
          assert(account.getUnlockedBalance().compare(TestUtils.MAX_FEE) < 0);
        }
        
        // test accounts after sweeping
        let accountsAfter = await that.wallet.getAccounts(true);
        assert.equal(accountsAfter.length, accounts.length);
        for (let i = 0; i < accounts.length; i++) {
          let accountBefore = accounts[i];
          let accountAfter = accountsAfter[i];
          
          // determine if account was swept
          let swept = false;
          for (let j = 0; j < NUM_ACCOUNTS_TO_SWEEP; j++) {
            if (accountsUnlocked[j].getIndex() === accountBefore.getIndex()) {
              swept = true;
              break;
            }
          }
          
          // assert unlocked balance is less than max fee if swept, unchanged otherwise
          if (swept) {
            assert(accountAfter.getUnlockedBalance().compare(TestUtils.MAX_FEE) < 0);
          } else {
            assert.equal(accountBefore.getUnlockedBalance().compare(accountAfter.getUnlockedBalance()), 0);
          }
        }
      });
      
      if (testConfig.testResets)
      it("Can sweep the whole wallet by accounts", async function() {
        assert(false, "Are you sure you want to sweep the whole wallet?");
        await _testSweepWallet();
      });
      
      if (testConfig.testResets)
      it("Can sweep the whole wallet by subaddresses", async function() {
        assert(false, "Are you sure you want to sweep the whole wallet?");
        await _testSweepWallet(true);
      });
      
      async function _testSweepWallet(sweepEachSubaddress) {
        await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(that.wallet);
        
        // verify 2 subaddresses with enough unlocked balance to cover the fee
        let subaddressesBalance = [];
        let subaddressesUnlocked = [];
        for (let account of await that.wallet.getAccounts(true)) {
          for (let subaddress of account.getSubaddresses()) {
            if (subaddress.getBalance().compare(TestUtils.MAX_FEE) > 0) subaddressesBalance.push(subaddress);
            if (subaddress.getUnlockedBalance().compare(TestUtils.MAX_FEE) > 0) subaddressesUnlocked.push(subaddress);
          }
        }
        assert(subaddressesBalance.length >= 2, "Test requires multiple accounts with a balance greater than the fee; run send to multiple first");
        assert(subaddressesUnlocked.length >= 2, "Wallet is waiting on unlocked funds");
        
        // sweep
        let destination = await that.wallet.getPrimaryAddress();
        let config = new MoneroTxConfig().setAddress(destination).setSweepEachSubaddress(sweepEachSubaddress).setRelay(true);
        let copy = config.copy();
        let txs = await that.wallet.sweepUnlocked(config);
        assert.deepEqual(config, copy); // config is unchanged
        for (let tx of txs) {
          assert(GenUtils.arrayContains(tx.getTxSet().getTxs(), tx));
          assert.equal(tx.getTxSet().getMultisigTxHex(), undefined);
          assert.equal(tx.getTxSet().getSignedTxHex(), undefined);
          assert.equal(tx.getTxSet().getUnsignedTxHex(), undefined);
        }
        assert(txs.length > 0);
        for (let tx of txs) {
          config = new MoneroTxConfig({
            address: destination,
            accountIndex: tx.getOutgoingTransfer().getAccountIndex(),
            sweepEachSubaddress: sweepEachSubaddress,
            relay: true
          });
          await that._testTxWallet(tx, {wallet: that.wallet, config: config, isSendResponse: true, isSweepResponse: true});
        }
        
        // all unspent, unlocked outputs must be less than fee
        let spendableOutputs = await that.wallet.getOutputs(new MoneroOutputQuery().setIsSpent(false).setTxQuery(new MoneroTxQuery().setIsLocked(false)));
        for (let spendableOutput of spendableOutputs) {
          assert(spendableOutput.getAmount().compare(TestUtils.MAX_FEE) < 0, "Unspent output should have been swept\n" + spendableOutput.toString());
        }
        
        // all subaddress unlocked balances must be less than fee
        subaddressesBalance = [];
        subaddressesUnlocked = [];
        for (let account of await that.wallet.getAccounts(true)) {
          for (let subaddress of account.getSubaddresses()) {
            assert(subaddress.getUnlockedBalance().compare(TestUtils.MAX_FEE) < 0, "No subaddress should have more unlocked than the fee");
          }
        }
      }
      
      it("Can scan transactions by id", async function() {
        
        // get a few tx hashes
        let txHashes = [];
        let txs = await that.wallet.getTxs();
        if (txs.length < 3) throw new Error("Not enough txs to scan");
        for (let i = 0; i < 3; i++) txHashes.push(txs[i].getHash());
        
        // start wallet without scanning
        let scanWallet = await that.createWallet(new MoneroWalletConfig().setMnemonic(await that.wallet.getMnemonic()).setRestoreHeight(0));
        await scanWallet.stopSyncing(); // TODO: create wallet without daemon connection (offline does not reconnect, default connects to localhost, offline then online causes confirmed txs to disappear)
        assert(await scanWallet.isConnectedToDaemon());
        
        // scan txs
        await scanWallet.scanTxs(txHashes);
        
        // TODO: scanning txs causes merge problems reconciling 0 fee, isMinerTx with test txs
        
    //    // txs are scanned
    //    assertEquals(txHashes.size(), scanWallet.getTxs().size());
    //    for (int i = 0; i < txHashes.size(); i++) {
    //      assertEquals(wallet.getTx(txHashes.get(i)), scanWallet.getTx(txHashes.get(i)));
    //    }
    //    List<MoneroTxWallet> scannedTxs = scanWallet.getTxs(txHashes);
    //    assertEquals(txHashes.size(), scannedTxs.size());
        
        // close wallet
        await that.closeWallet(scanWallet, false);
      });
      
      // disabled so tests don't delete local cache
      if (testConfig.testResets)
      it("Can rescan the blockchain", async function() {
        assert(false, "Are you sure you want to discard local wallet data and rescan the blockchain?");
        await that.wallet.rescanBlockchain();
        for (let tx of await that.wallet.getTxs()) {
          await that._testTxWallet(tx);
        }
      });
      
      if (testConfig.testNonRelays)
      it("Can freeze and thaw outputs", async function() {
        
        // get an available output
        let outputs = await that.wallet.getOutputs(new MoneroOutputQuery().setIsSpent(false).setIsFrozen(false).setTxQuery(new MoneroTxQuery().setIsLocked(false)));
        for (let output of outputs) assert.equal(false, output.isFrozen());
        assert(outputs.length > 0);
        let output = outputs[0];
        assert.equal(false, output.getTx().isLocked());
        assert.equal(false, output.isSpent());
        assert.equal(false, output.isFrozen());
        assert.equal(false, await that.wallet.isOutputFrozen(output.getKeyImage().getHex()));
        
        // freeze output by key image
        let numFrozenBefore = (await that.wallet.getOutputs(new MoneroOutputQuery().setIsFrozen(true))).length;
        await that.wallet.freezeOutput(output.getKeyImage().getHex());
        assert.equal(true, await that.wallet.isOutputFrozen(output.getKeyImage().getHex()));
    
        // test querying
        assert.equal(numFrozenBefore + 1, (await that.wallet.getOutputs(new MoneroOutputQuery().setIsFrozen(true))).length);
        outputs = await that.wallet.getOutputs(new MoneroOutputQuery().setKeyImage(new MoneroKeyImage().setHex(output.getKeyImage().getHex())).setIsFrozen(true));
        assert.equal(1, outputs.length);
        let outputFrozen = outputs[0];
        assert.equal(true, outputFrozen.isFrozen());
        assert.equal(output.getKeyImage().getHex(), outputFrozen.getKeyImage().getHex());
        
        // try to sweep frozen output
        try {
          await that.wallet.sweepOutput(new MoneroTxConfig().setAddress(await that.wallet.getPrimaryAddress()).setKeyImage(output.getKeyImage().getHex()));
          throw new Error("Should have thrown error");
        } catch (e) {
          assert.equal("No outputs found", e.message);
        }
        
        // try to freeze undefined key image
        try {
          await that.wallet.freezeOutput(undefined);
          throw new Error("Should have thrown error");
        } catch (e) {
          assert.equal("Must specify key image to freeze", e.message);
        }
        
        // try to freeze empty key image
        try {
          await that.wallet.freezeOutput("");
          throw new Error("Should have thrown error");
        } catch (e) {
          assert.equal("Must specify key image to freeze", e.message);
        }
        
        // try to freeze bad key image
        try {
          await that.wallet.freezeOutput("123");
          throw new Error("Should have thrown error");
        } catch (e) {
          //assert.equal("Bad key image", e.message);
        }
    
        // thaw output by key image
        await that.wallet.thawOutput(output.getKeyImage().getHex());
        assert.equal(false, await that.wallet.isOutputFrozen(output.getKeyImage().getHex()));
    
        // test querying
        assert.equal(numFrozenBefore, (await that.wallet.getOutputs(new MoneroOutputQuery().setIsFrozen(true))).length);
        outputs = await that.wallet.getOutputs(new MoneroOutputQuery().setKeyImage(new MoneroKeyImage().setHex(output.getKeyImage().getHex())).setIsFrozen(true));
        assert.equal(0, outputs.length);
        outputs = await that.wallet.getOutputs(new MoneroOutputQuery().setKeyImage(new MoneroKeyImage().setHex(output.getKeyImage().getHex())).setIsFrozen(false));
        assert.equal(1, outputs.length);
        let outputThawed = outputs[0];
        assert.equal(false, outputThawed.isFrozen());
        assert.equal(output.getKeyImage().getHex(), outputThawed.getKeyImage().getHex());
      });
      
      if (testConfig.testNonRelays)
      it("Provides key images of spent outputs", async function() {
        let accountIndex = 0;
        let subaddressIndex = 0;
      
        // test unrelayed single transaction
        testSpendTx(await that.wallet.createTx(new MoneroTxConfig().addDestination(await that.wallet.getPrimaryAddress(), TestUtils.MAX_FEE).setAccountIndex(accountIndex)));
        
        // test unrelayed split transactions
        for (let tx of await that.wallet.createTxs(new MoneroTxConfig().addDestination(await that.wallet.getPrimaryAddress(), TestUtils.MAX_FEE).setAccountIndex(accountIndex))) {
          testSpendTx(tx);
        }
        
        // test unrelayed sweep dust
        let dustKeyImages = [];
        for (let tx of await that.wallet.sweepDust(false)) {
          testSpendTx(tx);
          for (let input of tx.getInputs()) dustKeyImages.add(input.getKeyImage().getHex());
        }
        
        // get available outputs above min amount
        let outputs = await that.wallet.getOutputs(new MoneroOutputQuery().setAccountIndex(accountIndex).setSubaddressIndex(subaddressIndex).setIsSpent(false).setIsFrozen(false).setTxQuery(new MoneroTxQuery().setIsLocked(false)).setMinAmount(TestUtils.MAX_FEE));
        
        // filter dust outputs
        let dustOutputs = [];
        for (let output of outputs) {
          if (dustKeyImages.includes(output.getKeyImage().getHex())) dustOutputs.push(output);
        }
        outputs = outputs.filter(output => !dustOutputs.includes(output)); // remove dust outputs
        
        // test unrelayed sweep output
        testSpendTx(await that.wallet.sweepOutput(new MoneroTxConfig().setAddress(await that.wallet.getPrimaryAddress()).setKeyImage(outputs[0].getKeyImage().getHex())));
        
        // test unrelayed sweep wallet ensuring all non-dust outputs are spent
        let availableKeyImages = new Set();
        for (let output of outputs) availableKeyImages.add(output.getKeyImage().getHex());
        let sweptKeyImages = new Set();
        let txs = await that.wallet.sweepUnlocked(new MoneroTxConfig().setAccountIndex(accountIndex).setSubaddressIndex(subaddressIndex).setAddress(await that.wallet.getPrimaryAddress()));
        for (let tx of txs) {
          testSpendTx(tx);
          for (let input of tx.getInputs()) sweptKeyImages.add(input.getKeyImage().getHex());
        }
        assert(sweptKeyImages.size > 0);
        
        // max skipped output is less than max fee amount
        let maxSkippedOutput = undefined;
        for (let output of outputs) {
          if (!sweptKeyImages.has(output.getKeyImage().getHex())) {
            if (maxSkippedOutput === undefined || maxSkippedOutput.getAmount().compare(output.getAmount()) < 0) {
              maxSkippedOutput = output;
            }
          }
        }
        assert(maxSkippedOutput === undefined || maxSkippedOutput.getAmount().compare(TestUtils.MAX_FEE) < 0);
      });
      
      function testSpendTx(spendTx) {
        assert.notEqual(undefined, spendTx.getInputs());
        assert(spendTx.getInputs().length > 0);
        for (let input of spendTx.getInputs()) assert(input.getKeyImage().getHex());
      }
      
      if (testConfig.testNonRelays)
      it("Can prove unrelayed txs", async function() {
      
        // create unrelayed tx to verify
        let address1 = await TestUtils.getExternalWalletAddress();
        let address2 = await that.wallet.getAddress(0, 0);
        let address3 = await that.wallet.getAddress(1, 0);
        let tx = await that.wallet.createTx(new MoneroTxConfig()
                .setAccountIndex(0)
                .addDestination(address1, TestUtils.MAX_FEE)
                .addDestination(address2, TestUtils.MAX_FEE.multiply(new BigInteger("2")))
                .addDestination(address3, TestUtils.MAX_FEE.multiply(new BigInteger("3"))));
        
        // submit tx to daemon but do not relay
        let result = await that.daemon.submitTxHex(tx.getFullHex(), true);
        assert.equal(result.isGood(), true);
        
        // create random wallet to verify transfers
        let verifyingWallet = await that.createWallet(new MoneroWalletConfig());
        
        // verify transfer 1
        let check = await verifyingWallet.checkTxKey(tx.getHash(), tx.getKey(), address1);
        assert.equal(check.isGood(), true);
        assert.equal(check.inTxPool(), true);
        assert.equal(check.getNumConfirmations(), 0);
        assert.equal(check.getReceivedAmount().toString(), TestUtils.MAX_FEE.toString());
        
        // verify transfer 2
        check = await verifyingWallet.checkTxKey(tx.getHash(), tx.getKey(), address2);
        assert.equal(check.isGood(), true);
        assert.equal(check.inTxPool(), true);
        assert.equal(check.getNumConfirmations(), 0);
        assert.equal(check.getReceivedAmount().compare(TestUtils.MAX_FEE.multiply(new BigInteger("2"))) >= 0, true); // + change amount
        
        // verify transfer 3
        check = await verifyingWallet.checkTxKey(tx.getHash(), tx.getKey(), address3);
        assert.equal(check.isGood(), true);
        assert.equal(check.inTxPool(), true);
        assert.equal(check.getNumConfirmations(), 0);
        assert.equal(check.getReceivedAmount().toString(), TestUtils.MAX_FEE.multiply(new BigInteger("3")).toString());
        
        // cleanup
        await that.daemon.flushTxPool(tx.getHash());
        await that.closeWallet(verifyingWallet);
      });
    });
  }
  
  // -------------------------------- PRIVATE ---------------------------------

  async getSubaddressesWithBalance() {
    let subaddresses = [];
    for (let account of await this.wallet.getAccounts(true)) {
      for (let subaddress of account.getSubaddresses()) {
        if (subaddress.getBalance().toJSValue() > 0) subaddresses.push(subaddress);
      }
    }
    return subaddresses;
  }

  async getSubaddressesWithUnlockedBalance() {
    let subaddresses = [];
    for (let account of await this.wallet.getAccounts(true)) {
      for (let subaddress of account.getSubaddresses()) {
        if (subaddress.getUnlockedBalance().toJSValue() > 0) subaddresses.push(subaddress);
      }
    }
    return subaddresses;
  }
  
  async _testGetSubaddressAddressOutOfRange() {
    let accounts = await this.wallet.getAccounts(true);
    let accountIdx = accounts.length - 1;
    let subaddressIdx = accounts[accountIdx].getSubaddresses().length;
    let address = await this.wallet.getAddress(accountIdx, subaddressIdx);
    assert.notEqual(address, undefined);  // subclass my override with custom behavior (e.g. jni returns subaddress but wallet rpc does not)
    assert(address.length > 0);
  }
  
  /**
   * Fetches and tests transactions according to the given query.
   * 
   * TODO: convert query to query object and ensure each tx passes filter, same with getAndTestTransfer, getAndTestOutputs
   */
  async _getAndTestTxs(wallet, query, isExpected) {
    let copy;
    if (query !== undefined) {
      if (query instanceof MoneroTxQuery) copy = query.copy();
      else copy = Object.assign({}, query);
    }
    let txs = await wallet.getTxs(query);
    assert(Array.isArray(txs));
    if (isExpected === false) assert.equal(txs.length, 0);
    if (isExpected === true) assert(txs.length > 0, "Transactions were expected but not found; run send tests?");
    for (let tx of txs) await this._testTxWallet(tx, Object.assign({wallet: wallet}, query));
    testGetTxsStructure(txs, query);
    if (query !== undefined) {
      if (query instanceof MoneroTxQuery) assert.deepEqual(query.toJson(), copy.toJson());
      else assert.deepEqual(query, copy);
    }
    return txs;
  }

  /**
   * Fetches and tests transfers according to the given query.
   */
  async _getAndTestTransfers(wallet, query, isExpected) {
    let copy;
    if (query !== undefined) {
      if (query instanceof MoneroTransferQuery) copy = query.copy();
      else copy = Object.assign({}, query);
    }
    let transfers = await wallet.getTransfers(query);
    assert(Array.isArray(transfers));
    if (isExpected === false) assert.equal(transfers.length, 0);
    if (isExpected === true) assert(transfers.length > 0, "Transfers were expected but not found; run send tests?");
    for (let transfer of transfers) await this._testTxWallet(transfer.getTx(), Object.assign({wallet: wallet}, query));
    if (query !== undefined) {
      if (query instanceof MoneroTransferQuery) assert.deepEqual(query.toJson(), copy.toJson());
      else assert.deepEqual(query, copy);
    }
    return transfers;
  }
  
  /**
   * Fetches and tests outputs according to the given query.
   */
  async _getAndTestOutputs(wallet, query, isExpected) {
    let copy;
    if (query !== undefined) {
      if (query instanceof MoneroOutputQuery) copy = query.copy();
      else copy = Object.assign({}, query);
    }
    let outputs = await wallet.getOutputs(query);
    assert(Array.isArray(outputs));
    if (isExpected === false) assert.equal(outputs.length, 0);
    if (isExpected === true) assert(outputs.length > 0, "Outputs were expected but not found; run send tests?");
    for (let output of outputs) testOutputWallet(output);
    if (query !== undefined) {
      if (query instanceof MoneroOutputQuery) assert.deepEqual(query.toJson(), copy.toJson());
      else assert.deepEqual(query, copy);
    }
    return outputs;
  }
  
  /**
   * Tests a wallet transaction with a test configuration.
   * 
   * @param tx is the wallet transaction to test
   * @param ctx specifies test configuration
   *        ctx.wallet is used to cross reference tx info if available
   *        ctx.config specifies the tx's originating send configuration
   *        ctx.isSendResponse indicates if the tx is built from a send response, which contains additional fields (e.g. key)
   *        ctx.hasDestinations specifies if the tx has an outgoing transfer with destinations, undefined if doesn't matter
   *        ctx.includeOutputs specifies if outputs were fetched and should therefore be expected with incoming transfers
   */
  async _testTxWallet(tx, ctx) {
    
    // validate / sanitize inputs
    ctx = Object.assign({}, ctx);
    delete ctx.wallet; // TODO: re-enable
    if (!(tx instanceof MoneroTxWallet)) {
      console.log("Tx is not a MoneroTxWallet!");
      console.log(tx);
    }
    assert(tx instanceof MoneroTxWallet);
    if (ctx.wallet) assert(ctx.wallet instanceof MoneroWallet);
    assert(ctx.hasDestinations == undefined || typeof ctx.hasDestinations === "boolean");
    if (ctx.isSendResponse === undefined || ctx.config === undefined) {
      assert.equal(ctx.isSendResponse, undefined, "if either config or isSendResponse is defined, they must both be defined");
      assert.equal(ctx.config, undefined, "if either config or isSendResponse is defined, they must both be defined");
    }
    
    // test common field types
    assert.equal(typeof tx.getHash(), "string");
    assert.equal(typeof tx.isConfirmed(), "boolean");
    assert.equal(typeof tx.isMinerTx(), "boolean");
    assert.equal(typeof tx.isFailed(), "boolean");
    assert.equal(typeof tx.isRelayed(), "boolean");
    assert.equal(typeof tx.inTxPool(), "boolean");
    assert.equal(typeof tx.isLocked(), "boolean");
    TestUtils.testUnsignedBigInteger(tx.getFee());
    if (tx.getPaymentId()) assert.notEqual(tx.getPaymentId(), MoneroTx.DEFAULT_PAYMENT_ID); // default payment id converted to undefined
    if (tx.getNote()) assert(tx.getNote().length > 0);  // empty notes converted to undefined
    assert(tx.getUnlockHeight() >= 0);
    assert.equal(tx.getSize(), undefined);   // TODO monero-wallet-rpc: add tx_size to get_transfers and get_transfer_by_txid
    assert.equal(tx.getReceivedTimestamp(), undefined);  // TODO monero-wallet-rpc: return received timestamp (asked to file issue if wanted)
    
    // test send tx
    if (ctx.isSendResponse) {
      assert(tx.getWeight() > 0);
      assert.notEqual(tx.getInputs(), undefined);
      assert(tx.getInputs().length > 0);
      for (let input of tx.getInputs()) assert(input.getTx() === tx);
    } else {
      assert.equal(tx.getWeight(), undefined);
      assert.equal(tx.getInputs(), undefined);
    }
    
    // test confirmed
    if (tx.isConfirmed()) {
      assert(tx.getBlock());
      assert(tx.getBlock().getTxs().includes(tx));
      assert(tx.getBlock().getHeight() > 0);
      assert(tx.getBlock().getTimestamp() > 0);
      assert.equal(tx.isRelayed(), true);
      assert.equal(tx.isFailed(), false);
      assert.equal(tx.inTxPool(), false);
      assert.equal(tx.getRelay(), true);
      assert.equal(tx.isDoubleSpendSeen(), false);
      assert(tx.getNumConfirmations() > 0);
    } else {
      assert.equal(undefined, tx.getBlock());
      assert.equal(0, tx.getNumConfirmations());
    }
    
    // test in tx pool
    if (tx.inTxPool()) {
      assert.equal(tx.isConfirmed(), false);
      assert.equal(tx.getRelay(), true);
      assert.equal(tx.isRelayed(), true);
      assert.equal(tx.isDoubleSpendSeen(), false); // TODO: test double spend attempt
      assert.equal(tx.isLocked(), true);
      
      // these should be initialized unless a response from sending
      if (!ctx.isSendResponse) {
        //assert(tx.getReceivedTimestamp() > 0);    // TODO: re-enable when received timestamp returned in wallet rpc
      }
    } else {
      assert.equal(tx.getLastRelayedTimestamp(), undefined);
    }
    
    // test miner tx
    if (tx.isMinerTx()) {
      assert.equal(tx.getFee().compare(new BigInteger(0)), 0);
      assert(tx.getIncomingTransfers().length > 0);
    }
    
    // test failed  // TODO: what else to test associated with failed
    if (tx.isFailed()) {
      assert(tx.getOutgoingTransfer() instanceof MoneroTransfer);
      //assert(tx.getReceivedTimestamp() > 0);    // TODO: re-enable when received timestamp returned in wallet rpc
    } else {
      if (tx.isRelayed()) assert.equal(tx.isDoubleSpendSeen(), false);
      else {
        assert.equal(tx.isRelayed(), false);
        assert.notEqual(tx.getRelay(), true);
        assert.equal(tx.isDoubleSpendSeen(), undefined);
      }
    }
    assert.equal(tx.getLastFailedHeight(), undefined);
    assert.equal(tx.getLastFailedHash(), undefined);
    
    // received time only for tx pool or failed txs
    if (tx.getReceivedTimestamp() !== undefined) {
      assert(tx.inTxPool() || tx.isFailed());
    }
    
    // test relayed tx
    if (tx.isRelayed()) assert.equal(tx.getRelay(), true);
    if (tx.getRelay() !== true) assert.equal(tx.isRelayed(), false);
    
    // test outgoing transfer per configuration
    if (ctx.isOutgoing === false) assert(tx.getOutgoingTransfer() === undefined);
    if (ctx.hasDestinations) assert(tx.getOutgoingTransfer() && tx.getOutgoingTransfer().getDestinations().length > 0);  // TODO: this was typo with getDestionations so is this actually being tested?
    
    // test outgoing transfer
    if (tx.getOutgoingTransfer()) {
      assert(tx.isOutgoing());
      await testTransfer(tx.getOutgoingTransfer(), ctx);
      if (ctx.isSweepResponse) assert.equal(tx.getOutgoingTransfer().getDestinations().length, 1);
      
      // TODO: handle special cases
    } else {
      assert(tx.getIncomingTransfers().length > 0);
      assert.equal(tx.getOutgoingAmount(), undefined);
      assert.equal(tx.getOutgoingTransfer(), undefined);
      assert.equal(tx.getRingSize(), undefined);
      assert.equal(tx.getFullHex(), undefined);
      assert.equal(tx.getMetadata(), undefined);
      assert.equal(tx.getKey(), undefined);
    }
    
    // test incoming transfers
    if (tx.getIncomingTransfers()) {
      assert(tx.isIncoming());
      assert(tx.getIncomingTransfers().length > 0);
      TestUtils.testUnsignedBigInteger(tx.getIncomingAmount());      
      assert.equal(tx.isFailed(), false);
      
      // test each transfer and collect transfer sum
      let transferSum = new BigInteger(0);
      for (let transfer of tx.getIncomingTransfers()) {
        await testTransfer(transfer, ctx);
        transferSum = transferSum.add(transfer.getAmount());
        if (ctx.wallet) assert.equal(transfer.getAddress(), await ctx.wallet.getAddress(transfer.getAccountIndex(), transfer.getSubaddressIndex()));
        
        // TODO special case: transfer amount of 0
      }
      
      // incoming transfers add up to incoming tx amount
      assert.equal(transferSum.compare(tx.getIncomingAmount()), 0);
    } else {
      assert(tx.getOutgoingTransfer());
      assert.equal(tx.getIncomingAmount(), undefined);
      assert.equal(tx.getIncomingTransfers(), undefined);
    }
    
    // test tx results from send or relay
    if (ctx.isSendResponse) {
      
      // test tx set
      assert.notEqual(tx.getTxSet(), undefined);
      let found = false;
      for (let aTx of tx.getTxSet().getTxs()) {
        if (aTx === tx) {
          found = true;
          break;
        }
      }
      if (ctx.isCopy) assert(!found); // copy will not have back reference from tx set
      else assert(found);
      
      // test common attributes
      let config = ctx.config;
      assert.equal(tx.isConfirmed(), false);
      await testTransfer(tx.getOutgoingTransfer(), ctx);
      assert.equal(tx.getRingSize(), MoneroUtils.RING_SIZE);
      assert.equal(tx.getUnlockHeight(), config.getUnlockHeight() ? config.getUnlockHeight() : 0);
      assert.equal(tx.getBlock(), undefined);
      assert(tx.getKey().length > 0);
      assert.equal(typeof tx.getFullHex(), "string");
      assert(tx.getFullHex().length > 0);
      assert(tx.getMetadata());
      assert.equal(tx.getReceivedTimestamp(), undefined);
      assert.equal(tx.isLocked(), true);
      
      // test locked state
      if (tx.getUnlockHeight() === 0) assert.equal(!tx.isLocked(), tx.isConfirmed());
      else assert.equal(tx.isLocked(), true);
      if (tx.getOutputs() !== undefined) {
        for (let output of tx.getOutputs()) {
          assert.equal(output.isLocked(), tx.isLocked());
        }
      }
      
      // test destinations of sent tx
      if (tx.getOutgoingTransfer().getDestinations() === undefined) assert(config.getCanSplit()); // TODO: destinations not returned from transfer_split
      else {
        assert.equal(tx.getOutgoingTransfer().getDestinations().length, config.getDestinations().length);
        for (let i = 0; i < config.getDestinations().length; i++) {
          assert.equal(tx.getOutgoingTransfer().getDestinations()[i].getAddress(), config.getDestinations()[i].getAddress());
          if (ctx.isSweepResponse) {
            assert.equal(config.getDestinations().length, 1);
            assert.equal(config.getDestinations()[i].getAmount(), undefined);
            assert.equal(tx.getOutgoingTransfer().getDestinations()[i].getAmount().toString(), tx.getOutgoingTransfer().getAmount().toString());
          } else {
            assert.equal(tx.getOutgoingTransfer().getDestinations()[i].getAmount().toString(), config.getDestinations()[i].getAmount().toString());
          }
        }
      }
      
      // test relayed txs
      if (config.getRelay()) {
        assert.equal(tx.inTxPool(), true);
        assert.equal(tx.getRelay(), true);
        assert.equal(tx.isRelayed(), true);
        assert(tx.getLastRelayedTimestamp() > 0);
        assert.equal(tx.isDoubleSpendSeen(), false);
      }
      
      // test non-relayed txs
      else {
        assert.equal(tx.inTxPool(), false);
        assert.notEqual(tx.getRelay(), true);
        assert.equal(tx.isRelayed(), false);
        assert.equal(tx.getLastRelayedTimestamp(), undefined);
        assert.equal(tx.isDoubleSpendSeen(), undefined);
      }
    }
    
    // test tx result query
    else {
      assert.equal(tx.getTxSet(), undefined);  // tx set only initialized on send responses
      assert.equal(tx.getRingSize(), undefined);
      assert.equal(tx.getKey(), undefined);
      assert.equal(tx.getFullHex(), undefined);
      assert.equal(tx.getMetadata(), undefined);
      assert.equal(tx.getLastRelayedTimestamp(), undefined);
    }
    
    // test inputs
    if (tx.isOutgoing() && ctx.isSendResponse) {
      assert(tx.getInputs() !== undefined);
      assert(tx.getInputs().length > 0);
    } else {
      if (tx.getInputs()) for (let input of tx.getInputs()) testInputWallet(output);
    }
    
    // test outputs
    if (tx.isIncoming() && ctx.includeOutputs) {
      if (tx.isConfirmed()) {
        assert(tx.getOutputs() !== undefined);
        assert(tx.getOutputs().length > 0);
      } else {
        assert(tx.getOutputs() === undefined);
      }

    }
    if (tx.getOutputs()) for (let output of tx.getOutputs()) testOutputWallet(output);
    
    // test deep copy
    if (!ctx.isCopy) await this._testTxWalletCopy(tx, ctx);
  }
  
  // TODO: move below _testTxWalletCopy
  async _testTxWalletCopy(tx, ctx) {
    
    // copy tx and assert deep equality
    let copy = tx.copy();
    assert(copy instanceof MoneroTxWallet);
    assert.deepEqual(copy.toJson(), tx.toJson());
    
    // test different references
    if (tx.getOutgoingTransfer()) {
      assert(tx.getOutgoingTransfer() !== copy.getOutgoingTransfer());
      assert(tx.getOutgoingTransfer().getTx() !== copy.getOutgoingTransfer().getTx());
      //assert(tx.getOutgoingTransfer().getAmount() !== copy.getOutgoingTransfer().getAmount());  // TODO: BI 0 === BI 0?, testing this instead:
      if (tx.getOutgoingTransfer().getAmount() === copy.getOutgoingTransfer().getAmount()) assert(tx.getOutgoingTransfer().getAmount().compare(new BigInteger(0)) === 0);
      if (tx.getOutgoingTransfer().getDestinations()) {
        assert(tx.getOutgoingTransfer().getDestinations() !== copy.getOutgoingTransfer().getDestinations());
        for (let i = 0; i < tx.getOutgoingTransfer().getDestinations().length; i++) {
          assert.deepEqual(copy.getOutgoingTransfer().getDestinations()[i], tx.getOutgoingTransfer().getDestinations()[i]);
          assert(tx.getOutgoingTransfer().getDestinations()[i] !== copy.getOutgoingTransfer().getDestinations()[i]);
          if (tx.getOutgoingTransfer().getDestinations()[i].getAmount() === copy.getOutgoingTransfer().getDestinations()[i].getAmount()) assert(tx.getOutgoingTransfer().getDestinations()[i].getAmount().toJSValue() === 0);
        }
      }
    }
    if (tx.getIncomingTransfers()) {
      for (let i = 0; i < tx.getIncomingTransfers().length; i++) {
        assert.deepEqual(copy.getIncomingTransfers()[i].toJson(), tx.getIncomingTransfers()[i].toJson());
        assert(tx.getIncomingTransfers()[i] !== copy.getIncomingTransfers()[i]);
        if (tx.getIncomingTransfers()[i].getAmount() == copy.getIncomingTransfers()[i].getAmount()) assert(tx.getIncomingTransfers()[i].getAmount().toJSValue() === 0);
      }
    }
    if (tx.getInputs()) {
      for (let i = 0; i < tx.getInputs().length; i++) {
        assert.deepEqual(copy.getInputs()[i].toJson(), tx.getInputs()[i].toJson());
        assert(tx.getInputs()[i] !== copy.getInputs()[i]);
      }
    }
    if (tx.getOutputs()) {
      for (let i = 0; i < tx.getOutputs().length; i++) {
        assert.deepEqual(copy.getOutputs()[i].toJson(), tx.getOutputs()[i].toJson());
        assert(tx.getOutputs()[i] !== copy.getOutputs()[i]);
        if (tx.getOutputs()[i].getAmount() == copy.getOutputs()[i].getAmount()) assert(tx.getOutputs()[i].getAmount().toJSValue() === 0);
      }
    }
    
    // test copied tx
    ctx = Object.assign({}, ctx);
    ctx.isCopy = true;
    if (tx.getBlock()) copy.setBlock(tx.getBlock().copy().setTxs([copy])); // copy block for testing
    await this._testTxWallet(copy, ctx);
    
    // test merging with copy
    let merged = copy.merge(copy.copy());
    assert.equal(merged.toString(), tx.toString());
  }
  
  async _testMultisig(M, N, testTx) {
    
    // create N participants
    let participants = [];
    for (let i = 0; i < N; i++) participants.push(await this.createWallet(new MoneroWalletConfig()));

    // test multisig
    let err;
    try {
      await this._testMultisigParticipants(participants, M, N, testTx);
    } catch (e) {
      err = e;
    }
    
    // stop mining at end of test
    try { await this.daemon.stopMining(); }
    catch (err2) { }
    
    // save and close participants
    for (let participant of participants) await this.closeWallet(participant, true);
    if (err) throw err;
  }
  
  async _testMultisigParticipants(participants, M, N, testTx) {
    console.log("_testMultisig(" + M + ", " + N + ")");
    assert.equal(N, participants.length);
    
    // prepare multisig hexes
    let preparedMultisigHexes = [];
    for (let i = 0; i < N; i++) {
      let participant = participants[i];
      preparedMultisigHexes.push(await participant.prepareMultisig());
    }

    // make wallets multisig
    let madeMultisigHexes = [];
    for (let i = 0; i < participants.length; i++) {
      let participant = participants[i];
      
      // collect prepared multisig hexes from wallet's peers
      let peerMultisigHexes = [];
      for (let j = 0; j < participants.length; j++) if (j !== i) peerMultisigHexes.push(preparedMultisigHexes[j]);

      // test bad input
      try {
        await participant.makeMultisig(["asd", "dsa"], M, TestUtils.WALLET_PASSWORD);
        throw new Error("Should have thrown error making wallet multisig with bad input");
      } catch (err) {
        if (!(err instanceof MoneroError)) throw err;
        assert.equal(err.message, "basic_string"); // TODO (monero-project): improve error message https://github.com/monero-project/monero/issues/8493
      }
      
      // make the wallet multisig
      let multisigHex = await participant.makeMultisig(peerMultisigHexes, M, TestUtils.WALLET_PASSWORD);
      madeMultisigHexes.push(multisigHex);
    }
    
    // exchange keys N - M + 1 times
    let address = undefined;
    assert.equal(madeMultisigHexes.length, N);
    let prevMultisigHexes = madeMultisigHexes;
    for (let i = 0; i < N - M + 1; i++) {
      //console.log("Exchanging multisig keys round " + (i + 1) + " / " + (N - M));
      
      // exchange multisig keys with each wallet and collect results
      let exchangeMultisigHexes = [];
      for (let j = 0; j < participants.length; j++) {
        let participant = participants[j];
        
        // test bad input
        try {
          await participant.exchangeMultisigKeys([], TestUtils.WALLET_PASSWORD);
          throw new Error("Should have thrown error exchanging multisig keys with bad input");
        } catch (err) {
          if (!(err instanceof MoneroError)) throw err;
          assert(err.message.length > 0);
        }
        
        // collect the multisig hexes of the wallet's peers from last round
        let peerMultisigHexes = [];
        for (let k = 0; k < participants.length; k++) if (k !== j) peerMultisigHexes.push(prevMultisigHexes[k]);
        
        // import the multisig hexes of the wallet's peers
        let result = await participant.exchangeMultisigKeys(peerMultisigHexes, TestUtils.WALLET_PASSWORD);
        
        // test result
        assert.notEqual(result.getMultisigHex(), undefined);
        assert(result.getMultisigHex().length > 0);
        if (i === N - M) {  // result on last round has address
          assert.notEqual(result.getAddress(), undefined);
          assert(result.getAddress().length > 0);
          if (address === undefined) address = result.getAddress();
          else assert.equal(result.getAddress(), address);
        } else {
          assert.equal(result.getAddress(), undefined);
          exchangeMultisigHexes.push(result.getMultisigHex());
        }
      }
      
      // use results for next round of exchange
      prevMultisigHexes = exchangeMultisigHexes;
    }
    
    // validate final multisig address
    let participant = participants[0];
    await MoneroUtils.validateAddress(await participant.getPrimaryAddress(), TestUtils.NETWORK_TYPE);
    this._testMultisigInfo(await participant.getMultisigInfo(), M, N);
    
    // test sending a multisig transaction if configured
    if (testTx) {
      
      // create an account in the first multisig wallet to receive funds to
      await participant.createAccount();
      
      // get destinations to subaddresses within the account of the multisig wallet
      let accountIdx = 1;
      let destinations = [];
      for (let i = 0; i < 3; i++) {
        await participant.createSubaddress(accountIdx);
        destinations.push(new MoneroDestination(await participant.getAddress(accountIdx, i), TestUtils.MAX_FEE.multiply(new BigInteger(2))));
      }
      
      // wait for txs to confirm and for sufficient unlocked balance
      await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(this.wallet);
      await TestUtils.WALLET_TX_TRACKER.waitForUnlockedBalance(this.wallet, 0, undefined, TestUtils.MAX_FEE.multiply(BigInteger.parse("20"))); 
      
      // send funds from the main test wallet to destinations in the first multisig wallet
      assert((await this.wallet.getBalance()).compare(new BigInteger(0)) > 0);
      console.log("Sending funds from main wallet");
      await this.wallet.createTx({accountIndex: 0, destinations: destinations, relay: true});
      let returnAddress = await this.wallet.getPrimaryAddress(); // funds will be returned to this address from the multisig wallet
      
      console.log("Starting mining");
      
      // start mining to push the network along
      await StartMining.startMining();
      
      // wait for the multisig wallet's funds to unlock // TODO: replace with MoneroWalletListener.onOutputReceived() which is called when output unlocked
      let lastNumConfirmations = undefined;
      while (true) {
        
        // wait for a moment
        await new Promise(function(resolve) { setTimeout(resolve, TestUtils.SYNC_PERIOD_IN_MS); });
        
        // fetch and test outputs
        let outputs = await participant.getOutputs();
        if (outputs.length === 0) console.log("No outputs reported yet");
        else {
          
          // print num confirmations
          let height = await this.daemon.getHeight();
          let numConfirmations = height - outputs[0].getTx().getHeight();
          if (lastNumConfirmations === undefined || lastNumConfirmations !== numConfirmations) console.log("Output has " + (height - outputs[0].getTx().getHeight()) + " confirmations");
          lastNumConfirmations = numConfirmations;
          
          // outputs are not spent
          for (let output of outputs) assert(output.isSpent() === false);
          
          // break if output is unlocked
          if (!outputs[0].isLocked()) break;
        }
      }
      
      // stop mining
      await this.daemon.stopMining();
      
      // multisig wallet should have unlocked balance in account 1 subaddresses 0-3
      for (let i = 0; i < 3; i++) {
        assert((await participant.getUnlockedBalance(1, i)).compare(BigInteger.parse("0")) > 0);
      }
      let outputs = await participant.getOutputs({accountIndex: 1});
      assert(outputs.length > 0);
      if (outputs.length < 3) console.log("WARNING: not one output per subaddress?");
      //assert(outputs.length >= 3);  // TODO
      for (let output of outputs) assert.equal(output.isLocked(), false);
      
      // wallet requires importing multisig to be reliable
      assert(await participant.isMultisigImportNeeded());
      
      // attempt creating and relaying transaction without synchronizing with participants
      try {
        await participant.createTx({accountIndex: 1, address: returnAddress, amount: TestUtils.MAX_FEE.multiply(new BigInteger(3))});
        throw new Error("Should have failed sending funds without synchronizing with peers");
      } catch (e) {
        assert.equal(e.message, "No transaction created");
      }
      
      // synchronize the multisig participants since receiving outputs
      console.log("Synchronizing participants");
      await this._synchronizeMultisigParticipants(participants);
      
      // attempt relaying created transactions without co-signing
      try {
        await participant.createTxs({address: returnAddress, amount: TestUtils.MAX_FEE, accountIndex: 1, subaddressIndex: 0, relay: true});
        throw new Error("Should have failed");
      } catch (e) {
        assert.equal(e.message, "Cannot relay multisig transaction until co-signed");
      }
      
      // send funds from a subaddress in the multisig wallet
      console.log("Sending");
      let txs = await participant.createTxs({address: returnAddress, amount: TestUtils.MAX_FEE, accountIndex: 1, subaddressIndex: 0});
      assert(txs.length > 0);
      let txSet = txs[0].getTxSet();
      assert.notEqual(txSet.getMultisigTxHex(), undefined);
      assert.equal(txSet.getSignedTxHex(), undefined);
      assert.equal(txSet.getUnsignedTxHex(), undefined);
      
      // parse multisig tx hex and test
      await testDescribedTxSet(await participant.describeMultisigTxSet(txSet.getMultisigTxHex()));
      
      // sign the tx with participants 1 through M - 1 to meet threshold
      let multisigTxHex = txSet.getMultisigTxHex();
      console.log("Signing");
      for (let i = 1; i < M; i++) {
        let result = await participants[i].signMultisigTxHex(multisigTxHex);
        multisigTxHex = result.getSignedMultisigTxHex();
      }
      
      //console.log("Submitting signed multisig tx hex: " + multisigTxHex);
      
      // submit the signed multisig tx hex to the network
      console.log("Submitting");
      let txHashes = await participant.submitMultisigTxHex(multisigTxHex);
      
      // synchronize the multisig participants since spending outputs
      console.log("Synchronizing participants");
      await this._synchronizeMultisigParticipants(participants);
      
      // fetch the wallet's multisig txs
      let multisigTxs = await participant.getTxs({hashes: txHashes});
      assert.equal(txHashes.length, multisigTxs.length);
      
      // sweep an output from subaddress [1,1]
      outputs = await participant.getOutputs({accountIndex: 1, subaddressIndex: 1});
      assert(outputs.length > 0);
      assert(outputs[0].isSpent() === false);
      txSet = (await participant.sweepOutput({address: returnAddress, keyImage: outputs[0].getKeyImage().getHex(), relay: true})).getTxSet();
      assert.notEqual(txSet.getMultisigTxHex(), undefined);
      assert.equal(txSet.getSignedTxHex(), undefined);
      assert.equal(txSet.getUnsignedTxHex(), undefined);
      assert(txSet.getTxs().length > 0);
      
      // parse multisig tx hex and test
      await testDescribedTxSet(await participant.describeMultisigTxSet(txSet.getMultisigTxHex()));
      
      // sign the tx with participants 1 through M - 1 to meet threshold
      multisigTxHex = txSet.getMultisigTxHex();
      console.log("Signing sweep output");
      for (let i = 1; i < M; i++) {
        let result = await participants[i].signMultisigTxHex(multisigTxHex);
        multisigTxHex = result.getSignedMultisigTxHex();
      }
      
      // submit the signed multisig tx hex to the network
      console.log("Submitting sweep output");
      txHashes = await participant.submitMultisigTxHex(multisigTxHex);
      
      // synchronize the multisig participants since spending outputs
      console.log("Synchronizing participants");
      await this._synchronizeMultisigParticipants(participants);
      
      // fetch the wallet's multisig txs
      multisigTxs = await participant.getTxs({hashes: txHashes});
      assert.equal(txHashes.length, multisigTxs.length);
      
      // sweep remaining balance
      console.log("Sweeping");
      txs = await participant.sweepUnlocked({address: returnAddress, accountIndex: 1, relay: true}); // TODO: test multisig with sweepEachSubaddress which will generate multiple tx sets without synchronizing participants
      assert(txs.length > 0, "No txs created on sweepUnlocked");
      txSet = txs[0].getTxSet();
      for (let tx of txs) {
        assert(tx.getTxSet() === txSet);  // only one tx set created per account
        let found = false;
          for (let aTx of tx.getTxSet().getTxs()) {
          if (aTx === tx) {
            found = true;
            break;
          }
        }
        assert(found);  // tx is contained in tx set
      }
      assert.notEqual(txSet.getMultisigTxHex(), undefined);
      assert.equal(txSet.getSignedTxHex(), undefined);
      assert.equal(txSet.getUnsignedTxHex(), undefined);
      
      // parse multisig tx hex and test
      await testDescribedTxSet(await participant.describeTxSet(txSet));
      
      // sign the tx with participants 1 through M - 1 to meet threshold
      multisigTxHex = txSet.getMultisigTxHex();
      console.log("Signing sweep");
      for (let i = 1; i < M; i++) {
        let result = await participants[i].signMultisigTxHex(multisigTxHex);
        multisigTxHex = result.getSignedMultisigTxHex();
      }
      
      // submit the signed multisig tx hex to the network
      console.log("Submitting sweep");
      txHashes = await participant.submitMultisigTxHex(multisigTxHex);
      
      // synchronize the multisig participants since spending outputs
      console.log("Synchronizing participants");
      await this._synchronizeMultisigParticipants(participants);
      
      // fetch the wallet's multisig txs
      multisigTxs = await participant.getTxs({hashes: txHashes});
      assert.equal(txHashes.length, multisigTxs.length);
    }
  }
  
  async _synchronizeMultisigParticipants(wallets) {
    
    // collect multisig hex of all participants to synchronize
    let multisigHexes = [];
    for (let wallet of wallets) {
      await wallet.sync();
      multisigHexes.push(await wallet.exportMultisigHex());
    }
    
    // import each wallet's peer multisig hex 
    for (let i = 0; i < wallets.length; i++) {
      let peerMultisigHexes = [];
      for (let j = 0; j < wallets.length; j++) if (j !== i) peerMultisigHexes.push(multisigHexes[j]);
      let wallet = wallets[i];
      await wallet.sync();
      await wallet.importMultisigHex(peerMultisigHexes);
    }
  }
  
  async _testMultisigInfo(info, M, N) {
    assert(info.isMultisig());
    assert(info.isReady());
    assert.equal(info.getThreshold(), M);
    assert.equal(info.getNumParticipants(), N);
  }
  
  async _testViewOnlyAndOfflineWallets(viewOnlyWallet, offlineWallet) {
    
    // wait for txs to confirm and for sufficient unlocked balance
    await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(this.wallet);
    await TestUtils.WALLET_TX_TRACKER.waitForUnlockedBalance(this.wallet, 0, undefined, TestUtils.MAX_FEE.multiply(BigInteger.parse("4")));
    
    // test getting txs, transfers, and outputs from view-only wallet
    assert((await viewOnlyWallet.getTxs()).length, "View-only wallet has no transactions");
    assert((await viewOnlyWallet.getTransfers()).length, "View-only wallet has no transfers");
    assert((await viewOnlyWallet.getOutputs()).length, "View-only wallet has no outputs");
    
    // collect info from main test wallet
    let primaryAddress = await this.wallet.getPrimaryAddress();
    let privateViewKey = await this.wallet.getPrivateViewKey();
    
    // test and sync view-only wallet
    assert.equal(await viewOnlyWallet.getPrimaryAddress(), primaryAddress);
    assert.equal(await viewOnlyWallet.getPrivateViewKey(), privateViewKey);
    assert.equal(await viewOnlyWallet.getPrivateSpendKey(), undefined);
    assert.equal(await viewOnlyWallet.getMnemonic(), undefined);
    assert.equal(await viewOnlyWallet.getMnemonicLanguage(), undefined);
    assert(await viewOnlyWallet.isViewOnly());
    assert(await viewOnlyWallet.isConnectedToDaemon(), "Wallet created from keys is not connected to authenticated daemon");  // TODO
    assert.equal(await viewOnlyWallet.getMnemonic(), undefined);
    await viewOnlyWallet.sync();
    assert((await viewOnlyWallet.getTxs()).length > 0);
    
    // export outputs from view-only wallet
    let outputsHex = await viewOnlyWallet.exportOutputs();
    
    // test offline wallet
    assert(!await offlineWallet.isConnectedToDaemon());
    assert(!await offlineWallet.isViewOnly());
    if (!(offlineWallet instanceof MoneroWalletRpc)) assert.equal(await offlineWallet.getMnemonic(), TestUtils.MNEMONIC); // TODO monero-project: cannot get mnemonic from offline wallet rpc
    assert.equal((await offlineWallet.getTxs()).length, 0);
    
    // import outputs to offline wallet
    let numOutputsImported = await offlineWallet.importOutputs(outputsHex);
    assert(numOutputsImported > 0, "No outputs imported");
    
    // export key images from offline wallet
    let keyImages = await offlineWallet.exportKeyImages();
    assert(keyImages.length > 0);
    
    // import key images to view-only wallet
    assert(await viewOnlyWallet.isConnectedToDaemon());
    await viewOnlyWallet.importKeyImages(keyImages);
    assert.equal((await viewOnlyWallet.getBalance()).toString(), (await this.wallet.getBalance()).toString());
    
    // create unsigned tx using view-only wallet
    let unsignedTx = await viewOnlyWallet.createTx({accountIndex: 0, address: primaryAddress, amount: TestUtils.MAX_FEE.multiply(BigInteger.parse("3"))});
    assert.equal(typeof unsignedTx.getTxSet().getUnsignedTxHex(), "string");
    assert(unsignedTx.getTxSet().getUnsignedTxHex());
    
    // sign tx using offline wallet
    let signedTxHex = await offlineWallet.signTxs(unsignedTx.getTxSet().getUnsignedTxHex());
    assert(signedTxHex.length > 0);
    
    // parse or "describe" unsigned tx set
    let describedTxSet = await offlineWallet.describeUnsignedTxSet(unsignedTx.getTxSet().getUnsignedTxHex());
    await testDescribedTxSet(describedTxSet);
    
    // submit signed tx using view-only wallet
    if (this.testConfig.testRelays) {
      let txHashes = await viewOnlyWallet.submitTxs(signedTxHex);
      assert.equal(txHashes.length, 1);
      assert.equal(txHashes[0].length, 64);
      await TestUtils.WALLET_TX_TRACKER.waitForWalletTxsToClearPool(viewOnlyWallet); // wait for confirmation for other tests
    }
  }
  
  _testInvalidAddressError(err) {
    assert.equal("Invalid address", err.message);
  }
  
  _testInvalidTxHashError(err) {
    assert.equal("TX hash has invalid format", err.message);
  }
  
  _testInvalidTxKeyError(err) {
    assert.equal("Tx key has invalid format", err.message);
  }
  
  _testInvalidSignatureError(err) {
    assert.equal("Signature size mismatch with additional tx pubkeys", err.message);
  }
  
  _testNoSubaddressError(err) {
    assert.equal("Address must not be a subaddress", err.message);
  }
  
  _testSignatureHeaderCheckError(err) {
    assert.equal("Signature header check error", err.message);
  }
}

// ------------------------------ PRIVATE STATIC ------------------------------
  
async function testAccount(account) {
  
  // test account
  assert(account);
  assert(account.getIndex() >= 0);
  await MoneroUtils.validateAddress(account.getPrimaryAddress(), TestUtils.NETWORK_TYPE);
  TestUtils.testUnsignedBigInteger(account.getBalance());
  TestUtils.testUnsignedBigInteger(account.getUnlockedBalance());
  
  // if given, test subaddresses and that their balances add up to account balances
  if (account.getSubaddresses()) {
    let balance = new BigInteger(0);
    let unlockedBalance = new BigInteger(0);
    for (let i = 0; i < account.getSubaddresses().length; i++) {
      testSubaddress(account.getSubaddresses()[i]);
      assert.equal(account.getSubaddresses()[i].getAccountIndex(), account.getIndex());
      assert.equal(account.getSubaddresses()[i].getIndex(), i);
      balance = balance.add(account.getSubaddresses()[i].getBalance());
      unlockedBalance = unlockedBalance.add(account.getSubaddresses()[i].getUnlockedBalance());
    }
    assert(account.getBalance().compare(balance) === 0, "Subaddress balances " + balance.toString() + " != account " + account.getIndex() + " balance " + account.getBalance().toString());
    assert(account.getUnlockedBalance().compare(unlockedBalance) === 0, "Subaddress unlocked balances " + unlockedBalance.toString() + " != account " + account.getIndex() + " unlocked balance " + account.getUnlockedBalance().toString());
  }
  
  // tag must be undefined or non-empty
  let tag = account.getTag();
  assert(tag === undefined || tag.length > 0);
}

function testSubaddress(subaddress) {
  assert(subaddress.getAccountIndex() >= 0);
  assert(subaddress.getIndex() >= 0);
  assert(subaddress.getAddress());
  assert(subaddress.getLabel() === undefined || typeof subaddress.getLabel() === "string");
  if (typeof subaddress.getLabel() === "string") assert(subaddress.getLabel().length > 0);
  TestUtils.testUnsignedBigInteger(subaddress.getBalance());
  TestUtils.testUnsignedBigInteger(subaddress.getUnlockedBalance());
  assert(subaddress.getNumUnspentOutputs() >= 0);
  assert(typeof subaddress.isUsed() === "boolean");
  if (subaddress.getBalance().compare(new BigInteger(0)) > 0) assert(subaddress.isUsed());
  assert(subaddress.getNumBlocksToUnlock() >= 0);
}

/**
 * Gets random transactions.
 * 
 * @param wallet is the wallet to query for transactions
 * @param query configures the transactions to retrieve
 * @param minTxs specifies the minimum number of transactions (undefined for no minimum)
 * @param maxTxs specifies the maximum number of transactions (undefined for all filtered transactions)
 * @return {MoneroTxWallet[]} are the random transactions
 */
async function getRandomTransactions(wallet, query, minTxs, maxTxs) {
  let txs = await wallet.getTxs(query);
  if (minTxs !== undefined) assert(txs.length >= minTxs, txs.length + "/" + minTxs + " transactions found with query: " + JSON.stringify(query));
  GenUtils.shuffle(txs);
  if (maxTxs === undefined) return txs;
  else return txs.slice(0, Math.min(maxTxs, txs.length));
}

async function testTransfer(transfer, ctx) {
  if (ctx === undefined) ctx = {};
  assert(transfer instanceof MoneroTransfer);
  TestUtils.testUnsignedBigInteger(transfer.getAmount());
  if (!ctx.isSweepOutputResponse) assert(transfer.getAccountIndex() >= 0);
  if (transfer.isIncoming()) testIncomingTransfer(transfer);
  else await testOutgoingTransfer(transfer, ctx);
  
  // transfer and tx reference each other
  assert(transfer.getTx());
  if (transfer !== transfer.getTx().getOutgoingTransfer()) {
    assert(transfer.getTx().getIncomingTransfers());
    assert(transfer.getTx().getIncomingTransfers().includes(transfer), "Transaction does not reference given transfer");
  }
}

function testIncomingTransfer(transfer) {
  assert(transfer.isIncoming());
  assert(!transfer.isOutgoing());
  assert(transfer.getAddress());
  assert(transfer.getSubaddressIndex() >= 0);
  assert(transfer.getNumSuggestedConfirmations() > 0);
}

async function testOutgoingTransfer(transfer, ctx) {
  assert(!transfer.isIncoming());
  assert(transfer.isOutgoing());
  if (!ctx.isSendResponse) assert(transfer.getSubaddressIndices());
  if (transfer.getSubaddressIndices()) {
    assert(transfer.getSubaddressIndices().length >= 1);
    for (let subaddressIdx of transfer.getSubaddressIndices()) assert(subaddressIdx >= 0);
  }
  if (transfer.getAddresses()) {
    assert.equal(transfer.getAddresses().length, transfer.getSubaddressIndices().length);
    for (let address of transfer.getAddresses()) assert(address);
  }
  
  // test destinations sum to outgoing amount
  if (transfer.getDestinations()) {
    assert(transfer.getDestinations().length > 0);
    let sum = new BigInteger(0);
    for (let destination of transfer.getDestinations()) {
      await testDestination(destination);
      TestUtils.testUnsignedBigInteger(destination.getAmount(), true);
      sum = sum.add(destination.getAmount());
    }
    if (transfer.getAmount().compare(sum) !== 0) console.log(transfer.getTx().getTxSet() === undefined ? transfer.getTx().toString() : transfer.getTx().getTxSet().toString());
    assert.equal(sum.toString(), transfer.getAmount().toString()); // TODO: sum of destinations != outgoing amount in split txs
  }
}

async function testDestination(destination) {
  await MoneroUtils.validateAddress(destination.getAddress(), TestUtils.NETWORK_TYPE);
  TestUtils.testUnsignedBigInteger(destination.getAmount(), true);
}

function testInputWallet(input) {
  assert(input);
  assert(input.getKeyImage());
  assert(input.getKeyImage().getHex());
  assert(input.getKeyImage().getHex().length > 0);
  assert(input.getAmount() === undefined); // must get info separately
}

function testOutputWallet(output) {
  assert(output);
  assert(output instanceof MoneroOutputWallet);
  assert(output.getAccountIndex() >= 0);
  assert(output.getSubaddressIndex() >= 0);
  assert(output.getIndex() >= 0);
  assert.equal(typeof output.isSpent(), "boolean");
  assert.equal(typeof output.isLocked(), "boolean");
  assert.equal(typeof output.isFrozen(), "boolean");
  assert(output.getKeyImage());
  assert(output.getKeyImage() instanceof MoneroKeyImage);
  assert(output.getKeyImage().getHex());
  TestUtils.testUnsignedBigInteger(output.getAmount(), true);
  
  // output has circular reference to its transaction which has some initialized fields
  let tx = output.getTx();
  assert(tx);
  assert(tx instanceof MoneroTxWallet);
  assert(tx.getOutputs().includes(output));
  assert(tx.getHash());
  assert.equal(typeof tx.isLocked(), "boolean");
  assert.equal(tx.isConfirmed(), true);  // TODO monero-wallet-rpc: possible to get unconfirmed outputs?
  assert.equal(tx.isRelayed(), true);
  assert.equal(tx.isFailed(), false);
  assert(tx.getHeight() > 0);
  
  // test copying
  let copy = output.copy();
  assert(copy !== output);
  assert.equal(copy.toString(), output.toString());
  assert.equal(copy.getTx(), undefined);  // TODO: should output copy do deep copy of tx so models are graph instead of tree?  Would need to work out circular references
}

function testCommonTxSets(txs, hasSigned, hasUnsigned, hasMultisig) {
  assert(txs.length > 0);
  
  // assert that all sets are same reference
  let set;
  for (let i = 0; i < txs.length; i++) {
    assert(txs[i] instanceof MoneroTx);
    if (i === 0) set = txs[i].getTxSet();
    else assert(txs[i].getTxSet() === set);
  }
  
  // test expected set
  assert(set);
  if (hasSigned) {
    assert(set.getSignedTxSet());
    assert(set.getSignedTxSet().length > 0);
  }
  if (hasUnsigned) {
    assert(set.getUnsignedTxSet());
    assert(set.getUnsignedTxSet().length > 0);
  }
  if (hasMultisig) {
    assert(set.getMultisigTxSet());
    assert(set.getMultisigTxSet().length > 0);
  }
}

function testCheckTx(tx, check) {
  assert.equal(typeof check.isGood(), "boolean");
  if (check.isGood()) {
    assert(check.getNumConfirmations() >= 0);
    assert.equal(typeof check.inTxPool(), "boolean");
    TestUtils.testUnsignedBigInteger(check.getReceivedAmount());
    if (check.inTxPool()) assert.equal(0, check.getNumConfirmations());
    else assert(check.getNumConfirmations() > 0); // TODO (monero-wall-rpc) this fails (confirmations is 0) for (at least one) transaction that has 1 confirmation on testCheckTxKey()
  } else {
    assert.equal(check.getNumConfirmations(), undefined);
    assert.equal(check.inTxPool(), undefined);
    assert.equal(check.getReceivedAmount(), undefined);
  }
}

function testCheckReserve(check) {
  assert.equal(typeof check.isGood(), "boolean");
  if (check.isGood()) {
    TestUtils.testUnsignedBigInteger(check.getTotalAmount());
    assert(check.getTotalAmount().compare(new BigInteger(0)) >= 0);
    TestUtils.testUnsignedBigInteger(check.getUnconfirmedSpentAmount());
    assert(check.getUnconfirmedSpentAmount().compare(new BigInteger(0)) >= 0);
  } else {
    assert.equal(check.getTotalAmount(), undefined);
    assert.equal(check.getUnconfirmedSpentAmount(), undefined);
  }
}

async function testDescribedTxSet(describedTxSet) {
  assert.notEqual(describedTxSet, undefined);
  assert(describedTxSet.getTxs().length > 0);
  assert.equal(describedTxSet.getSignedTxHex(), undefined);
  assert.equal(describedTxSet.getUnsignedTxHex(), undefined);
  
  // test each transaction        
  // TODO: use common tx wallet test?
  assert.equal(describedTxSet.getMultisigTxHex(), undefined);
  for (let describedTx of describedTxSet.getTxs()) {
    assert(describedTx.getTxSet() === describedTxSet);
    TestUtils.testUnsignedBigInteger(describedTx.getInputSum(), true);
    TestUtils.testUnsignedBigInteger(describedTx.getOutputSum(), true);
    TestUtils.testUnsignedBigInteger(describedTx.getFee());
    TestUtils.testUnsignedBigInteger(describedTx.getChangeAmount());
    if (describedTx.getChangeAmount().compare(new BigInteger(0)) === 0) assert.equal(describedTx.getChangeAddress(), undefined);
    else await MoneroUtils.validateAddress(describedTx.getChangeAddress(), TestUtils.NETWORK_TYPE);
    assert(describedTx.getRingSize() > 1);
    assert(describedTx.getUnlockHeight() >= 0);
    assert(describedTx.getNumDummyOutputs() >= 0);
    assert(describedTx.getExtraHex());
    assert(describedTx.getPaymentId() === undefined || describedTx.getPaymentId().length > 0);
    assert(describedTx.isOutgoing());
    assert.notEqual(describedTx.getOutgoingTransfer(), undefined);
    assert.notEqual(describedTx.getOutgoingTransfer().getDestinations(), undefined);
    assert(describedTx.getOutgoingTransfer().getDestinations().length > 0);
    assert.equal(describedTx.isIncoming(), undefined);
    for (let destination of describedTx.getOutgoingTransfer().getDestinations()) {
      await testDestination(destination);
    }
  }
}

async function testAddressBookEntry(entry) {
  assert(entry.getIndex() >= 0);
  await MoneroUtils.validateAddress(entry.getAddress(), TestUtils.NETWORK_TYPE);
  assert.equal(typeof entry.getDescription(), "string");
}

/**
 * Tests the integrity of the full structure in the given txs from the block down
 * to transfers / destinations.
 */
function testGetTxsStructure(txs, query = undefined) {
  
  // normalize query
  if (query === undefined) query = new MoneroTxQuery();
  if (!(query instanceof MoneroTxQuery)) query = new MoneroTxQuery(query);
  
  // collect unique blocks in order (using set and list instead of TreeSet for direct portability to other languages)
  let seenBlocks = new Set();
  let blocks = [];
  let unconfirmedTxs = [];
  for (let tx of txs) {
    if (tx.getBlock() === undefined) unconfirmedTxs.push(tx);
    else {
      assert(tx.getBlock().getTxs().includes(tx));
      if (!seenBlocks.has(tx.getBlock())) {
        seenBlocks.add(tx.getBlock());
        blocks.push(tx.getBlock());
      }
    }
  }
  
  // tx hashes must be in order if requested
  if (query.getHashes() !== undefined) {
    assert.equal(txs.length, query.getHashes().length);
    for (let i = 0; i < query.getHashes().length; i++) {
      assert.equal(txs[i].getHash(), query.getHashes()[i]);
    }
  }
  
  // test that txs and blocks reference each other and blocks are in ascending order unless specific tx hashes requested
  let index = 0;
  let prevBlockHeight = undefined;
  for (let block of blocks) {
    if (prevBlockHeight === undefined) prevBlockHeight = block.getHeight();
    else if (query.getHashes() === undefined) assert(block.getHeight() > prevBlockHeight, "Blocks are not in order of heights: " + prevBlockHeight + " vs " + block.getHeight());
    for (let tx of block.getTxs()) {
      assert(tx.getBlock() === block);
      if (query.getHashes() === undefined) { 
        assert.equal(tx.getHash(), txs[index].getHash()); // verify tx order is self-consistent with blocks unless txs manually re-ordered by requesting by hash
        assert(tx === txs[index]);
      }
      index++;
    }
  }
  assert.equal(index + unconfirmedTxs.length, txs.length);
  
  // test that incoming transfers are in order of ascending accounts and subaddresses
  for (let tx of txs) {
    let prevAccountIdx = undefined;
    let prevSubaddressIdx = undefined;
    if (tx.getIncomingTransfers() === undefined) continue;
    for (let transfer of tx.getIncomingTransfers()) {
      if (prevAccountIdx === undefined) prevAccountIdx = transfer.getAccountIndex();
      else {
        assert(prevAccountIdx <= transfer.getAccountIndex());
        if (prevAccountIdx < transfer.getAccountIndex()) {
          prevSubaddressIdx = undefined;
          prevAccountIdx = transfer.getAccountIndex();
        }
        if (prevSubaddressIdx === undefined) prevSubaddressIdx = transfer.getSubaddressIndex();
        else assert(prevSubaddressIdx < transfer.getSubaddressIndex());
      }
    }
  }
}

function countNumInstances(instances) {
  let counts = new Map();
  for (let instance of instances) {
    let count = counts.get(instance);
    counts.set(instance, count === undefined ? 1 : count + 1);
  }
  return counts;
}

function getModes(counts) {
  let modes = new Set();
  let maxCount;
  for (let key of counts.keys()) {
    let count = counts.get(key);
    if (maxCount === undefined || count > maxCount) maxCount = count;
  }
  for (let key of counts.keys()) {
    let count = counts.get(key);
    if (count === maxCount) modes.add(key);
  }
  return modes;
}

/**
 * Internal tester for output notifications.
 */
class ReceivedOutputNotificationTester extends MoneroWalletListener {

  constructor(txHash) {
    super();
    this.txHash = txHash;
    this.testComplete = false;
    this.unlockedSeen = false;
  }
  
  onNewBlock(height) {
    this.lastOnNewBlockHeight = height;
  }
  
  onBalancesChanged(newBalance, newUnlockedBalance) {
    this.lastOnBalancesChangedBalance = newBalance;
    this.lastOnBalancesChangedUnlockedBalance = newUnlockedBalance;
  }
  
  onOutputReceived(output) {
    if (output.getTx().getHash() === this.txHash) this.lastNotifiedOutput = output;
  }
}

/**
 * Wallet listener to collect output notifications.
 */
class WalletNotificationCollector extends MoneroWalletListener {
  
  constructor() {
    super();
    this.listening = true;
    this.blockNotifications = [];
    this.balanceNotifications = [];
    this.outputsReceived = [];
    this.outputsSpent = [];
  }
  
  onNewBlock(height) {
    assert(this.listening);
    if (this.blockNotifications.length > 0) assert(height === this.blockNotifications[this.blockNotifications.length - 1] + 1);
    this.blockNotifications.push(height);
  }
  
  onBalancesChanged(newBalance, newUnlockedBalance) {
    assert(this.listening);
    if (this.balanceNotifications.length > 0) {
      this.lastNotification = this.balanceNotifications[this.balanceNotifications.length - 1];
      assert(newBalance.toString() !== this.lastNotification.balance.toString() || newUnlockedBalance.toString() !== this.lastNotification.unlockedBalance.toString());
    }
    this.balanceNotifications.push({balance: newBalance, unlockedBalance: newUnlockedBalance});
  }
  
  onOutputReceived(output) {
    assert(this.listening);
    this.outputsReceived.push(output);
  }
  
  onOutputSpent(output) {
    assert(this.listening);
    this.outputsSpent.push(output);
  }
  
  getBlockNotifications() {
    return this.blockNotifications;
  }
  
  getBalanceNotifications() {
    return this.balanceNotifications;
  }
  
  getOutputsReceived(query) {
    return Filter.apply(query, this.outputsReceived);
  }
  
  getOutputsSpent(query) {
    return Filter.apply(query, this.outputsSpent);
  }
  
  setListening(listening) {
    this.listening = listening;
  }
}

module.exports = TestMoneroWalletCommon;