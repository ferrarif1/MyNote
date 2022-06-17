import hashlib
class Block:
    def __init__(self, index, timestamp, content, previous_hash):
      self.index = index
      self.timestamp = timestamp
      self.content = content
      self.previous_hash = previous_hash
      self.hash = self.calc_hash()
   
    def calc_hash(self):
      sha = hashlib.sha256()
      sha.update(str(self.index).encode('utf-8') + 
                 str(self.timestamp).encode('utf-8') + 
                 str(self.content).encode('utf-8') + 
                 str(self.previous_hash).encode('utf-8'))
      return sha.hexdigest()
      
M4BlockChain = []

from datetime import datetime
def create_genesis_block():
    return Block(0, datetime.now(), "Genesis Block", "0")
    
M4BlockChain.append(create_genesis_block())


# write a function `next_block` to generate a block
def next_block(last_block):
    block_index = last_block.index + 1
    block_content = "This is block " + str(block_index)
    return Block(block_index, datetime.now(), block_content, last_block.hash)
    
# append 5 blocks to the blockchain
def app_five(block_list):
    for x in range(5):
      last_block_on_list = block_list[len(block_list) -1]
      block_list.append(next_block(last_block_on_list))
    return

