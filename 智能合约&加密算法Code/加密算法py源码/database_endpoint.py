from flask import Flask, request, g
from flask_restful import Resource, Api
from sqlalchemy import create_engine, select, MetaData, Table
from flask import jsonify
import json
import eth_account
import algosdk
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import load_only

from models import Base, Order, Log
engine = create_engine('sqlite:///orders.db')
Base.metadata.bind = engine
DBSession = sessionmaker(bind=engine)

app = Flask(__name__)

#These decorators allow you to use g.session to access the database inside the request code
@app.before_request
def create_session():
    g.session = scoped_session(DBSession) #g is an "application global" https://flask.palletsprojects.com/en/1.1.x/api/#application-globals

@app.teardown_appcontext
def shutdown_session(response_or_exc):
    g.session.commit()
    g.session.remove()

"""
-------- Helper methods (feel free to add your own!) -------
"""

def log_message(d):
    # Takes input dictionary d and writes it to the Log table
    pass

def verify(content):
    
    result = False
    
    if content['payload']['platform'] == "Ethereum":
        eth_account.Account.enable_unaudited_hdwallet_features()
        acct, mnemonic = eth_account.Account.create_with_mnemonic()
        
        eth_pk = acct.address
        eth_sk = acct.key

        payload = json.dumps(content['payload'])
        eth_encoded_msg = eth_account.messages.encode_defunct(text=payload)
        eth_sig_obj = content
        pk = eth_account.Account.recover_message(eth_encoded_msg,signature=content['sig'])
        
        if pk == content['payload']['sender_pk']:
            result = True
        else:
            result = False
        
    elif content['payload']['platform'] == "Algorand":
        payload = json.dumps(content['payload'])
        
        algo_sk, algo_pk = algosdk.account.generate_account()
        algo_sig_str = algosdk.util.sign_bytes(payload.encode('utf-8'),algo_sk)

        if algosdk.util.verify_bytes(payload.encode('utf-8'),content['sig'],content['payload']['sender_pk']):
            result = True
        else:
            result = False

    #Check if signature is valid
    return result

"""
---------------- Endpoints ----------------
"""

@app.route('/trade', methods=['POST'])
def trade():
    if request.method == "POST":
        content = request.get_json(silent=True)
        print( f"content = {json.dumps(content)}" )
        columns = [ "sender_pk", "receiver_pk", "buy_currency", "sell_currency", "buy_amount", "sell_amount", "platform" ]
        fields = [ "sig", "payload" ]
        error = False
        for field in fields:
            if not field in content.keys():
                print( f"{field} not received by Trade" )
                print( json.dumps(content) )
                log_message(content)
                return jsonify( False )
        
        error = False
        for column in columns:
            if not column in content['payload'].keys():
                print( f"{column} not received by Trade" )
                error = True
        if error:
            print( json.dumps(content) )
            log_message(content)
            return jsonify( False )
            
        #Your code here
        #Note that you can access the database session using g.session
        if verify(content) == True:
            #Insert the order
            order_obj = Order( sender_pk=content['payload']['sender_pk'], \
                receiver_pk=content['payload']['receiver_pk'], \
                buy_currency=content['payload']['buy_currency'], \
                sell_currency=content['payload']['sell_currency'], \
                buy_amount=content['payload']['buy_amount'], \
                sell_amount=content['payload']['sell_amount'], \
                signature=content['sig'])
            #fields = ['sender_pk','receiver_pk','buy_currency','sell_currency','buy_amount','sell_amount','signature']
            #order_obj = Order(**{f:order[f] for f in fields})
            
            g.session.add(order_obj)
            g.session.commit()
        else:
            content = json.dumps(content)
            log_message(content)
    return ""

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

if __name__ == '__main__':
    app.run(port='5002')
