const assert = require("assert");
const BigInteger = require("../common/biginteger").BigInteger;
const GenUtils = require("../common/GenUtils");
const LibraryUtils = require("../common/LibraryUtils");
const TaskLooper = require("../common/TaskLooper");
const MoneroAccount = require("./model/MoneroAccount");
const MoneroAccountTag = require("./model/MoneroAccountTag");
const MoneroAddressBookEntry = require("./model/MoneroAddressBookEntry");
const MoneroBlock = require("../daemon/model/MoneroBlock");
const MoneroBlockHeader = require("../daemon/model/MoneroBlockHeader");
const MoneroCheckReserve = require("./model/MoneroCheckReserve");
const MoneroCheckTx = require("./model/MoneroCheckTx");
const MoneroDestination = require("./model/MoneroDestination");
const MoneroError = require("../common/MoneroError");
const MoneroIncomingTransfer = require("./model/MoneroIncomingTransfer");
const MoneroIntegratedAddress = require("./model/MoneroIntegratedAddress");
const MoneroKeyImage = require("../daemon/model/MoneroKeyImage");
const MoneroKeyImageImportResult = require("./model/MoneroKeyImageImportResult");
const MoneroMultisigInfo = require("./model/MoneroMultisigInfo");
const MoneroMultisigInitResult = require("./model/MoneroMultisigInitResult");
const MoneroMultisigSignResult = require("./model/MoneroMultisigSignResult");
const MoneroOutgoingTransfer = require("./model/MoneroOutgoingTransfer");
const MoneroOutputQuery = require("./model/MoneroOutputQuery");
const MoneroOutputWallet = require("./model/MoneroOutputWallet");
const MoneroRpcConnection = require("../common/MoneroRpcConnection");
const MoneroRpcError = require("../common/MoneroRpcError");
const MoneroSubaddress = require("./model/MoneroSubaddress");
const MoneroSyncResult = require("./model/MoneroSyncResult");
const MoneroTransferQuery = require("./model/MoneroTransferQuery");
const MoneroTxConfig = require("./model/MoneroTxConfig");
const MoneroTxQuery = require("./model/MoneroTxQuery");
const MoneroTxSet = require("./model/MoneroTxSet");
const MoneroTxWallet = require("./model/MoneroTxWallet");
const MoneroUtils = require("../common/MoneroUtils");
const MoneroVersion = require("../daemon/model/MoneroVersion");
const MoneroWallet = require("./MoneroWallet");
const MoneroWalletConfig = require("./model/MoneroWalletConfig");
const MoneroWalletListener = require("./model/MoneroWalletListener");
const MoneroMessageSignatureType = require("./model/MoneroMessageSignatureType");
const MoneroMessageSignatureResult = require("./model/MoneroMessageSignatureResult");
const ThreadPool = require("../common/ThreadPool");
const SslOptions = require("../common/SslOptions");

/**
 * Copyright (c) woodser
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/**
 * Implements a MoneroWallet as a client of monero-wallet-rpc.
 * 
 * @implements {MoneroWallet}
 * @hideconstructor
 */
class MoneroWalletRpc extends MoneroWallet {
  
  /**
   * <p>Construct a wallet RPC client (for internal use).</p>
   * 
   * @param {string|object|MoneroRpcConnection|string[]} uriOrConfig - uri of monero-wallet-rpc or JS config object or MoneroRpcConnection or command line parameters to run a monero-wallet-rpc process internally
   * @param {string} uriOrConfig.uri - uri of monero-wallet-rpc
   * @param {string} uriOrConfig.username - username to authenticate with monero-wallet-rpc (optional)
   * @param {string} uriOrConfig.password - password to authenticate with monero-wallet-rpc (optional)
   * @param {boolean} uriOrConfig.rejectUnauthorized - rejects self-signed certificates if true (default true)
   * @param {string} username - username to authenticate with monero-wallet-rpc (optional)
   * @param {string} password - password to authenticate with monero-wallet-rpc (optional)
   * @param {boolean} rejectUnauthorized - rejects self-signed certificates if true (default true)
   */
  constructor(uriOrConfig, username, password, rejectUnauthorized) {
    super();
    if (GenUtils.isArray(uriOrConfig)) throw new MoneroError("Array with command parameters is invalid first parameter, use `await monerojs.connectToWalletRpc(...)`");
    this.config = MoneroWalletRpc._normalizeConfig(uriOrConfig, username, password, rejectUnauthorized);
    this.rpc = new MoneroRpcConnection(this.config);
    this.addressCache = {}; // avoid unecessary requests for addresses
    this.syncPeriodInMs = MoneroWalletRpc.DEFAULT_SYNC_PERIOD_IN_MS;
    this.listeners = [];
  }
  
  /**
   * <p>Create a client connected to monero-wallet-rpc (for internal use).</p>
   * 
   * @param {string|string[]|object|MoneroRpcConnection} uriOrConfig - uri of monero-wallet-rpc or terminal parameters or JS config object or MoneroRpcConnection
   * @param {string} uriOrConfig.uri - uri of monero-wallet-rpc
   * @param {string} uriOrConfig.username - username to authenticate with monero-wallet-rpc (optional)
   * @param {string} uriOrConfig.password - password to authenticate with monero-wallet-rpc (optional)
   * @param {boolean} uriOrConfig.rejectUnauthorized - rejects self-signed certificates if true (default true)
   * @param {string} username - username to authenticate with monero-wallet-rpc (optional)
   * @param {string} password - password to authenticate with monero-wallet-rpc (optional)
   * @param {boolean} rejectUnauthorized - rejects self-signed certificates if true (default true)
   * @return {MoneroWalletRpc} the wallet RPC client
   */
  static async _connectToWalletRpc(uriOrConfig, username, password, rejectUnauthorized) {
    if (GenUtils.isArray(uriOrConfig)) return MoneroWalletRpc._startWalletRpcProcess(uriOrConfig); // handle array as terminal command
    else return new MoneroWalletRpc(...arguments); // otherwise connect to server
  }
  
