#!/usr/bin/env python
# coding=utf8
import tushare as ts
import requests
import re

jj_list = [
           '110011',
           '009326',
           '470006',
           '005919',
           '519674',
           '005885', 
           '001210', 
           '161028', 
           '003511', '003634', '005621', '006229', '001638', 
           '005911', 
           '162703', 
           '005542', 
           '004642', 
           '320007','161725', '160222']
def m(init=100000, pay=100000, rate=0.3, y=20):
    print('初始资金{}，每年固定收入{}，年收益{}，累加年限{}。'.format(init, pay, rate, y))
    for i in range(y):
        init += init * rate + pay
        print('第{}年, 收入: {}'.format(i+1, init))

def jj():
    print(ts.get_index()[:1])
    for i in jj_list:
        print(requests.get('http://fundgz.1234567.com.cn/js/{}.js'.format(i)).text)

def jjs():
    print(ts.get_index()[:1])
    for i in jj_list:
        a = requests.get('http://fundgz.1234567.com.cn/js/{}.js'.format(i)).text
        print(re.findall('name":"(.*?)".*?gszzl":"(.*?)"', a)[0])
        if jj_list.index(i) == 5:
            print('-'*50)

def gp():
    print(ts.get_index()[:1])
    print(ts.get_index()[12:13])
    print(ts.get_index()[17:18])
    df=ts.get_realtime_quotes(['002291', '002939', '002475', '000034', '601607', '000100','002241','601099', '600728', '000998', '601800'])[['code','name','price','bid','ask','volume','amount','time']]
    print(df, end='\n{0}\n'.format('-'*50))
    
    sh = ts.get_index()[:1][['amount']].values[0][0]
    sz = ts.get_index()[12:13][['amount']].values[0][0]
    print('沪深成交额:{:.2f}亿'.format(float(sh)+float(sz)))

def take_cost(target_cost, now_cost, now_hold, now_price=None, code='000100'):
    """ take_cost(target_cost=19.8, now_cost=20.834, now_hold=6200, now_price=16,code='002241')
        take_cost(target_cost=9, now_cost=9.4, now_hold=700, now_price=8, code='600728')
        take_cost(target_cost=5.8, now_cost=7.4, now_hold=6100, now_price=4, code='000100')
        (7.044-4.8) * 6100 / (4.8-4.24)
        当前成本7.044；目标成本4.8；当前价4.24；当前持有6100
    """
    if now_price:
        name = '自定义'
    else:
        name, now_price = ts.get_realtime_quotes([code])[['name', 'price']].values[0]
        now_price = float(now_price)
    need_patch = (now_cost - target_cost) * now_hold / (target_cost - now_price)
    print("{} 当前价格{}, 持股 {}, 成本 {}, 如果想补仓后达到成本 {} 元:".format(name, now_price, now_hold, now_cost, target_cost))
    print("需要补仓{:.2f}股".format(float(need_patch) + 1))
    print("需要资金{:.2f}元".format(float(need_patch) * now_price))

def cover(need_patch, now_cost, now_hold, now_price=None, code='000100'):
    """ 计算补仓后的成本是多少
        cover(need_patch=1000, now_cost=9.338, now_hold=3100, code='000100')
        当前成本7.044；目标成本4.8；当前价4.24；当前持有6100
    """
    if now_price:
        name = '自定义'
    else:
        name, now_price = ts.get_realtime_quotes([code])[['name', 'price']].values[0]
        now_price = float(now_price)
    target_cost = (now_cost * now_hold + need_patch * now_price) / (need_patch+now_hold)
    print("{} 当前价格{}, 持股 {}, 成本 {}, 补仓{}股后达到成本 {:.2f} 元:".format(name, now_price, now_hold, now_cost, need_patch, target_cost))
    print("需要资金{:.2f}元".format(float(need_patch) * now_price))

def sell_tax(money):
    """卖出成本计算
       印花税：stamp = money * 0.001
       券商佣金：commission = money * 0.00025 至少5元
    """
    stamp = money * 0.001
    commission = money * 0.0002
    commission = 5 if commission < 5 else commission
    sum = stamp + commission
    print("卖出{}, 印花税:{}, 佣金: {}".format(money, stamp, commission))
    print("扣税: {}, 税后: {}".format(sum, money-sum))

if __name__ == '__main__':
    m()
