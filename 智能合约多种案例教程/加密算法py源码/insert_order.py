from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import random
from models import Base, Order

engine = create_engine('sqlite:///orders.db')
Base.metadata.bind = engine
DBSession = sessionmaker(bind=engine)
session = DBSession()

platforms = ["Algorand", "Ethereum"] 
platform = "Ethereum"
sender_pk = hex(random.randint(0,2**256))[2:] #Generate random string that looks like a public key
receiver_pk = hex(random.randint(0,2**256))[2:] #Generate random string that looks like a public key

other_platform = platforms[1-platforms.index(platform)]

#Generate random order data
order = {}
order['sender_pk'] = sender_pk
order['receiver_pk'] = receiver_pk
order['buy_currency'] = other_platform
order['sell_currency'] = platform
order['buy_amount'] = random.randint(1,10)
order['sell_amount'] = random.randint(1,10)


#Insert the order
order_obj = Order( sender_pk=order['sender_pk'],receiver_pk=order['receiver_pk'], buy_currency=order['buy_currency'], sell_currency=order['sell_currency'], buy_amount=order['buy_amount'], sell_amount=order['sell_amount'] )

#Alternatively, this code inserts the same record and is arguably more readable
fields = ['sender_pk','receiver_pk','buy_currency','sell_currency','buy_amount','sell_amount']
order_obj = Order(**{f:order[f] for f in fields})

session.add(order_obj)
session.commit()
