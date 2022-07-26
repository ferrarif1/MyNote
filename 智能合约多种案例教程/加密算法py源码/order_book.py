from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import datetime

from models import Base, Order
engine = create_engine('sqlite:///orders.db')
Base.metadata.bind = engine
DBSession = sessionmaker(bind=engine)
session = DBSession()
  
def process_order(order):
    #First, try to commit new order
    newOrder = {}
    try:
        newOrder['sender_pk'] = order['sender_pk']
        newOrder['receiver_pk'] = order['receiver_pk']
        newOrder['buy_currency'] = order['buy_currency']
        newOrder['sell_currency'] = order['sell_currency']
        newOrder['buy_amount'] = order['buy_amount']
        newOrder['sell_amount'] = order['sell_amount']
      
        fields = ['sender_pk','receiver_pk','buy_currency','sell_currency','buy_amount','sell_amount']
        order_obj = Order(**{f:newOrder[f] for f in fields})

        session.add(order_obj)
        session.commit()
        
    except CommitException:
        pass
      
    #Second, Match the following criteria
    for orderToMatch in session.query(Order).filter(Order.filled == None):
        possibleOrder = session.query(Order).filter(Order.filled == None, Order.buy_currency == orderToMatch.sell_currency, Order.sell_currency == orderToMatch.buy_currency,\
        (Order.sell_amount / Order.buy_amount) >= (orderToMatch.buy_amount / orderToMatch.sell_amount)).first()
        
        if possibleOrder != None and orderToMatch.filled == None:
            orderToMatch.filled = datetime.now()
            orderToMatch.counterparty_id = possibleOrder.id
            session.commit()
            
            possibleOrder.filled = datetime.now()
            possibleOrder.counterparty_id = orderToMatch.id
            session.commit()
            
            if orderToMatch.buy_amount > possibleOrder.sell_amount or orderToMatch.sell_amount > possibleOrder.buy_amount:
                newOrder = {}
                newOrder['sender_pk'] = orderToMatch.sender_pk
                newOrder['receiver_pk'] = orderToMatch.receiver_pk
                newOrder['buy_currency'] = orderToMatch.buy_currency
                newOrder['sell_currency'] = orderToMatch.sell_currency
                if orderToMatch.buy_amount > possibleOrder.sell_amount:
                    newOrder['buy_amount'] = orderToMatch.buy_amount - possibleOrder.sell_amount
                    newOrder['sell_amount'] = orderToMatch.sell_amount / orderToMatch.buy_amount * newOrder['buy_amount']
                elif orderToMatch.sell_amount > possibleOrder.buy_amount:
                    newOrder['sell_amount'] = orderToMatch.sell_amount - possibleOrder.buy_amount
                    newOrder['buy_amount'] = orderToMatch.buy_amount / orderToMatch.sell_amount * newOrder['sell_amount']
                newOrder['creator_id'] = orderToMatch.id
                
                fields = ['sender_pk','receiver_pk','buy_currency','sell_currency','buy_amount','sell_amount','creator_id']
                order_obj = Order(**{f:newOrder[f] for f in fields})
                session.add(order_obj)
                session.commit()

            if orderToMatch.buy_amount < possibleOrder.sell_amount or orderToMatch.sell_amount < possibleOrder.buy_amount:
                newOrder = {}
                newOrder['sender_pk'] = possibleOrder.sender_pk
                newOrder['receiver_pk'] = possibleOrder.receiver_pk
                newOrder['buy_currency'] = possibleOrder.buy_currency
                newOrder['sell_currency'] = possibleOrder.sell_currency
                if possibleOrder.sell_amount > orderToMatch.buy_amount:
                    newOrder['sell_amount'] = possibleOrder.sell_amount - possibleOrder.buy_amount
                    newOrder['buy_amount'] = possibleOrder.buy_amount / possibleOrder.sell_amount * newOrder['sell_amount']
                elif possibleOrder.buy_amount > orderToMatch.sell_amount:
                    newOrder['buy_amount'] = possibleOrder.buy_amount - possibleOrder.sell_amount
                    newOrder['sell_amount'] = possibleOrder.sell_amount / possibleOrder.buy_amount * newOrder['buy_amount']
                newOrder['creator_id'] = possibleOrder.id
                
                fields = ['sender_pk','receiver_pk','buy_currency','sell_currency','buy_amount','sell_amount', 'creator_id']
                order_obj = Order(**{f:newOrder[f] for f in fields})
                session.add(order_obj)
                session.commit()

    
    pass
  
  
  