  static async _startWalletRpcProcess(cmd) {
    assert(GenUtils.isArray(cmd), "Must provide string array with command line parameters");
    
    // start process
    this.process = require('child_process').spawn(cmd[0], cmd.slice(1), {});
    this.process.stdout.setEncoding('utf8');
    this.process.stderr.setEncoding('utf8');
    
    // return promise which resolves after starting monero-wallet-rpc
    let uri;
    let that = this;
    let output = "";
    return new Promise(function(resolve, reject) {
      
      // handle stdout
      that.process.stdout.on('data', function(data) {
        let line = data.toString();
        LibraryUtils.log(2, line);
        output += line + '\n'; // capture output in case of error
        
        // extract uri from e.g. "I Binding on 127.0.0.1 (IPv4):38085"
        let uriLineContains = "Binding on ";
        let uriLineContainsIdx = line.indexOf(uriLineContains);
        if (uriLineContainsIdx >= 0) {
          let host = line.substring(uriLineContainsIdx + uriLineContains.length, line.lastIndexOf(' '));
          let unformattedLine = line.replace(/\u001b\[.*?m/g, '').trim(); // remove color formatting
          let port = unformattedLine.substring(unformattedLine.lastIndexOf(':') + 1);
          let sslIdx = cmd.indexOf("--rpc-ssl");
          let sslEnabled = sslIdx >= 0 ? "enabled" == cmd[sslIdx + 1].toLowerCase() : false;
          uri = (sslEnabled ? "https" : "http") + "://" + host + ":" + port;
        }
        
        // read success message
        if (line.indexOf("Starting wallet RPC server") >= 0) {
          
          // get username and password from params
          let userPassIdx = cmd.indexOf("--rpc-login");
          let userPass = userPassIdx >= 0 ? cmd[userPassIdx + 1] : undefined;
          let username = userPass === undefined ? undefined : userPass.substring(0, userPass.indexOf(':'));
          let password = userPass === undefined ? undefined : userPass.substring(userPass.indexOf(':') + 1);
          
          // create client connected to internal process
          let wallet = new MoneroWalletRpc(uri, username, password);
          wallet.process = that.process;
          
          // resolve promise with client connected to internal process 
          this.isResolved = true;
          resolve(wallet);
        }
      });
      
      // handle stderr
      that.process.stderr.on('data', function(data) {
        if (LibraryUtils.getLogLevel() >= 2) console.error(data);
      });
      
      // handle exit
      that.process.on("exit", function(code) {
        if (!this.isResolved) reject(new MoneroError("monero-wallet-rpc process terminated with exit code " + code + (output ? ":\n\n" + output : "")));
      });
      
      // handle error
      that.process.on("error", function(err) {
        if (err.message.indexOf("ENOENT") >= 0) reject(new MoneroError("monero-wallet-rpc does not exist at path '" + cmd[0] + "'"));
        if (!this.isResolved) reject(err);
      });
      
      // handle uncaught exception
      that.process.on("uncaughtException", function(err, origin) {
        console.error("Uncaught exception in monero-wallet-rpc process: " + err.message);
        console.error(origin);
        reject(err);
      });
    });
  }
  
  // --------------------------- RPC WALLET METHODS ---------------------------
  
  /**
   * Get the internal process running monero-wallet-rpc.
   * 
   * @return the process running monero-wallet-rpc, undefined if not created from new process
   */
  getProcess() {
    return this.process;
  }
  
  /**
   * Stop the internal process running monero-wallet-rpc, if applicable.
   */
  async stopProcess() {
    if (this.process === undefined) throw new MoneroError("MoneroWalletRpc instance not created from new process");
    let listenersCopy = GenUtils.copyArray(this.getListeners());
    for (let listener of listenersCopy) await this.removeListener(listener);
    return GenUtils.killProcess(this.process);
  }
  
  /**
   * Get the wallet's RPC connection.
   * 
   * @return {MoneroWalletRpc} the wallet's rpc connection
   */
  getRpcConnection() {
    return this.rpc;
  }
  
  /**
   * <p>Open an existing wallet on the monero-wallet-rpc server.</p>
   * 
   * <p>Example:<p>
   * 
   * <code>
   * let wallet = new MoneroWalletRpc("http://localhost:38084", "rpc_user", "abc123");<br>
   * await wallet.openWallet("mywallet1", "supersecretpassword");<br>
   * await wallet.openWallet({<br>
   * &nbsp;&nbsp; path: "mywallet2",<br>
   * &nbsp;&nbsp; password: "supersecretpassword",<br>
   * &nbsp;&nbsp; serverUri: "http://locahost:38081",<br>
   * &nbsp;&nbsp; rejectUnauthorized: false<br>
   * });<br>
   * </code>
   * 
   * @param {string|object|MoneroWalletConfig} pathOrConfig  - the wallet's name or configuration to open
   * @param {string} pathOrConfig.path - path of the wallet to create (optional, in-memory wallet if not given)
   * @param {string} pathOrConfig.password - password of the wallet to create
   * @param {string} pathOrConfig.serverUri - uri of a daemon to use (optional, monero-wallet-rpc usually started with daemon config)
   * @param {string} pathOrConfig.serverUsername - username to authenticate with the daemon (optional)
   * @param {string} pathOrConfig.serverPassword - password to authenticate with the daemon (optional)
   * @param {boolean} pathOrConfig.rejectUnauthorized - reject self-signed server certificates if true (defaults to true)
   * @param {MoneroRpcConnection|object} pathOrConfig.server - MoneroRpcConnection or equivalent JS object providing daemon configuration (optional)
   * @param {string} password is the wallet's password
   * @return {MoneroWalletRpc} this wallet client
   */
  async openWallet(pathOrConfig, password) {
    
    // normalize and validate config
    let config = new MoneroWalletConfig(typeof pathOrConfig === "string" ? {path: pathOrConfig, password: password} : pathOrConfig);
    // TODO: ensure other fields are uninitialized?
    
    // open wallet on rpc server
    if (!config.getPath()) throw new MoneroError("Must provide name of wallet to open");
    if (!config.getPassword()) throw new MoneroError("Must provide password of wallet to open");
    await this.rpc.sendJsonRequest("open_wallet", {filename: config.getPath(), password: config.getPassword()});
    await this._clear();
    this.path = config.getPath();
    
    // set daemon if provided
    if (config.getServer()) return this.setDaemonConnection(config.getServer());
    return this;
  }
  
  /**
   * <p>Create and open a wallet on the monero-wallet-rpc server.<p>
   * 
   * <p>Example:<p>
   * 
   * <code>
   * &sol;&sol; construct client to monero-wallet-rpc<br>
   * let walletRpc = new MoneroWalletRpc("http://localhost:38084", "rpc_user", "abc123");<br><br>
   * 
   * &sol;&sol; create and open wallet on monero-wallet-rpc<br>
   * await walletRpc.createWallet({<br>
   * &nbsp;&nbsp; path: "mywallet",<br>
   * &nbsp;&nbsp; password: "abc123",<br>
   * &nbsp;&nbsp; mnemonic: "coexist igloo pamphlet lagoon...",<br>
   * &nbsp;&nbsp; restoreHeight: 1543218l<br>
   * });
   *  </code>
   * 
   * @param {object|MoneroWalletConfig} config - MoneroWalletConfig or equivalent JS object
   * @param {string} config.path - path of the wallet to create (optional, in-memory wallet if not given)
   * @param {string} config.password - password of the wallet to create
   * @param {string} config.mnemonic - mnemonic of the wallet to create (optional, random wallet created if neither mnemonic nor keys given)
   * @param {string} config.seedOffset - the offset used to derive a new seed from the given mnemonic to recover a secret wallet from the mnemonic phrase
   * @param {string} config.primaryAddress - primary address of the wallet to create (only provide if restoring from keys)
   * @param {string} config.privateViewKey - private view key of the wallet to create (optional)
   * @param {string} config.privateSpendKey - private spend key of the wallet to create (optional)
   * @param {number} config.restoreHeight - block height to start scanning from (defaults to 0 unless generating random wallet)
   * @param {string} config.language - language of the wallet's mnemonic phrase (defaults to "English" or auto-detected)
   * @param {string} config.serverUri - uri of a daemon to use (optional, monero-wallet-rpc usually started with daemon config)
   * @param {string} config.serverUsername - username to authenticate with the daemon (optional)
   * @param {string} config.serverPassword - password to authenticate with the daemon (optional)
   * @param {boolean} config.rejectUnauthorized - reject self-signed server certificates if true (defaults to true)
   * @param {MoneroRpcConnection|object} config.server - MoneroRpcConnection or equivalent JS object providing daemon configuration (optional)
   * @param {boolean} config.saveCurrent - specifies if the current RPC wallet should be saved before being closed (default true)
   * @return {MoneroWalletRpc} this wallet client
   */
  async createWallet(config) {
    
    // normalize and validate config
    if (config === undefined) throw new MoneroError("Must provide config to create wallet");
    config = config instanceof MoneroWalletConfig ? config : new MoneroWalletConfig(config);
    if (config.getMnemonic() !== undefined && (config.getPrimaryAddress() !== undefined || config.getPrivateViewKey() !== undefined || config.getPrivateSpendKey() !== undefined)) {
      throw new MoneroError("Wallet may be initialized with a mnemonic or keys but not both");
    }
    if (config.getNetworkType() !== undefined) throw new MoneroError("Cannot provide networkType when creating RPC wallet because server's network type is already set");
    
    // create wallet
    if (config.getMnemonic() !== undefined) {
      await this._createWalletFromMnemonic(config.getPath(), config.getPassword(), config.getMnemonic(), config.getRestoreHeight(), config.getLanguage(), config.getSeedOffset(), config.getSaveCurrent());
    } else if (config.getPrivateSpendKey() !== undefined || config.getPrimaryAddress() !== undefined) {
      if (config.getSeedOffset() !== undefined) throw new MoneroError("Cannot provide seedOffset when creating wallet from keys");
      await this._createWalletFromKeys(config.getPath(), config.getPassword(), config.getPrimaryAddress(), config.getPrivateViewKey(), config.getPrivateSpendKey(), config.getRestoreHeight(), config.getLanguage(), config.getSaveCurrent());
    } else {
      if (config.getSeedOffset() !== undefined) throw new MoneroError("Cannot provide seedOffset when creating random wallet");
      if (config.getRestoreHeight() !== undefined) throw new MoneroError("Cannot provide restoreHeight when creating random wallet");
      if (config.getSaveCurrent() === false) throw new MoneroError("Current wallet is saved automatically when creating random wallet");
      await this._createWalletRandom(config.getPath(), config.getPassword(), config.getLanguage());
    }
    
    // set daemon if provided
    if (config.getServer()) return this.setDaemonConnection(config.getServer());
    return this;
  }
  
  /**
   * Create and open a new wallet with a randomly generated seed on the RPC server.
   * 
   * @param {string} name - name of the wallet file to create
   * @param {string} password - wallet's password
   * @param {string} language - language for the wallet's mnemonic phrase
   * @return {MoneroWalletRpc} this wallet client
   */
  async _createWalletRandom(name, password, language) {
    if (!name) throw new MoneroError("Name is not initialized");
    if (!password) throw new MoneroError("Password is not initialized");
    if (!language) language = MoneroWallet.DEFAULT_LANGUAGE;
    let params = { filename: name, password: password, language: language };
    try {
      await this.rpc.sendJsonRequest("create_wallet", params);
    } catch (err) {
      this._handleCreateWalletError(name, err);
    }
    await this._clear();
    this.path = name;
    return this;
  }
  
  /**
   * Create and open a wallet from an existing mnemonic phrase on the RPC server,
   * closing the currently open wallet if applicable.
   * 
   * @param {string} name - name of the wallet to create on the RPC server
   * @param {string} password - wallet's password
   * @param {string} mnemonic - mnemonic of the wallet to construct
   * @param {int} restoreHeight - block height to restore from (default = 0)
   * @param {string} language - language of the mnemonic in case the old language is invalid
   * @param {string} seedOffset - offset used to derive a new seed from the given mnemonic to recover a secret wallet from the mnemonic phrase
   * @param {boolean} saveCurrent - specifies if the current RPC wallet should be saved before being closed
   * @return {MoneroWalletRpc} this wallet client
   */
  async _createWalletFromMnemonic(name, password, mnemonic, restoreHeight, language, seedOffset, saveCurrent) {
    try {
      await this.rpc.sendJsonRequest("restore_deterministic_wallet", {
        filename: name,
        password: password,
        seed: mnemonic,
        seed_offset: seedOffset,
        restore_height: restoreHeight,
        language: language,
        autosave_current: saveCurrent
      });
    } catch (err) {
      this._handleCreateWalletError(name, err);
    }
    await this._clear();
    this.path = name;
    return this;
  }
  
  /**
   * Create a wallet on the RPC server from an address, view key, and (optionally) spend key.
   * 
   * @param name - name of the wallet to create on the RPC server
   * @param password - password encrypt the wallet
   * @param networkType - wallet's network type
   * @param address - address of the wallet to construct
   * @param viewKey - view key of the wallet to construct
   * @param spendKey - spend key of the wallet to construct or null to create a view-only wallet
   * @param restoreHeight - block height to restore (i.e. scan the chain) from (default = 0)
   * @param language - wallet and mnemonic's language (default = "English")
   * @return {MoneroWalletRpc} this wallet client
   */
  async _createWalletFromKeys(name, password, address, viewKey, spendKey, restoreHeight, language, saveCurrent) {
    if (restoreHeight === undefined) restoreHeight = 0;
    if (language === undefined) language = MoneroWallet.DEFAULT_LANGUAGE;
    try {
      await this.rpc.sendJsonRequest("generate_from_keys", {
        filename: name,
        password: password,
        address: address,
        viewkey: viewKey,
        spendkey: spendKey,
        restore_height: restoreHeight,
        autosave_current: saveCurrent
      });
    } catch (err) {
      this._handleCreateWalletError(name, err);
    }
    await this._clear();
    this.path = name;
    return this;
  }
  
  _handleCreateWalletError(name, err) {
    if (err.message === "Cannot create wallet. Already exists.") throw new MoneroRpcError("Wallet already exists: " + name, err.getCode(), err.getRpcMethod(), err.getRpcParams());
    if (err.message === "Electrum-style word list failed verification") throw new MoneroRpcError("Invalid mnemonic", err.getCode(), err.getRpcMethod(), err.getRpcParams());
    throw err;
  }
  
  async isViewOnly() {
    try {
      await this.rpc.sendJsonRequest("query_key", {key_type: "mnemonic"});
      return false; // key retrieval succeeds if not view only
    } catch (e) {
      if (e.getCode() === -29) return true;  // wallet is view only
      if (e.getCode() === -1) return false;  // wallet is offline but not view only
      throw e;
    }
  }
  
  /**
   * Set the wallet's daemon connection.
   * 
   * @param {string|MoneroRpcConnection} uriOrConnection - the daemon's URI or connection (defaults to offline)
   * @param {boolean} isTrusted - indicates if the daemon in trusted
   * @param {SslOptions} sslOptions - custom SSL configuration
   */
  async setDaemonConnection(uriOrRpcConnection, isTrusted, sslOptions) {
    let connection = !uriOrRpcConnection ? undefined : uriOrRpcConnection instanceof MoneroRpcConnection ? uriOrRpcConnection : new MoneroRpcConnection(uriOrRpcConnection);
    if (!sslOptions) sslOptions = new SslOptions();
    let params = {};
    params.address = connection ? connection.getUri() : "bad_uri"; // TODO monero-wallet-rpc: bad daemon uri necessary for offline?
    params.username = connection ? connection.getUsername() : "";
    params.password = connection ? connection.getPassword() : "";
    params.trusted = isTrusted;
    params.ssl_support = "autodetect";
    params.ssl_private_key_path = sslOptions.getPrivateKeyPath();
    params.ssl_certificate_path  = sslOptions.getCertificatePath();
    params.ssl_ca_file = sslOptions.getCertificateAuthorityFile();
    params.ssl_allowed_fingerprints = sslOptions.getAllowedFingerprints();
    params.ssl_allow_any_cert = sslOptions.getAllowAnyCert();
    await this.rpc.sendJsonRequest("set_daemon", params);
    this.daemonConnection = connection;
  }
  
  async getDaemonConnection() {
    return this.daemonConnection;
  }
  
  // -------------------------- COMMON WALLET METHODS -------------------------
  
  async addListener(listener) {
    assert(listener instanceof MoneroWalletListener, "Listener must be instance of MoneroWalletListener");
    this.listeners.push(listener);
    this._refreshListening();
  }
  
  async removeListener(listener) {
    let idx = this.listeners.indexOf(listener);
    if (idx > -1) this.listeners.splice(idx, 1);
    else throw new MoneroError("Listener is not registered with wallet");
    this._refreshListening();
  }
  
  getListeners() {
    return this.listeners;
  }
  
  async isConnectedToDaemon() {
    try {
      await this.checkReserveProof(await this.getPrimaryAddress(), "", ""); // TODO (monero-project): provide better way to know if wallet rpc is connected to daemon
      throw new MoneroError("check reserve expected to fail");
    } catch (e) {
      return e.message.indexOf("Failed to connect to daemon") < 0;
    }
  }
  
  async getVersion() {
    let resp = await this.rpc.sendJsonRequest("get_version");
    return new MoneroVersion(resp.result.version, resp.result.release);
  }
  
  async getPath() {
    return this.path;
  }
  
  async getMnemonic() {
    try {
      let resp = await this.rpc.sendJsonRequest("query_key", { key_type: "mnemonic" });
      return resp.result.key;
    } catch (e) {
      if (e.getCode() === -29) return undefined;  // wallet is view-only
      throw e;
    }
  }
  
  async getMnemonicLanguage() {
    if (await this.getMnemonic() === undefined) return undefined;
    throw new MoneroError("MoneroWalletRpc.getMnemonicLanguage() not supported");
  }

  /**
   * Get a list of available languages for the wallet's mnemonic phrase.
   * 
   * @return {string[]} the available languages for the wallet's mnemonic phrase
   */
  async getMnemonicLanguages() {
    return (await this.rpc.sendJsonRequest("get_languages")).result.languages;
  }
  
  async getPrivateViewKey() {
    let resp = await this.rpc.sendJsonRequest("query_key", { key_type: "view_key" });
    return resp.result.key;
  }
  
  async getPrivateSpendKey() {
    
    // get private spend key which will throw error if wallet is view-only
    try {
      let resp = await this.rpc.sendJsonRequest("query_key", { key_type: "spend_key" });
      return resp.result.key;
    } catch (e) {
      if (e.getCode() === -29 && e.message.indexOf("watch-only") !== -1) return undefined; // return undefined if wallet is view-only
      throw e;
    }
  }
  
  async getAddress(accountIdx, subaddressIdx) {
    let subaddressMap = this.addressCache[accountIdx];
    if (!subaddressMap) {
      await this.getSubaddresses(accountIdx, undefined, true);  // cache's all addresses at this account
      return this.getAddress(accountIdx, subaddressIdx);        // recursive call uses cache
    }
    let address = subaddressMap[subaddressIdx];
    if (!address) {
      await this.getSubaddresses(accountIdx, undefined, true);  // cache's all addresses at this account
      return this.addressCache[accountIdx][subaddressIdx];
    }
    return address;
  }
  
  // TODO: use cache
  async getAddressIndex(address) {
    
    // fetch result and normalize error if address does not belong to the wallet
    let resp;
    try {
      resp = await this.rpc.sendJsonRequest("get_address_index", {address: address});
    } catch (e) {
      if (e.getCode() === -2) throw new MoneroError(e.message);
      throw e;
    }
    
    // convert rpc response
    let subaddress = new MoneroSubaddress(address);
    subaddress.setAccountIndex(resp.result.index.major);
    subaddress.setIndex(resp.result.index.minor);
    return subaddress;
  }
  
  async getIntegratedAddress(standardAddress, paymentId) {
    try {
      let integratedAddressStr = (await this.rpc.sendJsonRequest("make_integrated_address", {standard_address: standardAddress, payment_id: paymentId})).result.integrated_address;
      return await this.decodeIntegratedAddress(integratedAddressStr);
    } catch (e) {
      if (e.message.includes("Invalid payment ID")) throw new MoneroError("Invalid payment ID: " + paymentId);
      throw e;
    }
  }
  
  async decodeIntegratedAddress(integratedAddress) {
    let resp = await this.rpc.sendJsonRequest("split_integrated_address", {integrated_address: integratedAddress});
    return new MoneroIntegratedAddress().setStandardAddress(resp.result.standard_address).setPaymentId(resp.result.payment_id).setIntegratedAddress(integratedAddress);
  }
  
  async getHeight() {
    return (await this.rpc.sendJsonRequest("get_height")).result.height;
  }
  
  async getDaemonHeight() {
    throw new MoneroError("monero-wallet-rpc does not support getting the chain height");
  }
  
  async getHeightByDate(year, month, day) {
    throw new MoneroError("monero-wallet-rpc does not support getting a height by date");
  }
  
  async sync(startHeight, onProgress) {
    assert(onProgress === undefined, "Monero Wallet RPC does not support reporting sync progress");
    try {
      let resp = await this.rpc.sendJsonRequest("refresh", {start_height: startHeight});
      await this._poll();
      return new MoneroSyncResult(resp.result.blocks_fetched, resp.result.received_money);
    } catch (err) {
      if (err.message === "no connection to daemon") throw new MoneroError("Wallet is not connected to daemon");
      throw err;
    }
  }
  
  async startSyncing(syncPeriodInMs) {
    
    // convert ms to seconds for rpc parameter
    let syncPeriodInSeconds = Math.round((syncPeriodInMs === undefined ? MoneroWalletRpc.DEFAULT_SYNC_PERIOD_IN_MS : syncPeriodInMs) / 1000);
    
    // send rpc request
    await this.rpc.sendJsonRequest("auto_refresh", {
      enable: true,
      period: syncPeriodInSeconds
    });
    
    // update sync period for poller
    this.syncPeriodInMs = syncPeriodInSeconds * 1000;
    if (this.walletPoller !== undefined) this.walletPoller.setPeriodInMs(syncPeriodInMs);
    
    // poll if listening
    await this._poll();
  }
  
  async stopSyncing() {
    return this.rpc.sendJsonRequest("auto_refresh", { enable: false });
  }
  
  async scanTxs(txHashes) {
    if (!txHashes || !txHashes.length) throw new MoneroError("No tx hashes given to scan");
    await this.rpc.sendJsonRequest("scan_tx", {txids: txHashes});
    await this._poll();
  }
  
  async rescanSpent() {
    await this.rpc.sendJsonRequest("rescan_spent");
  }
  
  async rescanBlockchain() {
    await this.rpc.sendJsonRequest("rescan_blockchain");
  }
  
  async getBalance(accountIdx, subaddressIdx) {
    return (await this._getBalances(accountIdx, subaddressIdx))[0];
  }
  
  async getUnlockedBalance(accountIdx, subaddressIdx) {
    return (await this._getBalances(accountIdx, subaddressIdx))[1];
  }
  
  async getAccounts(includeSubaddresses, tag, skipBalances) {
    
    // fetch accounts from rpc
    let resp = await this.rpc.sendJsonRequest("get_accounts", {tag: tag});
    
    // build account objects and fetch subaddresses per account using get_address
    // TODO monero-wallet-rpc: get_address should support all_accounts so not called once per account
    let accounts = [];
    for (let rpcAccount of resp.result.subaddress_accounts) {
      let account = MoneroWalletRpc._convertRpcAccount(rpcAccount);
      if (includeSubaddresses) account.setSubaddresses(await this.getSubaddresses(account.getIndex(), undefined, true));
      accounts.push(account);
    }
    
    // fetch and merge fields from get_balance across all accounts
    if (includeSubaddresses && !skipBalances) {
      
      // these fields are not initialized if subaddress is unused and therefore not returned from `get_balance`
      for (let account of accounts) {
        for (let subaddress of account.getSubaddresses()) {
          subaddress.setBalance(new BigInteger(0));
          subaddress.setUnlockedBalance(new BigInteger(0));
          subaddress.setNumUnspentOutputs(0);
          subaddress.setNumBlocksToUnlock(0);
        }
      }
      
      // fetch and merge info from get_balance
      resp = await this.rpc.sendJsonRequest("get_balance", {all_accounts: true});
      if (resp.result.per_subaddress) {
        for (let rpcSubaddress of resp.result.per_subaddress) {
          let subaddress = MoneroWalletRpc._convertRpcSubaddress(rpcSubaddress);
          
          // merge info
          let account = accounts[subaddress.getAccountIndex()];
          assert.equal(subaddress.getAccountIndex(), account.getIndex(), "RPC accounts are out of order");  // would need to switch lookup to loop
          let tgtSubaddress = account.getSubaddresses()[subaddress.getIndex()];
          assert.equal(subaddress.getIndex(), tgtSubaddress.getIndex(), "RPC subaddresses are out of order");
          if (subaddress.getBalance() !== undefined) tgtSubaddress.setBalance(subaddress.getBalance());
          if (subaddress.getUnlockedBalance() !== undefined) tgtSubaddress.setUnlockedBalance(subaddress.getUnlockedBalance());
          if (subaddress.getNumUnspentOutputs() !== undefined) tgtSubaddress.setNumUnspentOutputs(subaddress.getNumUnspentOutputs());
        }
      }
    }
    
    // return accounts
    return accounts;
  }
  
  // TODO: getAccountByIndex(), getAccountByTag()
  async getAccount(accountIdx, includeSubaddresses, skipBalances) {
    assert(accountIdx >= 0);
    for (let account of await this.getAccounts()) {
      if (account.getIndex() === accountIdx) {
        if (includeSubaddresses) account.setSubaddresses(await this.getSubaddresses(accountIdx, undefined, skipBalances));
        return account;
      }
    }
    throw new Exception("Account with index " + accountIdx + " does not exist");
  }

  async createAccount(label) {
    label = label ? label : undefined;
    let resp = await this.rpc.sendJsonRequest("create_account", {label: label});
    return new MoneroAccount(resp.result.account_index, resp.result.address, new BigInteger(0), new BigInteger(0));
  }

  async getSubaddresses(accountIdx, subaddressIndices, skipBalances) {
    
    // fetch subaddresses
    let params = {};
    params.account_index = accountIdx;
    if (subaddressIndices) params.address_index = GenUtils.listify(subaddressIndices);
    let resp = await this.rpc.sendJsonRequest("get_address", params);
    
    // initialize subaddresses
    let subaddresses = [];
    for (let rpcSubaddress of resp.result.addresses) {
      let subaddress = MoneroWalletRpc._convertRpcSubaddress(rpcSubaddress);
      subaddress.setAccountIndex(accountIdx);
      subaddresses.push(subaddress);
    }
    
    // fetch and initialize subaddress balances
    if (!skipBalances) {
      
      // these fields are not initialized if subaddress is unused and therefore not returned from `get_balance`
      for (let subaddress of subaddresses) {
        subaddress.setBalance(new BigInteger(0));
        subaddress.setUnlockedBalance(new BigInteger(0));
        subaddress.setNumUnspentOutputs(0);
        subaddress.setNumBlocksToUnlock(0);
      }

      // fetch and initialize balances
      resp = await this.rpc.sendJsonRequest("get_balance", params);
      if (resp.result.per_subaddress) {
        for (let rpcSubaddress of resp.result.per_subaddress) {
          let subaddress = MoneroWalletRpc._convertRpcSubaddress(rpcSubaddress);
          
          // transfer info to existing subaddress object
          for (let tgtSubaddress of subaddresses) {
            if (tgtSubaddress.getIndex() !== subaddress.getIndex()) continue; // skip to subaddress with same index
            if (subaddress.getBalance() !== undefined) tgtSubaddress.setBalance(subaddress.getBalance());
            if (subaddress.getUnlockedBalance() !== undefined) tgtSubaddress.setUnlockedBalance(subaddress.getUnlockedBalance());
            if (subaddress.getNumUnspentOutputs() !== undefined) tgtSubaddress.setNumUnspentOutputs(subaddress.getNumUnspentOutputs());
            if (subaddress.getNumBlocksToUnlock() !== undefined) tgtSubaddress.setNumBlocksToUnlock(subaddress.getNumBlocksToUnlock());
          }
        }
      }
    }
    
    // cache addresses
    let subaddressMap = this.addressCache[accountIdx];
    if (!subaddressMap) {
      subaddressMap = {};
      this.addressCache[accountIdx] = subaddressMap;
    }
    for (let subaddress of subaddresses) {
      subaddressMap[subaddress.getIndex()] = subaddress.getAddress();
    }
    
    // return results
    return subaddresses;
  }

  async getSubaddress(accountIdx, subaddressIdx, skipBalances) {
    assert(accountIdx >= 0);
    assert(subaddressIdx >= 0);
    return (await this.getSubaddresses(accountIdx, subaddressIdx, skipBalances))[0];
  }

  async createSubaddress(accountIdx, label) {
    
    // send request
    let resp = await this.rpc.sendJsonRequest("create_address", {account_index: accountIdx, label: label});
    
    // build subaddress object
    let subaddress = new MoneroSubaddress();
    subaddress.setAccountIndex(accountIdx);
    subaddress.setIndex(resp.result.address_index);
    subaddress.setAddress(resp.result.address);
    subaddress.setLabel(label ? label : undefined);
    subaddress.setBalance(new BigInteger(0));
    subaddress.setUnlockedBalance(new BigInteger(0));
    subaddress.setNumUnspentOutputs(0);
    subaddress.setIsUsed(false);
    subaddress.setNumBlocksToUnlock(0);
    return subaddress;
  }
  
  async getTxs(query, missingTxHashes) {
    
    // copy query
    query = MoneroWallet._normalizeTxQuery(query);
    
    // temporarily disable transfer and output queries in order to collect all tx information
    let transferQuery = query.getTransferQuery();
    let inputQuery = query.getInputQuery();
    let outputQuery = query.getOutputQuery();
    query.setTransferQuery(undefined);
    query.setInputQuery(undefined);
    query.setOutputQuery(undefined);
    
    // fetch all transfers that meet tx query
    let transfers = await this._getTransfersAux(new MoneroTransferQuery().setTxQuery(MoneroWalletRpc._decontextualize(query.copy())));
    
    // collect unique txs from transfers while retaining order
    let txs = [];
    let txsSet = new Set();
    for (let transfer of transfers) {
      if (!txsSet.has(transfer.getTx())) {
        txs.push(transfer.getTx());
        txsSet.add(transfer.getTx());
      }
    }
    
    // cache types into maps for merging and lookup
    let txMap = {};
    let blockMap = {};
    for (let tx of txs) {
      MoneroWalletRpc._mergeTx(tx, txMap, blockMap);
    }
    
    // fetch and merge outputs if requested
    if (query.getIncludeOutputs() || outputQuery) {
        
      // fetch outputs
      let outputQueryAux = (outputQuery ? outputQuery.copy() : new MoneroOutputQuery()).setTxQuery(MoneroWalletRpc._decontextualize(query.copy()));
      let outputs = await this._getOutputsAux(outputQueryAux);
      
      // merge output txs one time while retaining order
      let outputTxs = [];
      for (let output of outputs) {
        if (!outputTxs.includes(output.getTx())) {
          MoneroWalletRpc._mergeTx(output.getTx(), txMap, blockMap);
          outputTxs.push(output.getTx());
        }
      }
    }
    
    // restore transfer and output queries
    query.setTransferQuery(transferQuery);
    query.setInputQuery(inputQuery);
    query.setOutputQuery(outputQuery);
    
    // filter txs that don't meet transfer query
    let txsQueried = [];
    for (let tx of txs) {
      if (query.meetsCriteria(tx)) txsQueried.push(tx);
      else if (tx.getBlock() !== undefined) tx.getBlock().getTxs().splice(tx.getBlock().getTxs().indexOf(tx), 1);
    }
    txs = txsQueried;
    
    // collect unfound tx hashes
    if (query.getHashes()) {
      let unfoundTxHashes = [];
      for (let txHash of query.getHashes()) {
        let found = false;
        for (let tx of txs) {
          if (txHash === tx.getHash()) {
            found = true;
            break;
          }
        }
        if (!found) unfoundTxHashes.push(txHash);
      }
     
      // if txs not found, collect missing hashes or throw error if no collection given
      if (missingTxHashes) for (let unfoundTxHash of unfoundTxHashes) missingTxHashes.push(unfoundTxHash);
      else if (unfoundTxHashes.length > 0) throw new MoneroError("Wallet missing requested tx hashes: " + unfoundTxHashes);
    }
    
    // special case: re-fetch txs if inconsistency caused by needing to make multiple rpc calls
    for (let tx of txs) {
      if (tx.isConfirmed() && tx.getBlock() === undefined) {
        console.error("Inconsistency detected building txs from multiple rpc calls, re-fetching txs");
        return this.getTxs(query);
      }
    }
    
    // order txs if tx hashes given then return
    if (query.getHashes() && query.getHashes().length > 0) {
      let txsById = new Map()  // store txs in temporary map for sorting
      for (let tx of txs) txsById.set(tx.getHash(), tx);
      let orderedTxs = [];
      for (let hash of query.getHashes()) if (txsById.get(hash)) orderedTxs.push(txsById.get(hash));
      txs = orderedTxs;
    }
    return txs;
  }
  
  async getTransfers(query) {
    
    // copy and normalize query up to block
    query = MoneroWallet._normalizeTransferQuery(query);
    
    // get transfers directly if query does not require tx context (other transfers, outputs)
    if (!MoneroWalletRpc._isContextual(query)) return this._getTransfersAux(query);
    
    // otherwise get txs with full models to fulfill query
    let transfers = [];
    for (let tx of await this.getTxs(query.getTxQuery())) {
      for (let transfer of tx.filterTransfers(query)) {
        transfers.push(transfer);
      }
    }
    
    return transfers;
  }
  
  async getOutputs(query) {
    
    // copy and normalize query up to block
    query = MoneroWallet._normalizeOutputQuery(query);
    
    // get outputs directly if query does not require tx context (other outputs, transfers)
    if (!MoneroWalletRpc._isContextual(query)) return this._getOutputsAux(query);
    
    // otherwise get txs with full models to fulfill query
    let outputs = [];
    for (let tx of await this.getTxs(query.getTxQuery())) {
      for (let output of tx.filterOutputs(query)) {
        outputs.push(output);
      }
    }
    
    return outputs;
  }
  
  async exportOutputs(all) {
    return (await this.rpc.sendJsonRequest("export_outputs", {all: all})).result.outputs_data_hex;
  }
  
  async importOutputs(outputsHex) {
    let resp = await this.rpc.sendJsonRequest("import_outputs", {outputs_data_hex: outputsHex});
    return resp.result.num_imported;
  }
  
  async exportKeyImages(all) {
    return await this._rpcExportKeyImages(all);
  }
  
  async importKeyImages(keyImages) {
    
    // convert key images to rpc parameter
    let rpcKeyImages = keyImages.map(keyImage => ({key_image: keyImage.getHex(), signature: keyImage.getSignature()}));
    
    // send request
    let resp = await this.rpc.sendJsonRequest("import_key_images", {signed_key_images: rpcKeyImages});
    
    // build and return result
    let importResult = new MoneroKeyImageImportResult();
    importResult.setHeight(resp.result.height);
    importResult.setSpentAmount(new BigInteger(resp.result.spent));
    importResult.setUnspentAmount(new BigInteger(resp.result.unspent));
    return importResult;
  }
  
  async getNewKeyImagesFromLastImport() {
    return await this._rpcExportKeyImages(false);
  }
  
  async freezeOutput(keyImage) {
    return this.rpc.sendJsonRequest("freeze", {key_image: keyImage});
  }
  
  async thawOutput(keyImage) {
    return this.rpc.sendJsonRequest("thaw", {key_image: keyImage});
  }
  
  async isOutputFrozen(keyImage) {
    let resp = await this.rpc.sendJsonRequest("frozen", {key_image: keyImage});
    return resp.result.frozen === true;
  }
  
  async createTxs(config) {
    
    // validate, copy, and normalize config
    config = MoneroWallet._normalizeCreateTxsConfig(config);
    if (config.getCanSplit() === undefined) config.setCanSplit(true);
    if (config.getRelay() === true && await this.isMultisig()) throw new MoneroError("Cannot relay multisig transaction until co-signed");

    // determine account and subaddresses to send from
    let accountIdx = config.getAccountIndex();
    if (accountIdx === undefined) throw new MoneroError("Must provide the account index to send from");
    let subaddressIndices = config.getSubaddressIndices() === undefined ? undefined : config.getSubaddressIndices().slice(0); // fetch all or copy given indices
    
    // build config parameters
    let params = {};
    params.destinations = [];
    for (let destination of config.getDestinations()) {
      assert(destination.getAddress(), "Destination address is not defined");
      assert(destination.getAmount(), "Destination amount is not defined");
      params.destinations.push({ address: destination.getAddress(), amount: destination.getAmount().toString() });
    }
    params.account_index = accountIdx;
    params.subaddr_indices = subaddressIndices;
    params.payment_id = config.getPaymentId();
    params.unlock_time = config.getUnlockHeight();
    params.do_not_relay = config.getRelay() !== true;
    assert(config.getPriority() === undefined || config.getPriority() >= 0 && config.getPriority() <= 3);
    params.priority = config.getPriority();
    params.get_tx_hex = true;
    params.get_tx_metadata = true;
    if (config.getCanSplit()) params.get_tx_keys = true; // param to get tx key(s) depends if split
    else params.get_tx_key = true;
    
    // send request
    let result;
    try {
      let resp = await this.rpc.sendJsonRequest(config.getCanSplit() ? "transfer_split" : "transfer", params);
      result = resp.result;
    } catch (err) {
      if (err.message.indexOf("WALLET_RPC_ERROR_CODE_WRONG_ADDRESS") > -1) throw new MoneroError("Invalid destination address");
      throw err;
    }
    
    // pre-initialize txs iff present. multisig and view-only wallets will have tx set without transactions
    let txs;
    let numTxs = config.getCanSplit() ? (result.fee_list !== undefined ? result.fee_list.length : 0) : (result.fee !== undefined ? 1 : 0);
    if (numTxs > 0) txs = [];
    let copyDestinations = numTxs === 1;
    for (let i = 0; i < numTxs; i++) {
      let tx = new MoneroTxWallet();
      MoneroWalletRpc._initSentTxWallet(config, tx, copyDestinations);
      tx.getOutgoingTransfer().setAccountIndex(accountIdx);
      if (subaddressIndices !== undefined && subaddressIndices.length === 1) tx.getOutgoingTransfer().setSubaddressIndices(subaddressIndices);
      txs.push(tx);
    }
    
    // notify of changes
    if (config.getRelay()) await this._poll();
    
    // initialize tx set from rpc response with pre-initialized txs
    if (config.getCanSplit()) return MoneroWalletRpc._convertRpcSentTxsToTxSet(result, txs).getTxs();
    else return MoneroWalletRpc._convertRpcTxToTxSet(result, txs === undefined ? undefined : txs[0], true).getTxs();
  }
  
  async sweepOutput(config) {
    
    // normalize and validate config
    config = MoneroWallet._normalizeSweepOutputConfig(config);
    
    // build config parameters
    let params = {};
    params.address = config.getDestinations()[0].getAddress();
    params.account_index = config.getAccountIndex();
    params.subaddr_indices = config.getSubaddressIndices();
    params.key_image = config.getKeyImage();
    params.unlock_time = config.getUnlockHeight();
    params.do_not_relay = config.getRelay() !== true;
    assert(config.getPriority() === undefined || config.getPriority() >= 0 && config.getPriority() <= 3);
    params.priority = config.getPriority();
    params.payment_id = config.getPaymentId();
    params.get_tx_key = true;
    params.get_tx_hex = true;
    params.get_tx_metadata = true;
    
    // send request
    let resp = await this.rpc.sendJsonRequest("sweep_single", params);
    let result = resp.result;
    
    // notify of changes
    if (config.getRelay()) await this._poll();
    
    // build and return tx
    let tx = MoneroWalletRpc._initSentTxWallet(config, null, true);
    MoneroWalletRpc._convertRpcTxToTxSet(result, tx, true);
    tx.getOutgoingTransfer().getDestinations()[0].setAmount(tx.getOutgoingTransfer().getAmount()); // initialize destination amount
    return tx;
  }
  
  async sweepUnlocked(config) {
    
    // validate and normalize config
    config = MoneroWallet._normalizeSweepUnlockedConfig(config);
    
    // determine account and subaddress indices to sweep; default to all with unlocked balance if not specified
    let indices = new Map();  // maps each account index to subaddress indices to sweep
    if (config.getAccountIndex() !== undefined) {
      if (config.getSubaddressIndices() !== undefined) {
        indices.set(config.getAccountIndex(), config.getSubaddressIndices());
      } else {
        let subaddressIndices = [];
        indices.set(config.getAccountIndex(), subaddressIndices);
        for (let subaddress of await this.getSubaddresses(config.getAccountIndex())) {
          if (subaddress.getUnlockedBalance().compare(new BigInteger(0)) > 0) subaddressIndices.push(subaddress.getIndex());
        }
      }
    } else {
      let accounts = await this.getAccounts(true);
      for (let account of accounts) {
        if (account.getUnlockedBalance().compare(new BigInteger(0)) > 0) {
          let subaddressIndices = [];
          indices.set(account.getIndex(), subaddressIndices);
          for (let subaddress of account.getSubaddresses()) {
            if (subaddress.getUnlockedBalance().compare(new BigInteger(0)) > 0) subaddressIndices.push(subaddress.getIndex());
          }
        }
      }
    }
    
    // sweep from each account and collect resulting tx sets
    let txs = [];
    for (let accountIdx of indices.keys()) {
      
      // copy and modify the original config
      let copy = config.copy();
      copy.setAccountIndex(accountIdx);
      copy.setSweepEachSubaddress(false);
      
      // sweep all subaddresses together  // TODO monero-project: can this reveal outputs belong to the same wallet?
      if (copy.getSweepEachSubaddress() !== true) {
        copy.setSubaddressIndices(indices.get(accountIdx));
        for (let tx of await this._rpcSweepAccount(copy)) txs.push(tx);
      }
      
      // otherwise sweep each subaddress individually
      else {
        for (let subaddressIdx of indices.get(accountIdx)) {
          copy.setSubaddressIndices([subaddressIdx]);
          for (let tx of await this._rpcSweepAccount(copy)) txs.push(tx);
        }
      }
    }
    
    // notify of changes
    if (config.getRelay()) await this._poll();
    return txs;
  }
  
  async sweepDust(relay) {
    if (relay === undefined) relay = false;
    let resp = await this.rpc.sendJsonRequest("sweep_dust", {do_not_relay: !relay});
    if (relay) await this._poll();
    let result = resp.result;
    let txSet = MoneroWalletRpc._convertRpcSentTxsToTxSet(result);
    if (txSet.getTxs() === undefined) return [];
    for (let tx of txSet.getTxs()) {
      tx.setIsRelayed(!relay);
      tx.setInTxPool(tx.isRelayed());
    }
    return txSet.getTxs();
  }
  
  async relayTxs(txsOrMetadatas) {
    assert(Array.isArray(txsOrMetadatas), "Must provide an array of txs or their metadata to relay");
    let txHashes = [];
    for (let txOrMetadata of txsOrMetadatas) {
      let metadata = txOrMetadata instanceof MoneroTxWallet ? txOrMetadata.getMetadata() : txOrMetadata;
      let resp = await this.rpc.sendJsonRequest("relay_tx", { hex: metadata });
      txHashes.push(resp.result.tx_hash);
    }
    await this._poll(); // notify of changes
    return txHashes;
  }
  
  async describeTxSet(txSet) {
    let resp = await this.rpc.sendJsonRequest("describe_transfer", {
      unsigned_txset: txSet.getUnsignedTxHex(),
      multisig_txset: txSet.getMultisigTxHex()
    });
    return MoneroWalletRpc._convertRpcDescribeTransfer(resp.result);
  }
  
  async signTxs(unsignedTxHex) {
    let resp = await this.rpc.sendJsonRequest("sign_transfer", {
      unsigned_txset: unsignedTxHex,
      export_raw: false
    });
    await this._poll();
    return resp.result.signed_txset
  }
  
  async submitTxs(signedTxHex) {
    let resp = await this.rpc.sendJsonRequest("submit_transfer", {
      tx_data_hex: signedTxHex
    });
    await this._poll();
    return resp.result.tx_hash_list;
  }
  
  async signMessage(message, signatureType, accountIdx, subaddressIdx) {
    let resp = await this.rpc.sendJsonRequest("sign", {
        data: message,
        signature_type: signatureType === MoneroMessageSignatureType.SIGN_WITH_SPEND_KEY ? "spend" : "view",
        account_index: accountIdx,
        address_index: subaddressIdx
    });
    return resp.result.signature;
  }
  
  async verifyMessage(message, address, signature) {
    try {
      let resp = await this.rpc.sendJsonRequest("verify", {data: message, address: address, signature: signature});
      let result = new MoneroMessageSignatureResult(
        resp.result.good,
        !resp.result.good ? undefined : resp.result.old,
        !resp.result.good ? undefined : !resp.result.signature_type ? undefined : resp.result.signature_type === "view" ? MoneroMessageSignatureType.SIGN_WITH_VIEW_KEY : MoneroMessageSignatureType.SIGN_WITH_SPEND_KEY,
        !resp.result.good ? undefined : resp.result.version);
      return result;
    } catch (e) {
      if (e.getCode() === -2) return new MoneroMessageSignatureResult(false);
      throw e;
    }
  }
  
  async getTxKey(txHash) {
    try {
      return (await this.rpc.sendJsonRequest("get_tx_key", {txid: txHash})).result.tx_key;
    } catch (e) {
      if (e instanceof MoneroRpcError && e.getCode() === -8 && e.message.includes("TX ID has invalid format")) e = new MoneroRpcError("TX hash has invalid format", e.getCode(), e.getRpcMethod(), e.getRpcParams());  // normalize error message
      throw e;
    }
  }
  
  async checkTxKey(txHash, txKey, address) {
    try {
      
      // send request
      let resp = await this.rpc.sendJsonRequest("check_tx_key", {txid: txHash, tx_key: txKey, address: address});
      
      // interpret result
      let check = new MoneroCheckTx();
      check.setIsGood(true);
      check.setNumConfirmations(resp.result.confirmations);
      check.setInTxPool(resp.result.in_pool);
      check.setReceivedAmount(new BigInteger(resp.result.received));
      return check;
    } catch (e) {
      if (e instanceof MoneroRpcError && e.getCode() === -8 && e.message.includes("TX ID has invalid format")) e = new MoneroRpcError("TX hash has invalid format", e.getCode(), e.getRpcMethod(), e.getRpcParams());  // normalize error message
      throw e;
    }
  }
  
  async getTxProof(txHash, address, message) {
    try {
      let resp = await this.rpc.sendJsonRequest("get_tx_proof", {txid: txHash, address: address, message: message});
      return resp.result.signature;
    } catch (e) {
      if (e instanceof MoneroRpcError && e.getCode() === -8 && e.message.includes("TX ID has invalid format")) e = new MoneroRpcError("TX hash has invalid format", e.getCode(), e.getRpcMethod(), e.getRpcParams());  // normalize error message
      throw e;
    }
  }
  
  async checkTxProof(txHash, address, message, signature) {
    try {
      
      // send request
      let resp = await this.rpc.sendJsonRequest("check_tx_proof", {
        txid: txHash,
        address: address,
        message: message,
        signature: signature
      });
      
      // interpret response
      let isGood = resp.result.good;
      let check = new MoneroCheckTx();
      check.setIsGood(isGood);
      if (isGood) {
        check.setNumConfirmations(resp.result.confirmations);
        check.setInTxPool(resp.result.in_pool);
        check.setReceivedAmount(new BigInteger(resp.result.received));
      }
      return check;
    } catch (e) {
      if (e instanceof MoneroRpcError && e.getCode() === -1 && e.message === "basic_string") e = new MoneroRpcError("Must provide signature to check tx proof", -1);
      if (e instanceof MoneroRpcError && e.getCode() === -8 && e.message.includes("TX ID has invalid format")) e = new MoneroRpcError("TX hash has invalid format", e.getCode(), e.getRpcMethod(), e.getRpcParams());
      throw e;
    }
  }
  
  async getSpendProof(txHash, message) {
    try {
      let resp = await this.rpc.sendJsonRequest("get_spend_proof", {txid: txHash, message: message});
      return resp.result.signature;
    } catch (e) {
      if (e instanceof MoneroRpcError && e.getCode() === -8 && e.message.includes("TX ID has invalid format")) e = new MoneroRpcError("TX hash has invalid format", e.getCode(), e.getRpcMethod(), e.getRpcParams());  // normalize error message
      throw e;
    }
  }
  
  async checkSpendProof(txHash, message, signature) {
    try {
      let resp = await this.rpc.sendJsonRequest("check_spend_proof", {
        txid: txHash,
        message: message,
        signature: signature
      });
      return resp.result.good;
    } catch (e) {
      if (e instanceof MoneroRpcError && e.getCode() === -8 && e.message.includes("TX ID has invalid format")) e = new MoneroRpcError("TX hash has invalid format", e.getCode(), e.getRpcMethod(), e.getRpcParams());  // normalize error message
      throw e;
    }
  }
  
  async getReserveProofWallet(message) {
    let resp = await this.rpc.sendJsonRequest("get_reserve_proof", {
      all: true,
      message: message
    });
    return resp.result.signature;
  }
  
  async getReserveProofAccount(accountIdx, amount, message) {
    let resp = await this.rpc.sendJsonRequest("get_reserve_proof", {
      account_index: accountIdx,
      amount: amount.toString(),
      message: message
    });
    return resp.result.signature;
  }

  async checkReserveProof(address, message, signature) {
    
    // send request
    let resp = await this.rpc.sendJsonRequest("check_reserve_proof", {
      address: address,
      message: message,
      signature: signature
    });
    
    // interpret results
    let isGood = resp.result.good;
    let check = new MoneroCheckReserve();
    check.setIsGood(isGood);
    if (isGood) {
      check.setUnconfirmedSpentAmount(new BigInteger(resp.result.spent));
      check.setTotalAmount(new BigInteger(resp.result.total));
    }
    return check;
  }
  
  async getTxNotes(txHashes) {
    return (await this.rpc.sendJsonRequest("get_tx_notes", {txids: txHashes})).result.notes;
  }
  
  async setTxNotes(txHashes, notes) {
    await this.rpc.sendJsonRequest("set_tx_notes", {txids: txHashes, notes: notes});
  }
  
  async getAddressBookEntries(entryIndices) {
    let resp = await this.rpc.sendJsonRequest("get_address_book", {entries: entryIndices});
    if (!resp.result.entries) return [];
    let entries = [];
    for (let rpcEntry of resp.result.entries) {
      entries.push(new MoneroAddressBookEntry().setIndex(rpcEntry.index).setAddress(rpcEntry.address).setDescription(rpcEntry.description).setPaymentId(rpcEntry.payment_id));
    }
    return entries;
  }
  
  async addAddressBookEntry(address, description) {
    let resp = await this.rpc.sendJsonRequest("add_address_book", {address: address, description: description});
    return resp.result.index;
  }
  
  async editAddressBookEntry(index, setAddress, address, setDescription, description) {
    let resp = await this.rpc.sendJsonRequest("edit_address_book", {
      index: index,
      set_address: setAddress,
      address: address,
      set_description: setDescription,
      description: description
    });
  }
  
  async deleteAddressBookEntry(entryIdx) {
    await this.rpc.sendJsonRequest("delete_address_book", {index: entryIdx});
  }
  
  async tagAccounts(tag, accountIndices) {
    await this.rpc.sendJsonRequest("tag_accounts", {tag: tag, accounts: accountIndices});
  }

  async untagAccounts(accountIndices) {
    await this.rpc.sendJsonRequest("untag_accounts", {accounts: accountIndices});
  }

  async getAccountTags() {
    let tags = [];
    let resp = await this.rpc.sendJsonRequest("get_account_tags");
    if (resp.result.account_tags) {
      for (let rpcAccountTag of resp.result.account_tags) {
        tags.push(new MoneroAccountTag(rpcAccountTag.tag ? rpcAccountTag.tag : undefined, rpcAccountTag.label ? rpcAccountTag.label : undefined, rpcAccountTag.accounts));
      }
    }
    return tags;
  }

  async setAccountTagLabel(tag, label) {
    await this.rpc.sendJsonRequest("set_account_tag_description", {tag: tag, description: label});
  }
  
  async getPaymentUri(config) {
    config = MoneroWallet._normalizeCreateTxsConfig(config);
    let resp = await this.rpc.sendJsonRequest("make_uri", {
      address: config.getDestinations()[0].getAddress(),
      amount: config.getDestinations()[0].getAmount() ? config.getDestinations()[0].getAmount().toString() : undefined,
      payment_id: config.getPaymentId(),
      recipient_name: config.getRecipientName(),
      tx_description: config.getNote()
    });
    return resp.result.uri;
  }
  
  async parsePaymentUri(uri) {
    assert(uri, "Must provide URI to parse");
    let resp = await this.rpc.sendJsonRequest("parse_uri", {uri: uri});
    let config = new MoneroTxConfig({address: resp.result.uri.address, amount: new BigInteger(resp.result.uri.amount)});
    config.setPaymentId(resp.result.uri.payment_id);
    config.setRecipientName(resp.result.uri.recipient_name);
    config.setNote(resp.result.uri.tx_description);
    if ("" === config.getDestinations()[0].getAddress()) config.getDestinations()[0].setAddress(undefined);
    if ("" === config.getPaymentId()) config.setPaymentId(undefined);
    if ("" === config.getRecipientName()) config.setRecipientName(undefined);
    if ("" === config.getNote()) config.setNote(undefined);
    return config;
  }
  
  async getAttribute(key) {
    try {
      let resp = await this.rpc.sendJsonRequest("get_attribute", {key: key});
      return resp.result.value === "" ? undefined : resp.result.value;
    } catch (e) {
      if (e instanceof MoneroRpcError && e.getCode() === -45) return undefined;
      throw e;
    }
  }
  
  async setAttribute(key, val) {
    await this.rpc.sendJsonRequest("set_attribute", {key: key, value: val});
  }
  
  async startMining(numThreads, backgroundMining, ignoreBattery) {
    await this.rpc.sendJsonRequest("start_mining", {
      threads_count: numThreads,
      do_background_mining: backgroundMining,
      ignore_battery: ignoreBattery
    });
  }
  
  async stopMining() {
    await this.rpc.sendJsonRequest("stop_mining");
  }
  
  async isMultisigImportNeeded() {
    let resp = await this.rpc.sendJsonRequest("get_balance");
    return resp.result.multisig_import_needed === true;
  }
  
  async getMultisigInfo() {
    let resp = await this.rpc.sendJsonRequest("is_multisig");
    let result = resp.result;
    let info = new MoneroMultisigInfo();
    info.setIsMultisig(result.multisig);
    info.setIsReady(result.ready);
    info.setThreshold(result.threshold);
    info.setNumParticipants(result.total);
    return info;
  }
  
  async prepareMultisig() {
    let resp = await this.rpc.sendJsonRequest("prepare_multisig", {enable_multisig_experimental: true});
    let result = resp.result;
    return result.multisig_info;
  }
  
  async makeMultisig(multisigHexes, threshold, password) {
    let resp = await this.rpc.sendJsonRequest("make_multisig", {
      multisig_info: multisigHexes,
      threshold: threshold,
      password: password
    });
    return resp.result.multisig_info;
  }
  
  async exchangeMultisigKeys(multisigHexes, password) {
    let resp = await this.rpc.sendJsonRequest("exchange_multisig_keys", {multisig_info: multisigHexes, password: password});
    let msResult = new MoneroMultisigInitResult();
    msResult.setAddress(resp.result.address);
    msResult.setMultisigHex(resp.result.multisig_info);
    if (msResult.getAddress().length === 0) msResult.setAddress(undefined);
    if (msResult.getMultisigHex().length === 0) msResult.setMultisigHex(undefined);
    return msResult;
  }
  
  async exportMultisigHex() {
    let resp = await this.rpc.sendJsonRequest("export_multisig_info");
    return resp.result.info;
  }

  async importMultisigHex(multisigHexes) {
    if (!GenUtils.isArray(multisigHexes)) throw new MoneroError("Must provide string[] to importMultisigHex()")
    let resp = await this.rpc.sendJsonRequest("import_multisig_info", {info: multisigHexes});
    return resp.result.n_outputs;
  }

  async signMultisigTxHex(multisigTxHex) {
    let resp = await this.rpc.sendJsonRequest("sign_multisig", {tx_data_hex: multisigTxHex});
    let result = resp.result;
    let signResult = new MoneroMultisigSignResult();
    signResult.setSignedMultisigTxHex(result.tx_data_hex);
    signResult.setTxHashes(result.tx_hash_list);
    return signResult;
  }

  async submitMultisigTxHex(signedMultisigTxHex) {
    let resp = await this.rpc.sendJsonRequest("submit_multisig", {tx_data_hex: signedMultisigTxHex});
    return resp.result.tx_hash_list;
  }
  
  async changePassword(oldPassword, newPassword) {
    return this.rpc.sendJsonRequest("change_wallet_password", {old_password: oldPassword, new_password: newPassword});
  }
  
  async save() {
    await this.rpc.sendJsonRequest("store");
  }
  
  async close(save) {
    if (save === undefined) save = false;
    await this._clear();
    await this.rpc.sendJsonRequest("close_wallet", {autosave_current: save});
  }
  
  async isClosed() {
    try {
      await this.getPrimaryAddress();
    } catch (e) {
      return e instanceof MoneroRpcError && e.getCode() === -13 && e.message.indexOf("No wallet file") > -1;
    }
    return false;
  }
  
  /**
   * Save and close the current wallet and stop the RPC server.
   */
  async stop() {
    await this._clear();
    await this.rpc.sendJsonRequest("stop_wallet");
  }
  
  // ----------- ADD JSDOC FOR SUPPORTED DEFAULT IMPLEMENTATIONS --------------
  
  async getNumBlocksToUnlock() { return super.getNumBlocksToUnlock(...arguments); }
  async getTx() { return super.getTx(...arguments); }
  async getIncomingTransfers() { return super.getIncomingTransfers(...arguments); }
  async getOutgoingTransfers() { return super.getOutgoingTransfers(...arguments); }
  async createTx() { return super.createTx(...arguments); }
  async relayTx() { return super.relayTx(...arguments); }
  async getTxNote() { return super.getTxNote(...arguments); }
  async setTxNote() { return super.setTxNote(...arguments); }
  
  // -------------------------------- PRIVATE ---------------------------------
  
  async _clear() {
    this.listeners.splice(0, this.listeners.length);
    this._refreshListening();
    delete this.addressCache;
    this.addressCache = {};
    this.path = undefined;
  }
  
  async _getBalances(accountIdx, subaddressIdx) {
    if (accountIdx === undefined) {
      assert.equal(subaddressIdx, undefined, "Must provide account index with subaddress index");
      let balance = new BigInteger(0);
      let unlockedBalance = new BigInteger(0);
      for (let account of await this.getAccounts()) {
        balance = balance.add(account.getBalance());
        unlockedBalance = unlockedBalance.add(account.getUnlockedBalance());
      }
      return [balance, unlockedBalance];
    } else {
      let params = {account_index: accountIdx, address_indices: subaddressIdx === undefined ? undefined : [subaddressIdx]};
      let resp = await this.rpc.sendJsonRequest("get_balance", params);
      if (subaddressIdx === undefined) return [new BigInteger(resp.result.balance), new BigInteger(resp.result.unlocked_balance)];
      else return [new BigInteger(resp.result.per_subaddress[0].balance), new BigInteger(resp.result.per_subaddress[0].unlocked_balance)];
    }
  }
  
  async _getAccountIndices(getSubaddressIndices) {
    let indices = new Map();
    for (let account of await this.getAccounts()) {
      indices.set(account.getIndex(), getSubaddressIndices ? await this._getSubaddressIndices(account.getIndex()) : undefined);
    }
    return indices;
  }
  
  async _getSubaddressIndices(accountIdx) {
    let subaddressIndices = [];
    let resp = await this.rpc.sendJsonRequest("get_address", {account_index: accountIdx});
    for (let address of resp.result.addresses) subaddressIndices.push(address.address_index);
    return subaddressIndices;
  }
  
  async _getTransfersAux(query) {
    
    // check if pool txs explicitly requested without daemon connection
    let isConnectedToDaemon = await this.isConnectedToDaemon();
    let txQuery = query.getTxQuery();
    if (txQuery.inTxPool() !== undefined && txQuery.inTxPool() && !isConnectedToDaemon) {
      throw new MoneroError("Cannot fetch pool transactions because wallet has no daemon connection");
    }
    
    // build params for get_transfers rpc call
    let canBeConfirmed = txQuery.isConfirmed() !== false && txQuery.inTxPool() !== true && txQuery.isFailed() !== true && txQuery.isRelayed() !== false;
    let canBeInTxPool = isConnectedToDaemon && txQuery.isConfirmed() !== true && txQuery.inTxPool() !== false && txQuery.isFailed() !== true && txQuery.isRelayed() !== false && txQuery.getHeight() === undefined && txQuery.getMaxHeight() === undefined && txQuery.isLocked() !== false;
    let canBeIncoming = query.isIncoming() !== false && query.isOutgoing() !== true && query.hasDestinations() !== true;
    let canBeOutgoing = query.isOutgoing() !== false && query.isIncoming() !== true;
    let params = {};
    params.in = canBeIncoming && canBeConfirmed;
    params.out = canBeOutgoing && canBeConfirmed;
    params.pool = canBeIncoming && canBeInTxPool;
    params.pending = canBeOutgoing && canBeInTxPool;
    params.failed = txQuery.isFailed() !== false && txQuery.isConfirmed() !== true && txQuery.inTxPool() != true;
    if (txQuery.getMinHeight() !== undefined) {
      if (txQuery.getMinHeight() > 0) params.min_height = txQuery.getMinHeight() - 1; // TODO monero-project: wallet2::get_payments() min_height is exclusive, so manually offset to match intended range (issues #5751, #5598)
      else params.min_height = txQuery.getMinHeight();
    }
    if (txQuery.getMaxHeight() !== undefined) params.max_height = txQuery.getMaxHeight();
    params.filter_by_height = txQuery.getMinHeight() !== undefined || txQuery.getMaxHeight() !== undefined;
    if (query.getAccountIndex() === undefined) {
      assert(query.getSubaddressIndex() === undefined && query.getSubaddressIndices() === undefined, "Query specifies a subaddress index but not an account index");
      params.all_accounts = true;
    } else {
      params.account_index = query.getAccountIndex();
      
      // set subaddress indices param
      let subaddressIndices = new Set();
      if (query.getSubaddressIndex() !== undefined) subaddressIndices.add(query.getSubaddressIndex());
      if (query.getSubaddressIndices() !== undefined) query.getSubaddressIndices().map(subaddressIdx => subaddressIndices.add(subaddressIdx));
      if (subaddressIndices.size) params.subaddr_indices = Array.from(subaddressIndices);
    }
    
    // cache unique txs and blocks
    let txMap = {};
    let blockMap = {};
    
    // build txs using `get_transfers`
    let resp = await this.rpc.sendJsonRequest("get_transfers", params);
    for (let key of Object.keys(resp.result)) {
      for (let rpcTx of resp.result[key]) {
        //if (rpcTx.txid === query.debugTxId) console.log(rpcTx);
        let tx = MoneroWalletRpc._convertRpcTxWithTransfer(rpcTx);
        if (tx.isConfirmed()) assert(tx.getBlock().getTxs().indexOf(tx) > -1);
        
        // replace transfer amount with destination sum
        // TODO monero-wallet-rpc: confirmed tx from/to same account has amount 0 but cached transfers
        if (tx.getOutgoingTransfer() !== undefined && tx.isRelayed() && !tx.isFailed() &&
            tx.getOutgoingTransfer().getDestinations() && tx.getOutgoingAmount().compare(new BigInteger(0)) === 0) {
          let outgoingTransfer = tx.getOutgoingTransfer();
          let transferTotal = new BigInteger(0);
          for (let destination of outgoingTransfer.getDestinations()) transferTotal = transferTotal.add(destination.getAmount());
          tx.getOutgoingTransfer().setAmount(transferTotal);
        }
        
        // merge tx
        MoneroWalletRpc._mergeTx(tx, txMap, blockMap);
      }
    }
    
    // sort txs by block height
    let txs = Object.values(txMap);
    txs.sort(MoneroWalletRpc._compareTxsByHeight);
    
    // filter and return transfers
    let transfers = [];
    for (let tx of txs) {
      
      // tx is not incoming/outgoing unless already set
      if (tx.isIncoming() === undefined) tx.setIsIncoming(false);
      if (tx.isOutgoing() === undefined) tx.setIsOutgoing(false);
      
      // sort incoming transfers
      if (tx.getIncomingTransfers() !== undefined) tx.getIncomingTransfers().sort(MoneroWalletRpc._compareIncomingTransfers);
      
      // collect queried transfers, erase if excluded
      for (let transfer of tx.filterTransfers(query)) {
        transfers.push(transfer);
      }
      
      // remove txs without requested transfer
      if (tx.getBlock() !== undefined && tx.getOutgoingTransfer() === undefined && tx.getIncomingTransfers() === undefined) {
        tx.getBlock().getTxs().splice(tx.getBlock().getTxs().indexOf(tx), 1);
      }
    }
    
    return transfers;
  }
  
  async _getOutputsAux(query) {
    
    // determine account and subaddress indices to be queried
    let indices = new Map();
    if (query.getAccountIndex() !== undefined) {
      let subaddressIndices = new Set();
      if (query.getSubaddressIndex() !== undefined) subaddressIndices.add(query.getSubaddressIndex());
      if (query.getSubaddressIndices() !== undefined) query.getSubaddressIndices().map(subaddressIdx => subaddressIndices.add(subaddressIdx));
      indices.set(query.getAccountIndex(), subaddressIndices.size ? Array.from(subaddressIndices) : undefined);  // undefined will fetch from all subaddresses
    } else {
      assert.equal(query.getSubaddressIndex(), undefined, "Query specifies a subaddress index but not an account index")
      assert(query.getSubaddressIndices() === undefined || query.getSubaddressIndices().length === 0, "Query specifies subaddress indices but not an account index");
      indices = await this._getAccountIndices();  // fetch all account indices without subaddresses
    }
    
    // cache unique txs and blocks
    let txMap = {};
    let blockMap = {};
    
    // collect txs with outputs for each indicated account using `incoming_transfers` rpc call
    let params = {};
    params.transfer_type = query.isSpent() === true ? "unavailable" : query.isSpent() === false ? "available" : "all";
    params.verbose = true;
    for (let accountIdx of indices.keys()) {
    
      // send request
      params.account_index = accountIdx;
      params.subaddr_indices = indices.get(accountIdx);
      let resp = await this.rpc.sendJsonRequest("incoming_transfers", params);
      
      // convert response to txs with outputs and merge
      if (resp.result.transfers === undefined) continue;
      for (let rpcOutput of resp.result.transfers) {
        let tx = MoneroWalletRpc._convertRpcTxWalletWithOutput(rpcOutput);
        MoneroWalletRpc._mergeTx(tx, txMap, blockMap);
      }
    }
    
    // sort txs by block height
    let txs = Object.values(txMap);
    txs.sort(MoneroWalletRpc._compareTxsByHeight);
    
    // collect queried outputs
    let outputs = [];
    for (let tx of txs) {
      
      // sort outputs
      if (tx.getOutputs() !== undefined) tx.getOutputs().sort(MoneroWalletRpc._compareOutputs);
      
      // collect queried outputs, erase if excluded
      for (let output of tx.filterOutputs(query)) outputs.push(output);
      
      // remove excluded txs from block
      if (tx.getOutputs() === undefined && tx.getBlock() !== undefined) {
        tx.getBlock().getTxs().splice(tx.getBlock().getTxs().indexOf(tx), 1);
      }
    }
    return outputs;
  }
  
  /**
   * Common method to get key images.
   * 
   * @param all - pecifies to get all xor only new images from last import
   * @return {MoneroKeyImage[]} are the key images
   */
  async _rpcExportKeyImages(all) {
    let resp = await this.rpc.sendJsonRequest("export_key_images", {all: all});
    if (!resp.result.signed_key_images) return [];
    return resp.result.signed_key_images.map(rpcImage => new MoneroKeyImage(rpcImage.key_image, rpcImage.signature));
  }
  
  async _rpcSweepAccount(config) {
    
    // validate config
    if (config === undefined) throw new MoneroError("Must provide sweep config");
    if (config.getAccountIndex() === undefined) throw new MoneroError("Must provide an account index to sweep from");
    if (config.getDestinations() === undefined || config.getDestinations().length != 1) throw new MoneroError("Must provide exactly one destination to sweep to");
    if (config.getDestinations()[0].getAddress() === undefined) throw new MoneroError("Must provide destination address to sweep to");
    if (config.getDestinations()[0].getAmount() !== undefined) throw new MoneroError("Cannot specify amount in sweep config");
    if (config.getKeyImage() !== undefined) throw new MoneroError("Key image defined; use sweepOutput() to sweep an output by its key image");
    if (config.getSubaddressIndices() !== undefined && config.getSubaddressIndices().length === 0) throw new MoneroError("Empty list given for subaddresses indices to sweep");
    if (config.getSweepEachSubaddress()) throw new MoneroError("Cannot sweep each subaddress with RPC `sweep_all`");
    
    // sweep from all subaddresses if not otherwise defined
    if (config.getSubaddressIndices() === undefined) {
      config.setSubaddressIndices([]);
      for (let subaddress of await this.getSubaddresses(config.getAccountIndex())) {
        config.getSubaddressIndices().push(subaddress.getIndex());
      }
    }
    if (config.getSubaddressIndices().length === 0) throw new MoneroError("No subaddresses to sweep from");
    
    // common config params
    let params = {};
    let relay = config.getRelay() === true;
    params.account_index = config.getAccountIndex();
    params.subaddr_indices = config.getSubaddressIndices();
    params.address = config.getDestinations()[0].getAddress();
    assert(config.getPriority() === undefined || config.getPriority() >= 0 && config.getPriority() <= 3);
    params.priority = config.getPriority();
    params.unlock_time = config.getUnlockHeight();
    params.payment_id = config.getPaymentId();
    params.do_not_relay = !relay;
    params.below_amount = config.getBelowAmount();
    params.get_tx_keys = true;
    params.get_tx_hex = true;
    params.get_tx_metadata = true;
    
    // invoke wallet rpc `sweep_all`
    let resp = await this.rpc.sendJsonRequest("sweep_all", params);
    let result = resp.result;
    
    // initialize txs from response
    let txSet = MoneroWalletRpc._convertRpcSentTxsToTxSet(result);
    
    // initialize remaining known fields
    for (let tx of txSet.getTxs()) {
      tx.setIsLocked(true);
      tx.setIsConfirmed(false);
      tx.setNumConfirmations(0);
      tx.setRelay(relay);
      tx.setInTxPool(relay);
      tx.setIsRelayed(relay);
      tx.setIsMinerTx(false);
      tx.setIsFailed(false);
      tx.setRingSize(MoneroUtils.RING_SIZE);
      let transfer = tx.getOutgoingTransfer();
      transfer.setAccountIndex(config.getAccountIndex());
      if (config.getSubaddressIndices().length === 1) transfer.setSubaddressIndices(config.getSubaddressIndices());
      let destination = new MoneroDestination(config.getDestinations()[0].getAddress(), new BigInteger(transfer.getAmount()));
      transfer.setDestinations([destination]);
      tx.setOutgoingTransfer(transfer);
      tx.setPaymentId(config.getPaymentId());
      if (tx.getUnlockHeight() === undefined) tx.setUnlockHeight(config.getUnlockHeight() === undefined ? 0 : config.getUnlockHeight());
      if (tx.getRelay()) {
        if (tx.getLastRelayedTimestamp() === undefined) tx.setLastRelayedTimestamp(+new Date().getTime());  // TODO (monero-wallet-rpc): provide timestamp on response; unconfirmed timestamps vary
        if (tx.isDoubleSpendSeen() === undefined) tx.setIsDoubleSpend(false);
      }
    }
    return txSet.getTxs();
  }
  
  _refreshListening() {
    if (this.walletPoller == undefined && this.listeners.length) this.walletPoller = new WalletPoller(this);
    if (this.walletPoller !== undefined) this.walletPoller.setIsPolling(this.listeners.length > 0);
  }
  
  /**
   * Poll if listening.
   */
  async _poll() {
    if (this.walletPoller !== undefined && this.walletPoller._isPolling) await this.walletPoller.poll();
  }
  
  // ---------------------------- PRIVATE STATIC ------------------------------
  
  static _normalizeConfig(uriOrConfigOrConnection, username, password, rejectUnauthorized) {
    let config;
    if (typeof uriOrConfigOrConnection === "string") config = {uri: uriOrConfigOrConnection, username: username, password: password, rejectUnauthorized: rejectUnauthorized};
    else {
      if (typeof uriOrConfigOrConnection !== "object") throw new MoneroError("Invalid configuration to create rpc client; must be string, object, or MoneroRpcConnection");
      if (username || password || rejectUnauthorized) throw new MoneroError("Can provide config object or params or new MoneroDaemonRpc(...) but not both");
      if (uriOrConfigOrConnection instanceof MoneroRpcConnection) config = Object.assign({}, uriOrConfigOrConnection.getConfig());
      else config = Object.assign({}, uriOrConfigOrConnection);
    }
    if (config.server) {
      config = Object.assign(config, new MoneroRpcConnection(config.server).getConfig());
      delete config.server;
    }
    return config;
  }
  
  /**
   * Remove criteria which requires looking up other transfers/outputs to
   * fulfill query.
   * 
   * @param {MoneroTxQuery} query - the query to decontextualize
   * @return {MoneroTxQuery} a reference to the query for convenience
   */
  static _decontextualize(query) {
    query.setIsIncoming(undefined);
    query.setIsOutgoing(undefined);
    query.setTransferQuery(undefined);
    query.setInputQuery(undefined);
    query.setOutputQuery(undefined);
    return query;
  }
  
  static _isContextual(query) {
    if (!query) return false;
    if (!query.getTxQuery()) return false;
    if (query.getTxQuery().isIncoming() !== undefined) return true; // requires getting other transfers
    if (query.getTxQuery().isOutgoing() !== undefined) return true;
    if (query instanceof MoneroTransferQuery) {
      if (query.getTxQuery().getOutputQuery() !== undefined) return true; // requires getting other outputs
    } else if (query instanceof MoneroOutputQuery) {
      if (query.getTxQuery().getTransferQuery() !== undefined) return true; // requires getting other transfers
    } else {
      throw new MoneroError("query must be tx or transfer query");
    }
    return false;
  }
  
  static _convertRpcAccount(rpcAccount) {
    let account = new MoneroAccount();
    for (let key of Object.keys(rpcAccount)) {
      let val = rpcAccount[key];
      if (key === "account_index") account.setIndex(val);
      else if (key === "balance") account.setBalance(new BigInteger(val));
      else if (key === "unlocked_balance") account.setUnlockedBalance(new BigInteger(val));
      else if (key === "base_address") account.setPrimaryAddress(val);
      else if (key === "tag") account.setTag(val);
      else if (key === "label") { } // label belongs to first subaddress
      else console.log("WARNING: ignoring unexpected account field: " + key + ": " + val);
    }
    if ("" === account.getTag()) account.setTag(undefined);
    return account;
  }
  
  static _convertRpcSubaddress(rpcSubaddress) {
    let subaddress = new MoneroSubaddress();
    for (let key of Object.keys(rpcSubaddress)) {
      let val = rpcSubaddress[key];
      if (key === "account_index") subaddress.setAccountIndex(val);
      else if (key === "address_index") subaddress.setIndex(val);
      else if (key === "address") subaddress.setAddress(val);
      else if (key === "balance") subaddress.setBalance(new BigInteger(val));
      else if (key === "unlocked_balance") subaddress.setUnlockedBalance(new BigInteger(val));
      else if (key === "num_unspent_outputs") subaddress.setNumUnspentOutputs(val);
      else if (key === "label") { if (val) subaddress.setLabel(val); }
      else if (key === "used") subaddress.setIsUsed(val);
      else if (key === "blocks_to_unlock") subaddress.setNumBlocksToUnlock(val);
      else if (key == "time_to_unlock") {}  // ignoring
      else console.log("WARNING: ignoring unexpected subaddress field: " + key + ": " + val);
    }
    return subaddress;
  }
  
  /**
   * Initializes a sent transaction.
   * 
   * @param {MoneroTxConfig} config - send config
   * @param {MoneroTxWallet} tx - existing transaction to initialize (optional)
   * @param {boolean} copyDestinations - copies config destinations if true
   * @return {MoneroTxWallet} is the initialized send tx
   */
  static _initSentTxWallet(config, tx, copyDestinations) {
    if (!tx) tx = new MoneroTxWallet();
    let relay = config.getRelay() === true;
    tx.setIsOutgoing(true);
    tx.setIsConfirmed(false);
    tx.setNumConfirmations(0);
    tx.setInTxPool(relay);
    tx.setRelay(relay);
    tx.setIsRelayed(relay);
    tx.setIsMinerTx(false);
    tx.setIsFailed(false);
    tx.setIsLocked(true);
    tx.setRingSize(MoneroUtils.RING_SIZE);
    let transfer = new MoneroOutgoingTransfer().setTx(tx);
    if (config.getSubaddressIndices() && config.getSubaddressIndices().length === 1) transfer.setSubaddressIndices(config.getSubaddressIndices().slice(0)); // we know src subaddress indices iff config specifies 1
    if (copyDestinations) {
      let destCopies = [];
      for (let dest of config.getDestinations()) destCopies.push(dest.copy());
      transfer.setDestinations(destCopies);
    }
    tx.setOutgoingTransfer(transfer);
    tx.setPaymentId(config.getPaymentId());
    if (tx.getUnlockHeight() === undefined) tx.setUnlockHeight(config.getUnlockHeight() === undefined ? 0 : config.getUnlockHeight());
    if (config.getRelay()) {
      if (tx.getLastRelayedTimestamp() === undefined) tx.setLastRelayedTimestamp(+new Date().getTime());  // TODO (monero-wallet-rpc): provide timestamp on response; unconfirmed timestamps vary
      if (tx.isDoubleSpendSeen() === undefined) tx.setIsDoubleSpend(false);
    }
    return tx;
  }
  
  /**
   * Initializes a tx set from a RPC map excluding txs.
   * 
   * @param rpcMap - map to initialize the tx set from
   * @return MoneroTxSet - initialized tx set
   * @return the resulting tx set
   */
  static _convertRpcTxSet(rpcMap) {
    let txSet = new MoneroTxSet();
    txSet.setMultisigTxHex(rpcMap.multisig_txset);
    txSet.setUnsignedTxHex(rpcMap.unsigned_txset);
    txSet.setSignedTxHex(rpcMap.signed_txset);
    if (txSet.getMultisigTxHex() !== undefined && txSet.getMultisigTxHex().length === 0) txSet.setMultisigTxHex(undefined);
    if (txSet.getUnsignedTxHex() !== undefined && txSet.getUnsignedTxHex().length === 0) txSet.setUnsignedTxHex(undefined);
    if (txSet.getSignedTxHex() !== undefined && txSet.getSignedTxHex().length === 0) txSet.setSignedTxHex(undefined);
    return txSet;
  }
  
  /**
   * Initializes a MoneroTxSet from from a list of rpc txs.
   * 
   * @param rpcTxs - rpc txs to initialize the set from
   * @param txs - existing txs to further initialize (optional)
   * @return the converted tx set
   */
  static _convertRpcSentTxsToTxSet(rpcTxs, txs) {
    
    // build shared tx set
    let txSet = MoneroWalletRpc._convertRpcTxSet(rpcTxs);
    
    // get number of txs
    let numTxs = rpcTxs.fee_list ? rpcTxs.fee_list.length : 0;
    
    // done if rpc response contains no txs
    if (numTxs === 0) {
      assert.equal(txs, undefined);
      return txSet;
    }
    
    // pre-initialize txs if none given
    if (txs) txSet.setTxs(txs);
    else {
      txs = [];
      for (let i = 0; i < numTxs; i++) txs.push(new MoneroTxWallet());
    }
    for (let tx of txs) {
      tx.setTxSet(txSet);
      tx.setIsOutgoing(true);
    }
    txSet.setTxs(txs);
    
    // initialize txs from rpc lists
    for (let key of Object.keys(rpcTxs)) {
      let val = rpcTxs[key];
      if (key === "tx_hash_list") for (let i = 0; i < val.length; i++) txs[i].setHash(val[i]);
      else if (key === "tx_key_list") for (let i = 0; i < val.length; i++) txs[i].setKey(val[i]);
      else if (key === "tx_blob_list") for (let i = 0; i < val.length; i++) txs[i].setFullHex(val[i]);
      else if (key === "tx_metadata_list") for (let i = 0; i < val.length; i++) txs[i].setMetadata(val[i]);
      else if (key === "fee_list") for (let i = 0; i < val.length; i++) txs[i].setFee(new BigInteger(val[i]));
      else if (key === "weight_list") for (let i = 0; i < val.length; i++) txs[i].setWeight(val[i]);
      else if (key === "amount_list") {
        for (let i = 0; i < val.length; i++) {
          if (txs[i].getOutgoingTransfer() !== undefined) txs[i].getOutgoingTransfer().setAmount(new BigInteger(val[i]));
          else txs[i].setOutgoingTransfer(new MoneroOutgoingTransfer().setTx(txs[i]).setAmount(new BigInteger(val[i])));
        }
      }
      else if (key === "multisig_txset" || key === "unsigned_txset" || key === "signed_txset") {} // handled elsewhere
      else if (key === "spent_key_images_list") {
        let inputKeyImagesList = val;
        for (let i = 0; i < inputKeyImagesList.length; i++) {
          GenUtils.assertTrue(txs[i].getInputs() === undefined);
          txs[i].setInputs([]);
          for (let inputKeyImage of inputKeyImagesList[i]["key_images"]) {
            txs[i].getInputs().push(new MoneroOutputWallet().setKeyImage(new MoneroKeyImage().setHex(inputKeyImage)).setTx(txs[i]));
          }
        }
      }
      else console.log("WARNING: ignoring unexpected transaction field: " + key + ": " + val);
    }
    
    return txSet;
  }
  
  /**
   * Converts a rpc tx with a transfer to a tx set with a tx and transfer.
   * 
   * @param rpcTx - rpc tx to build from
   * @param tx - existing tx to continue initializing (optional)
   * @param isOutgoing - specifies if the tx is outgoing if true, incoming if false, or decodes from type if undefined
   * @returns the initialized tx set with a tx
   */
  static _convertRpcTxToTxSet(rpcTx, tx, isOutgoing) {
    let txSet = MoneroWalletRpc._convertRpcTxSet(rpcTx);
    txSet.setTxs([MoneroWalletRpc._convertRpcTxWithTransfer(rpcTx, tx, isOutgoing).setTxSet(txSet)]);
    return txSet;
  }
  
  /**
   * Builds a MoneroTxWallet from a RPC tx.
   * 
   * @param rpcTx - rpc tx to build from
   * @param tx - existing tx to continue initializing (optional)
   * @param isOutgoing - specifies if the tx is outgoing if true, incoming if false, or decodes from type if undefined
   * @returns {MoneroTxWallet} is the initialized tx
   */
  static _convertRpcTxWithTransfer(rpcTx, tx, isOutgoing) {  // TODO: change everything to safe set
        
    // initialize tx to return
    if (!tx) tx = new MoneroTxWallet();
    
    // initialize tx state from rpc type
    if (rpcTx.type !== undefined) isOutgoing = MoneroWalletRpc._decodeRpcType(rpcTx.type, tx);
    else assert.equal(typeof isOutgoing, "boolean", "Must indicate if tx is outgoing (true) xor incoming (false) since unknown");
    
    // TODO: safe set
    // initialize remaining fields  TODO: seems this should be part of common function with DaemonRpc._convertRpcTx
    let header;
    let transfer;
    for (let key of Object.keys(rpcTx)) {
      let val = rpcTx[key];
      if (key === "txid") tx.setHash(val);
      else if (key === "tx_hash") tx.setHash(val);
      else if (key === "fee") tx.setFee(new BigInteger(val));
      else if (key === "note") { if (val) tx.setNote(val); }
      else if (key === "tx_key") tx.setKey(val);
      else if (key === "type") { } // type already handled
      else if (key === "tx_size") tx.setSize(val);
      else if (key === "unlock_time") tx.setUnlockHeight(val);
      else if (key === "weight") tx.setWeight(val);
      else if (key === "locked") tx.setIsLocked(val);
      else if (key === "tx_blob") tx.setFullHex(val);
      else if (key === "tx_metadata") tx.setMetadata(val);
      else if (key === "double_spend_seen") tx.setIsDoubleSpend(val);
      else if (key === "block_height" || key === "height") {
        if (tx.isConfirmed()) {
          if (!header) header = new MoneroBlockHeader();
          header.setHeight(val);
        }
      }
      else if (key === "timestamp") {
        if (tx.isConfirmed()) {
          if (!header) header = new MoneroBlockHeader();
          header.setTimestamp(val);
        } else {
          // timestamp of unconfirmed tx is current request time
        }
      }
      else if (key === "confirmations") tx.setNumConfirmations(val);
      else if (key === "suggested_confirmations_threshold") {
        if (transfer === undefined) transfer = (isOutgoing ? new MoneroOutgoingTransfer() : new MoneroIncomingTransfer()).setTx(tx);
        if (!isOutgoing) transfer.setNumSuggestedConfirmations(val);
      }
      else if (key === "amount") {
        if (transfer === undefined) transfer = (isOutgoing ? new MoneroOutgoingTransfer() : new MoneroIncomingTransfer()).setTx(tx);
        transfer.setAmount(new BigInteger(val));
      }
      else if (key === "amounts") {}  // ignoring, amounts sum to amount
      else if (key === "address") {
        if (!isOutgoing) {
          if (!transfer) transfer = new MoneroIncomingTransfer().setTx(tx);
          transfer.setAddress(val);
        }
      }
      else if (key === "payment_id") {
        if ("" !== val && MoneroTxWallet.DEFAULT_PAYMENT_ID !== val) tx.setPaymentId(val);  // default is undefined
      }
      else if (key === "subaddr_index") assert(rpcTx.subaddr_indices);  // handled by subaddr_indices
      else if (key === "subaddr_indices") {
        if (!transfer) transfer = (isOutgoing ? new MoneroOutgoingTransfer() : new MoneroIncomingTransfer()).setTx(tx);
        let rpcIndices = val;
        transfer.setAccountIndex(rpcIndices[0].major);
        if (isOutgoing) {
          let subaddressIndices = [];
          for (let rpcIndex of rpcIndices) subaddressIndices.push(rpcIndex.minor);
          transfer.setSubaddressIndices(subaddressIndices);
        } else {
          assert.equal(rpcIndices.length, 1);
          transfer.setSubaddressIndex(rpcIndices[0].minor);
        }
      }
      else if (key === "destinations" || key == "recipients") {
        assert(isOutgoing);
        let destinations = [];
        for (let rpcDestination of val) {
          let destination = new MoneroDestination();
          destinations.push(destination);
          for (let destinationKey of Object.keys(rpcDestination)) {
            if (destinationKey === "address") destination.setAddress(rpcDestination[destinationKey]);
            else if (destinationKey === "amount") destination.setAmount(new BigInteger(rpcDestination[destinationKey]));
            else throw new MoneroError("Unrecognized transaction destination field: " + destinationKey);
          }
        }
        if (transfer === undefined) transfer = new MoneroOutgoingTransfer({tx: tx});
        transfer.setDestinations(destinations);
      }
      else if (key === "multisig_txset" && val !== undefined) {} // handled elsewhere; this method only builds a tx wallet
      else if (key === "unsigned_txset" && val !== undefined) {} // handled elsewhere; this method only builds a tx wallet
      else if (key === "amount_in") tx.setInputSum(new BigInteger(val));
      else if (key === "amount_out") tx.setOutputSum(new BigInteger(val));
      else if (key === "change_address") tx.setChangeAddress(val === "" ? undefined : val);
      else if (key === "change_amount") tx.setChangeAmount(new BigInteger(val));
      else if (key === "dummy_outputs") tx.setNumDummyOutputs(val);
      else if (key === "extra") tx.setExtraHex(val);
      else if (key === "ring_size") tx.setRingSize(val);
      else if (key === "spent_key_images") {
        let inputKeyImages = val.key_images;
        GenUtils.assertTrue(tx.getInputs() === undefined);
        tx.setInputs([]);
        for (let inputKeyImage of inputKeyImages) {
          tx.getInputs().push(new MoneroOutputWallet().setKeyImage(new MoneroKeyImage().setHex(inputKeyImage)).setTx(tx));
        }
      }
      else console.log("WARNING: ignoring unexpected transaction field: " + key + ": " + val);
    }
    
    // link block and tx
    if (header) tx.setBlock(new MoneroBlock(header).setTxs([tx]));
    
    // initialize final fields
    if (transfer) {
      if (tx.isConfirmed() === undefined) tx.setIsConfirmed(false);
      if (!transfer.getTx().isConfirmed()) tx.setNumConfirmations(0);
      if (isOutgoing) {
        tx.setIsOutgoing(true);
        if (tx.getOutgoingTransfer()) tx.getOutgoingTransfer().merge(transfer);
        else tx.setOutgoingTransfer(transfer);
      } else {
        tx.setIsIncoming(true);
        tx.setIncomingTransfers([transfer]);
      }
    }
    
    // return initialized transaction
    return tx;
  }
  
  static _convertRpcTxWalletWithOutput(rpcOutput) {
    
    // initialize tx
    let tx = new MoneroTxWallet();
    tx.setIsConfirmed(true);
    tx.setIsRelayed(true);
    tx.setIsFailed(false);
    
    // initialize output
    let output = new MoneroOutputWallet({tx: tx});
    for (let key of Object.keys(rpcOutput)) {
      let val = rpcOutput[key];
      if (key === "amount") output.setAmount(new BigInteger(val));
      else if (key === "spent") output.setIsSpent(val);
      else if (key === "key_image") { if ("" !== val) output.setKeyImage(new MoneroKeyImage(val)); }
      else if (key === "global_index") output.setIndex(val);
      else if (key === "tx_hash") tx.setHash(val);
      else if (key === "unlocked") tx.setIsLocked(!val);
      else if (key === "frozen") output.setIsFrozen(val);
      else if (key === "pubkey") output.setStealthPublicKey(val);
      else if (key === "subaddr_index") {
        output.setAccountIndex(val.major);
        output.setSubaddressIndex(val.minor);
      }
      else if (key === "block_height") tx.setBlock(new MoneroBlock().setHeight(val).setTxs([tx]));
      else console.log("WARNING: ignoring unexpected transaction field: " + key + ": " + val);
    }
    
    // initialize tx with output
    tx.setOutputs([output]);
    return tx;
  }
  
  static _convertRpcDescribeTransfer(rpcDescribeTransferResult) {
    let txSet = new MoneroTxSet();
    for (let key of Object.keys(rpcDescribeTransferResult)) {
      let val = rpcDescribeTransferResult[key];
      if (key === "desc") {
        txSet.setTxs([]);
        for (let txMap of val) {
          let tx = MoneroWalletRpc._convertRpcTxWithTransfer(txMap, undefined, true);
          tx.setTxSet(txSet);
          txSet.getTxs().push(tx);
        }
      }
      else if (key === "summary") { } // TODO: support tx set summary fields?
      else console.log("WARNING: ignoring unexpected descdribe transfer field: " + key + ": " + val);
    }
    return txSet;
  }
  
  /**
   * Decodes a "type" from monero-wallet-rpc to initialize type and state
   * fields in the given transaction.
   * 
   * TODO: these should be safe set
   * 
   * @param rpcType is the type to decode
   * @param tx is the transaction to decode known fields to
   * @return {boolean} true if the rpc type indicates outgoing xor incoming
   */
  static _decodeRpcType(rpcType, tx) {
    let isOutgoing;
    if (rpcType === "in") {
      isOutgoing = false;
      tx.setIsConfirmed(true);
      tx.setInTxPool(false);
      tx.setIsRelayed(true);
      tx.setRelay(true);
      tx.setIsFailed(false);
      tx.setIsMinerTx(false);
    } else if (rpcType === "out") {
      isOutgoing = true;
      tx.setIsConfirmed(true);
      tx.setInTxPool(false);
      tx.setIsRelayed(true);
      tx.setRelay(true);
      tx.setIsFailed(false);
      tx.setIsMinerTx(false);
    } else if (rpcType === "pool") {
      isOutgoing = false;
      tx.setIsConfirmed(false);
      tx.setInTxPool(true);
      tx.setIsRelayed(true);
      tx.setRelay(true);
      tx.setIsFailed(false);
      tx.setIsMinerTx(false);  // TODO: but could it be?
    } else if (rpcType === "pending") {
      isOutgoing = true;
      tx.setIsConfirmed(false);
      tx.setInTxPool(true);
      tx.setIsRelayed(true);
      tx.setRelay(true);
      tx.setIsFailed(false);
      tx.setIsMinerTx(false);
    } else if (rpcType === "block") {
      isOutgoing = false;
      tx.setIsConfirmed(true);
      tx.setInTxPool(false);
      tx.setIsRelayed(true);
      tx.setRelay(true);
      tx.setIsFailed(false);
      tx.setIsMinerTx(true);
    } else if (rpcType === "failed") {
      isOutgoing = true;
      tx.setIsConfirmed(false);
      tx.setInTxPool(false);
      tx.setIsRelayed(true);
      tx.setRelay(true);
      tx.setIsFailed(true);
      tx.setIsMinerTx(false);
    } else {
      throw new MoneroError("Unrecognized transfer type: " + rpcType);
    }
    return isOutgoing;
  }
  
  /**
   * Merges a transaction into a unique set of transactions.
   *
   * @param {MoneroTxWallet} tx - the transaction to merge into the existing txs
   * @param {Object} txMap - maps tx hashes to txs
   * @param {Object} blockMap - maps block heights to blocks
   */
  static _mergeTx(tx, txMap, blockMap) {
    assert(tx.getHash() !== undefined);
    
    // merge tx
    let aTx = txMap[tx.getHash()];
    if (aTx === undefined) txMap[tx.getHash()] = tx; // cache new tx
    else aTx.merge(tx); // merge with existing tx
    
    // merge tx's block if confirmed
    if (tx.getHeight() !== undefined) {
      let aBlock = blockMap[tx.getHeight()];
      if (aBlock === undefined) blockMap[tx.getHeight()] = tx.getBlock(); // cache new block
      else aBlock.merge(tx.getBlock()); // merge with existing block
    }
  }
  
  /**
   * Compares two transactions by their height.
   */
  static _compareTxsByHeight(tx1, tx2) {
    if (tx1.getHeight() === undefined && tx2.getHeight() === undefined) return 0; // both unconfirmed
    else if (tx1.getHeight() === undefined) return 1;   // tx1 is unconfirmed
    else if (tx2.getHeight() === undefined) return -1;  // tx2 is unconfirmed
    let diff = tx1.getHeight() - tx2.getHeight();
    if (diff !== 0) return diff;
    return tx1.getBlock().getTxs().indexOf(tx1) - tx2.getBlock().getTxs().indexOf(tx2); // txs are in the same block so retain their original order
  }
  
  /**
   * Compares two transfers by ascending account and subaddress indices.
   */
  static _compareIncomingTransfers(t1, t2) {
    if (t1.getAccountIndex() < t2.getAccountIndex()) return -1;
    else if (t1.getAccountIndex() === t2.getAccountIndex()) return t1.getSubaddressIndex() - t2.getSubaddressIndex();
    return 1;
  }
  
  /**
   * Compares two outputs by ascending account and subaddress indices.
   */
  static _compareOutputs(o1, o2) {
    
    // compare by height
    let heightComparison = MoneroWalletRpc._compareTxsByHeight(o1.getTx(), o2.getTx());
    if (heightComparison !== 0) return heightComparison;
    
    // compare by account index, subaddress index, output index, then key image hex
    let compare = o1.getAccountIndex() - o2.getAccountIndex();
    if (compare !== 0) return compare;
    compare = o1.getSubaddressIndex() - o2.getSubaddressIndex();
    if (compare !== 0) return compare;
    compare = o1.getIndex() - o2.getIndex();
    if (compare !== 0) return compare;
    return o1.getKeyImage().getHex().localeCompare(o2.getKeyImage().getHex());
  }
}

/**
 * Polls monero-wallet-rpc to provide listener notifications.
 * 
 * @class
 * @ignore
 */
class WalletPoller {
  
