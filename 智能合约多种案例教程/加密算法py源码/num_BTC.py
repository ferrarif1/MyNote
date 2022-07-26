import math

def num_BTC(b):
    currentBlock = 1
    currentReward = float(50)
    c = float(50)
    while currentBlock != b:
        if currentBlock % 210000 == 0:
            currentBlock = currentBlock + 1
            currentReward = currentReward / 2
            c = c + currentReward
        else:
            c = c + currentReward
            currentBlock = currentBlock + 1
    return c


