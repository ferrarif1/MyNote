from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, ForeignKey, Integer, String, Table, Float, DateTime, Enum
from sqlalchemy.orm import relationship
from sqlalchemy import create_engine
from datetime import datetime
from sqlalchemy.orm import backref
Base = declarative_base()

PLATFORMS = ['Algorand','Ethereum']

class Order(Base):
    __tablename__ = 'orders'
    id = Column(Integer,primary_key=True)
    receiver_pk = Column( String(256) )
    sender_pk = Column( String(256) )
    tx_id = Column(String(256))
    buy_currency = Column(Enum(*PLATFORMS))
    sell_currency = Column(Enum(*PLATFORMS))
    buy_amount = Column(Integer,default=0)
    sell_amount = Column(Integer,default=0)
    signature = Column(String(256))
    timestamp = Column(DateTime,default=datetime.now()) #When was the order inserted into the database
    counterparty_id = Column(Integer,ForeignKey('orders.id')) #If the order was filled (or partially filled) the order_id of the order that acted as the counterparty
    counterparty = relationship("Order",foreign_keys='Order.counterparty_id') #The Order object referenced by counterparty_id
    filled = Column(DateTime) #When was the order filled
    creator_id = Column(Integer,ForeignKey('orders.id')) #For derived orders: the order ID of the order that this order was derived from
    child = relationship("Order", foreign_keys='Order.creator_id', backref=backref('creator', remote_side=[id])) #set "child" and "creator" to be the derived Order and creating Order objects associated. 

class TX(Base):
    __tablename__ = 'txes'
    id = Column(Integer,primary_key=True)
    platform = Column(Enum(*PLATFORMS))
    receiver_pk = Column(String(256))
    order_id = Column(Integer,ForeignKey('orders.id')) #The id of the order that 
    order = relationship("Order", foreign_keys='TX.order_id' )
    tx_id = Column(String(256))

class Log(Base):
    __tablename__ = 'log'
    id = Column(Integer,primary_key=True)
    logtime = Column(DateTime,default=datetime.now())
    message = Column(String(1000))

engine = create_engine('sqlite:///orders.db')
Base.metadata.create_all(engine)

