from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import random
from models import Base, Order
import progressbar

engine = create_engine('sqlite:///orders.db')
Base.metadata.bind = engine
DBSession = sessionmaker(bind=engine)
session = DBSession()

#Clear tables
session.query(Order).delete()
session.commit()

def make_order(platform):
    platforms = ["Algorand", "Ethereum"]
    assert platform in platforms
    other_platform = platforms[1-platforms.index(platform)]
    order = {}
    order['buy_currency'] = other_platform
    order['sell_currency'] = platform
    order['buy_amount'] = random.randint(1,10)
    order['sell_amount'] = random.randint(1,10)
    order['sender_pk'] = hex(random.randint(0,2**256))[2:] 
    order['receiver_pk'] = hex(random.randint(0,2**256))[2:] 
    return order

from order_book import process_order

order_list = [] 
num_orders=100
bar = progressbar.ProgressBar(max_value=num_orders, widgets=[progressbar.Bar('=', '[', ']'), ' ', progressbar.Percentage()])
for i in range(num_orders):
    bar.update(i+1)
    platforms = ["Algorand", "Ethereum"]
    order_dict = make_order( platforms[random.randint(0,1)] )
    order_list.append(order_dict)
    process_order(order_dict)
bar.finish()

