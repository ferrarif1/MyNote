import hashlib
import os
import string
import random

def hash_collision(k):
    if not isinstance(k,int):
        print( "hash_collision expects an integer" )
        return( b'\x00',b'\x00' )
    if k < 0:
        print( "Specify a positive number of bits" )
        return( b'\x00',b'\x00' )
   
    #Collision finding code goes here
    letters = string.ascii_letters
    strX = ''.join(random.choice(letters) for i in range(256))
    x = strX.encode('utf-8')
    strY = ''.join(random.choice(letters) for i in range(256))
    y = strY.encode('utf-8')
    
    isCollision = 0
    while (isCollision == 0):
        hashX = hashlib.sha256(x).digest()
        hashY = hashlib.sha256(y).digest()
        intX = int.from_bytes(hashX, 'big')
        intY = int.from_bytes(hashY, 'big')
        binX = bin(intX)
        binY = bin(intY)
        if (binX[(len(binX)-k):] == binY[(len(binY)-k):]):
            isCollision = 1
        else:
            strY = ''.join(random.choice(letters) for i in range (256))
            y = strY.encode('utf-8')

    return (x, y)
    #x = b'\x00'
    #y = b'\x00'
