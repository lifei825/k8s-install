#!/usr/bin/env python


class A(object):
    _ist = None

    def __new__(cls, *args, **kwargs):
        print("cls._ist:", cls._ist)
        if not cls._ist:
            print("start new ...")
            ori = super(A, cls)
            cls._ist = ori.__new__(cls, *args, **kwargs)

        return cls._ist

    def __init__(self):
        print("start init ...")


class Test(A):
    def t(self):
        print("test t")

if __name__ == "__main__":
    aa = A()
    bb = A()

    # print(aa.t())