  constructor(wallet) {
    let that = this;
    this._wallet = wallet;
    this._looper = new TaskLooper(async function() { await that.poll(); });
    this._prevLockedTxs = [];
    this._prevUnconfirmedNotifications = new Set(); // tx hashes of previous notifications
    this._prevConfirmedNotifications = new Set(); // tx hashes of previously confirmed but not yet unlocked notifications
    this._threadPool = new ThreadPool(1); // synchronize polls
    this._numPolling = 0;
  }
  
  setIsPolling(isPolling) {
    this._isPolling = isPolling;
    if (isPolling) this._looper.start(this._wallet.syncPeriodInMs);
    else this._looper.stop();
  }
  
  setPeriodInMs(periodInMs) {
    this._looper.setPeriodInMs(periodInMs);
  }
  
  async poll() {
    
    // synchronize polls
    let that = this;
    return this._threadPool.submit(async function() {
      try {
        
        // skip if next poll is already queued
        if (that._numPolling > 1) return;
        that._numPolling++;
        
        // skip if wallet is closed
        if (await that._wallet.isClosed()) return;
        
        // take initial snapshot
        if (that._prevHeight === undefined) {
          that._prevHeight = await that._wallet.getHeight();
          that._prevLockedTxs = await that._wallet.getTxs(new MoneroTxQuery().setIsLocked(true));
          that._prevBalances = await that._wallet._getBalances();
          that._numPolling--;
          return;
        }
        
        // announce height changes
        let height = await that._wallet.getHeight();
        if (that._prevHeight !== height) {
          for (let i = that._prevHeight; i < height; i++) await that._onNewBlock(i);
          that._prevHeight = height;
        }
        
        // get locked txs for comparison to previous
        let minHeight = Math.max(0, height - 70); // only monitor recent txs
        let lockedTxs = await that._wallet.getTxs(new MoneroTxQuery().setIsLocked(true).setMinHeight(minHeight).setIncludeOutputs(true));
        
        // collect hashes of txs no longer locked
        let noLongerLockedHashes = [];
        for (let prevLockedTx of that._prevLockedTxs) {
          if (that._getTx(lockedTxs, prevLockedTx.getHash()) === undefined) {
            noLongerLockedHashes.push(prevLockedTx.getHash());
          }
        }
        
        // save locked txs for next comparison
        that._prevLockedTxs = lockedTxs;
        
        // fetch txs which are no longer locked
        let unlockedTxs = noLongerLockedHashes.length === 0 ? [] : await that._wallet.getTxs(new MoneroTxQuery().setIsLocked(false).setMinHeight(minHeight).setHashes(noLongerLockedHashes).setIncludeOutputs(true), []); // ignore missing tx hashes which could be removed due to re-org
         
        // announce new unconfirmed and confirmed outputs
        for (let lockedTx of lockedTxs) {
          let searchSet = lockedTx.isConfirmed() ? that._prevConfirmedNotifications : that._prevUnconfirmedNotifications;
          let unannounced = !searchSet.has(lockedTx.getHash());
          searchSet.add(lockedTx.getHash());
          if (unannounced) await that._notifyOutputs(lockedTx);
        }
        
        // announce new unlocked outputs
        for (let unlockedTx of unlockedTxs) {
          that._prevUnconfirmedNotifications.delete(unlockedTx.getHash());
          that._prevConfirmedNotifications.delete(unlockedTx.getHash());
          await that._notifyOutputs(unlockedTx);
        }
        
        // announce balance changes
        await that._checkForChangedBalances();
        that._numPolling--;
      } catch (err) {
        that._numPolling--;
        console.error("Failed to background poll " + await that._wallet.getPath());
        console.error(err);
      }
    });
  }
  
