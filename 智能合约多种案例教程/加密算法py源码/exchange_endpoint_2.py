from flask import Flask, request, g
from flask_restful import Resource, Api
from sqlalchemy import create_engine
from flask import jsonify
import json
import eth_account
import algosdk
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import load_only
from datetime import datetime
import sys

from models import Base, Order, Log
engine = create_engine('sqlite:///orders.db')
Base.metadata.bind = engine
DBSession = sessionmaker(bind=engine)

app = Flask(__name__)

@app.before_request
def create_session():
    g.session = scoped_session(DBSession)

@app.teardown_appcontext
def shutdown_session(response_or_exc):
    sys.stdout.flush()
    g.session.commit()
    g.session.remove()


""" Suggested helper methods """

#Check if signature is valid
def check_sig(payload,sig):
    result = False
    
    if payload['platform'] == "Ethereum":
        eth_account.Account.enable_unaudited_hdwallet_features()
        acct, mnemonic = eth_account.Account.create_with_mnemonic()
        
        eth_pk = acct.address
        eth_sk = acct.key

        payloadtxt = json.dumps(payload)
        eth_encoded_msg = eth_account.messages.encode_defunct(text=payloadtxt)
        eth_sig_obj = payload
        pk = eth_account.Account.recover_message(eth_encoded_msg,signature=sig)
        
        if pk == payload['sender_pk']:
            result = True
        else:
            result = False
        
    elif payload['platform'] == "Algorand":
        payloadtxt = json.dumps(payload)
        
        algo_sk, algo_pk = algosdk.account.generate_account()
        algo_sig_str = algosdk.util.sign_bytes(payloadtxt.encode('utf-8'),algo_sk)

        if algosdk.util.verify_bytes(payloadtxt.encode('utf-8'),sig,payload['sender_pk']):
            result = True
        else:
            result = False

    return result

def fill_order(order,txes=[]):
    for orderToMatch in g.session.query(Order).filter(Order.filled == None):
        possibleOrder = g.session.query(Order).filter(Order.filled == None, Order.buy_currency == orderToMatch.sell_currency, Order.sell_currency == orderToMatch.buy_currency,\
        (Order.sell_amount / Order.buy_amount) >= (orderToMatch.buy_amount / orderToMatch.sell_amount)).first()
        
        if possibleOrder != None and orderToMatch.filled == None:
            orderToMatch.filled = datetime.now()
            orderToMatch.counterparty_id = possibleOrder.id
            g.session.commit()
            
            possibleOrder.filled = datetime.now()
            possibleOrder.counterparty_id = orderToMatch.id
            g.session.commit()
            
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
                g.session.add(order_obj)
                g.session.commit()

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
                g.session.add(order_obj)
                g.session.commit()
    pass
  
def log_message(d):
    # Takes input dictionary d and writes it to the Log table
    # Hint: use json.dumps or str() to get it in a nice string form
    pass

""" End of helper methods """



@app.route('/trade', methods=['POST'])
def trade():
    print("In trade endpoint")
    if request.method == "POST":
        content = request.get_json(silent=True)
        print( f"content = {json.dumps(content)}" )
        columns = [ "sender_pk", "receiver_pk", "buy_currency", "sell_currency", "buy_amount", "sell_amount", "platform" ]
        fields = [ "sig", "payload" ]

        for field in fields:
            if not field in content.keys():
                print( f"{field} not received by Trade" )
                print( json.dumps(content) )
                log_message(content)
                return jsonify( False )
        
        for column in columns:
            if not column in content['payload'].keys():
                print( f"{column} not received by Trade" )
                print( json.dumps(content) )
                log_message(content)
                return jsonify( False )
            
        #Your code here
        #Note that you can access the database session using g.session
        # TODO: Check the signature
        if check_sig(content["payload"],content["sig"]) == False:
            return jsonify(False)
        
        # TODO: Add the order to the database
        fields = ['sender_pk','receiver_pk','buy_currency','sell_currency','buy_amount','sell_amount']
        order_obj = Order(**{f:content["payload"][f] for f in fields})
        g.session.add(order_obj)
        g.session.commit
        
        # TODO: Fill the order
        fill_order(order_obj, [])
        
        # TODO: Be sure to return jsonify(True) or jsonify(False) depending on if the method was successful
        return jsonify(True)

@app.route('/order_book')
def order_book():
    #Your code here
    #Note that you can access the database session using g.session
    data = g.session.query(Order)
    result = []
    for d in data:
        dic = {}
        dic['sender_pk'] = d.sender_pk
        dic['receiver_pk'] = d.receiver_pk
        dic['buy_currency'] = d.buy_currency
        dic['sell_currency'] = d.sell_currency
        dic['buy_amount'] = d.buy_amount
        dic['sell_amount'] = d.sell_amount
        dic['signature'] = d.signature
        result.append(dic)
    resultDict = {'data': result}
    return resultDict
    return jsonify(result)

if __name__ == '__main__':
    app.run(port='5002')
