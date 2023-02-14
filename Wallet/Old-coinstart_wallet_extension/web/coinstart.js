
const __globalPromiseHandlerMap = {};

function generateUUID() {
    var d = new Date().getTime();
    var d2 = ((typeof performance !== 'undefined') && performance.now && (performance.now() * 1000)) || 0;
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16;
        if (d > 0) {
            r = (d + r) % 16 | 0;
            d = Math.floor(d / 16);
        } else {
            r = (d2 + r) % 16 | 0;
            d2 = Math.floor(d2 / 16);
        }
        return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
    });
}

function createMessage(
    payload,
    id
) {
    return {
        id: id || generateUUID(),
        payload,
//        hostname
    };
}

const ALL_PERMISSION_TYPES = [
    'viewAccount',
    'suggestTransactions',
];

//
//class DAppInterface  {
//  name: string;
//  connected: boolean;
//  connecting: boolean;
//  windowMsgStream: WindowMsgStream;
//
//  constructor() {
//    this.name = 'Suiet';
//    this.connected = false;
//    this.connecting = false;
//    this.windowMsgStream = new WindowMsgStream(
//      WindowMsgTarget.DAPP,
//      WindowMsgTarget.SUIET_CONTENT
//    );
//  }
//
//  async connect(permissions) {
//    await this.windowMsgStream.post(reqData('handshake', null));
//    return await this.windowMsgStream.post(
//      reqData('dapp.connect', { permissions })
//    );
//  }
//
//  async disconnect() {
//    return await this.windowMsgStream.post(reqData('handwave', null));
//  }
//
//  // @ts-expect-error
//  async hasPermissions(permissions: readonly string[]) {
//    throw new Error('function not implemented yet');
//  }
//
//  // @ts-expect-error
//  async requestPermissions() {
//    throw new Error('function not implemented yet');
//  }
//
//  async executeMoveCall(transaction: MoveCallTransaction) {
//    return await this.windowMsgStream.post(
//      reqData('dapp.requestTransaction', {
//        type: TxRequestType.MOVE_CALL,
//        data: transaction,
//      })
//    );
//  }
//
//  // @ts-expect-error
//  async executeSerializedMoveCall(
//    transactionBytes: Uint8Array
//  ): Promise<SuiTransactionResponse> {
//    throw new Error('function not implemented yet');
//  }
//
//  async getAccounts() {
//    return await this.windowMsgStream.post<SuiAddress[]>(
//      reqData('dapp.getAccounts', null)
//    );
//  }
//
//  async signMessage(input: { message: Uint8Array }) {
//    const encodedInput = { message: baseEncode(input.message) };
//    const result = await this.windowMsgStream.post(
//      reqData('dapp.signMessage', encodedInput)
//    );
//    if (result.error) return result;
//
//    const data = result.data as {
//      signature: string;
//      signedMessage: string;
//    };
//    return {
//      ...result,
//      data: {
//        signature: baseDecode(data.signature),
//        signedMessage: baseDecode(data.signedMessage),
//      },
//    };
//  }
//
//  async getPublicKey() {
//    return await this.windowMsgStream.post(reqData('dapp.getPublicKey', null));
//  }
//}

class DAppInterface {
    /*

    */
    hasPermissions(
        permissions = ALL_PERMISSION_TYPES
    ) {
        return mapToPromise(
            this.send({
                type: 'has-permissions-request',
                permissions,
            }),
            (response) => response.result
        );
    }

    requestPermissions(
        permissions = ALL_PERMISSION_TYPES
    ) {
        return mapToPromise(
            this.send({
                type: 'acquire-permissions-request',
                permissions,
            }),
            (response) => response.result
        );
    }

    getAccounts() {
        return mapToPromise(
            this.send({
                type: 'get-account',
            }),
            (response) => response.accounts
        );
    }

    executeMoveCall(transaction) {
        return mapToPromise(
            this.send({
                type: 'execute-transaction-request',
                transaction,
            }),
            (response) => response.result
        );
    }

    executeSerializedMoveCall(transactionBytes) {
        return mapToPromise(
            this.send({
                type: 'execute-transaction-request',
                transactionBytes,
            }),
            (response) => response.result
        );
    }

    send(
        payload,
        responseForID
    ) {
        console.log('send function',payload,responseForID);
        const msg = createMessage(payload, responseForID);
        Promise.resolve().then(function (resolve,reject) {
            if(window.__SpMessageProxy) {
                window.__SpMessageProxy.postMessage(JSON.stringify(msg));
            }
        });
        return msg.id;
    }
}


function mapToPromise(responseForID, project) {
    return new Promise((resolve, reject) => {
        __globalPromiseHandlerMap[responseForID] = {
            resolve,
            reject,
            project
        };
    })
}

function isErrorPayload(payload) {
    return 'error' in payload && payload.error === true;
}

console.log('test js log');

 Object.defineProperty(window, 'coinstartWallet', {
        enumerable: false,
        configurable: false,
        value: new DAppInterface(),
    });

console.log(window);
console.log(Object.defineProperty);
console.log(window.coinstartWallet);

window.coinstartWallet.getAccounts();

console.log('test js log end');



if(!window.coinstartWallet) {
    Object.defineProperty(window, 'coinstartWallet', {
        enumerable: false,
        configurable: false,
        value: new DAppInterface(),
    });
}

if(!window.__SpMessageProxyCallback) {
    Object.defineProperty(window, '__SpMessageProxyCallback', {
        enumerable: false,
        configurable: false,
        value: function __SpMessageProxyCallback(response, msgId) {
            response = JSON.parse(response);
            const promiseHandler = __globalPromiseHandlerMap[msgId];
            if(!promiseHandler) {
                return;
            }
            if (isErrorPayload(response)) {
                promiseHandler.reject(response.message);
            } else {
                promiseHandler.resolve(promiseHandler.project(response))
            }
            delete __globalPromiseHandlerMap[msgId];
        }
    })
}
