from bitcoinrpc.authproxy import AuthServiceProxy, JSONRPCException

rpcuser='quaker_quorum'
rpcpassword='franklin_fought_for_continental_cash'
rpcport=8332
rpcip='3.134.159.30'

rpc_connection = AuthServiceProxy("http://%s:%s@%s:%s"%(rpcuser, rpcpassword, rpcip, rpcport))
print(rpc_connection.getblockhash(0))
print(rpc_connection.getblock("000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"))

time = 0
index = 0
hash = 0
while time < 1232100000:
  index = index + 1
  hash = rpc_connection.getblockhash(index)
  dict = rpc_connection.getblock(hash)
  time = dict['time']
print(index)
print(rpc_connection.getblock(hash))