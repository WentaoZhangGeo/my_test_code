#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jun 17 18:14:31 2021

@author: wzhang
"""

from __future__ import division
import numpy as np
from scipy.sparse.linalg import spsolve
from scipy.sparse import coo_matrix

npzfile = np.load('PYout.npz')
# prfirst, etas1, etan1, xnum, ynum, xstp, ystp, RX1, RY1, RC1, bleft, bright, btop, bbottom
prnorm,etas,etan,xnum,ynum,xstp,ystp,RX,RY,RC,bleft,bright,btop,bbottom \
    = npzfile['prfirst'], npzfile['etas1'], npzfile['etan1'], \
      npzfile['xnum'], npzfile['ynum'], npzfile['xstp'], npzfile['ystp'], \
      npzfile['RX1'], npzfile['RY1'], npzfile['RC1'], \
      npzfile['bleft'], npzfile['bright'], npzfile['btop'], npzfile['bbottom']


# Poisson-like equations koefficients
xkf=1/xstp ** 2
xkf2=2/xstp ** 2
ykf=1/ystp ** 2
ykf2=2/ystp ** 2
xykf=1/(xstp*ystp)


# Koefficient for scaling pressure
pscale=2*etan[0]/(xstp+ystp)

# Horizontal shift index
ynum3=(ynum-1)*3


# Creating matrix
L=coo_matrix(((xnum-1)*(ynum-1)*3,(xnum-1)*(ynum-1)*3))
R=np.zeros(((xnum-1)*(ynum-1)*3,1))





def main():
    # main(prnorm,etas,etan,xnum,ynum,xstp,ystp,RX,RY,RC,bleft,bright,btop,bbottom)


    # return(vx, resx, vy, resy, pr, resc)
    pass


if __name__ == '__main__':
    main()

    # (vx1, resx1, vy1, resy1, pr1, resc1) \
    #     = main(prfirst, etas1, etan1, xnum, ynum, xstp, ystp, RX1, RY1, RC1, bleft, bright, btop, bbottom)




