import random

#alpha: selfish miners mining power (percentage),
#gamma: the ratio of honest miners choose to mine on the selfish miners pool's block
#N: number of simulations run
def Simulate(alpha,gamma,N, seed):
    
    # DO NOT CHANGE. This is used to test your function despite randomness
    random.seed(seed)
  
    #the same as the state of the state machine in the slides 
    state=0
    # the length of the blockchain
    ChainLength=0
    # the revenue of the selfish mining pool
    SelfishRevenue=0

    #A round begin when the state=0
    for i in range(N):
        r=random.random()
        if state==0:
            #The selfish pool has 0 hidden block.
            if r<=alpha:
                #The selfish pool mines a block.
                #They don't publish it. 
                state=1
            else:
                #The honest miners found a block.
                #The round is finished : the honest miners found 1 block
                # and the selfish miners found 0 block.
                ChainLength+=1
                state=0

        elif state==1:
            #The selfish pool has 1 hidden block.
            if r<=alpha:
                #The selfish miners found a new block.
                #Write a piece of code to change the required variables.
                #You might need to define new variable to keep track of the number of hidden blocks.
                state+=1
            else:
                #Write a piece of code to change the required variables.
                state=-1

        elif state==-1:
            #It's the state 0' in the slides (the paper of Eyal and Gun Sirer)
            #There are three situations! 
            #Write a piece of code to change the required variables in each one.
            if r<=alpha:
                SelfishRevenue+=2
                ChainLength+=2
                state=0
            elif r<=alpha+(1-alpha)*gamma:
                SelfishRevenue+=1
                ChainLength+=2
                state=0
            else:
                ChainLength+=2
                state=0

        elif state==2:
            #The selfish pool has 2 hidden block.
            if r<=alpha:
                state+=1
            else:
                #The honest miners found a block.
                SelfishRevenue+=2
                ChainLength+=2
                state=0
        elif state>2:
            if r<=alpha:
                #The selfish miners found a new block
                state+=1
            else:
                #The honest miners found a block
                SelfishRevenue+=1
                ChainLength+=1
                state-=1

    return float(SelfishRevenue)/ChainLength


""" 
  Uncomment out the following lines to try out your code
  DON'T include it in your final submission though.
"""

"""
#let's run the code with the follwing parameters!
alpha=0.35
gamma=0.5
Nsimu=10**7
seed = 100
#This is the theoretical probability computed in the original paper
print("Theoretical probability :",(alpha*(1-alpha)**2*(4*alpha+gamma*(1-2*alpha))-alpha**3)/(1-alpha*(1+(2-alpha)*alpha)))
print("Simulated probability :",Simulate(alpha,gamma,Nsimu, seed))
"""