  async _onNewBlock(height) {
    for (let listener of this._wallet.getListeners()) await listener.onNewBlock(height);
  }
  
  async _notifyOutputs(tx) {
  
    // notify spent outputs // TODO (monero-project): monero-wallet-rpc does not allow scrape of tx inputs so providing one input with outgoing amount
    if (tx.getOutgoingTransfer() !== undefined) {
      assert(tx.getInputs() === undefined);
      let output = new MoneroOutputWallet()
          .setAmount(tx.getOutgoingTransfer().getAmount().add(tx.getFee()))
          .setAccountIndex(tx.getOutgoingTransfer().getAccountIndex())
          .setSubaddressIndex(tx.getOutgoingTransfer().getSubaddressIndices().length === 1 ? tx.getOutgoingTransfer().getSubaddressIndices()[0] : undefined) // initialize if transfer sourced from single subaddress
          .setTx(tx);
      tx.setInputs([output]);
      for (let listener of this._wallet.getListeners()) await listener.onOutputSpent(output);
    }
    
    // notify received outputs
    if (tx.getIncomingTransfers() !== undefined) {
      if (tx.getOutputs() !== undefined && tx.getOutputs().length > 0) { // TODO (monero-project): outputs only returned for confirmed txs
        for (let output of tx.getOutputs()) {
          for (let listener of this._wallet.getListeners()) await listener.onOutputReceived(output);
        }
      } else { // TODO (monero-project): monero-wallet-rpc does not allow scrape of unconfirmed received outputs so using incoming transfer values
        let outputs = [];
        for (let transfer of tx.getIncomingTransfers()) {
          outputs.push(new MoneroOutputWallet()
              .setAccountIndex(transfer.getAccountIndex())
              .setSubaddressIndex(transfer.getSubaddressIndex())
              .setAmount(transfer.getAmount())
              .setTx(tx));
        }
        tx.setOutputs(outputs);
        for (let listener of this._wallet.getListeners()) {
          for (let output of tx.getOutputs()) await listener.onOutputReceived(output);
        }
      }
    }
  }
  
  _getTx(txs, txHash) {
    for (let tx of txs) if (txHash === tx.getHash()) return tx;
    return undefined;
  }
  
  async _checkForChangedBalances() {
    let balances = await this._wallet._getBalances();
    if (balances[0].compare(this._prevBalances[0]) !== 0 || balances[1].compare(this._prevBalances[1]) !== 0) {
      this._prevBalances = balances;
      for (let listener of await this._wallet.getListeners()) await listener.onBalancesChanged(balances[0], balances[1]);
      return true;
    }
    return false;
  }
}

MoneroWalletRpc.DEFAULT_SYNC_PERIOD_IN_MS = 20000; // default period between syncs in ms (defined by DEFAULT_AUTO_REFRESH_PERIOD in wallet_rpc_server.cpp)

module.exports = MoneroWalletRpc;