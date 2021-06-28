#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jun 17 18:14:31 2021

@author: wzhang
"""

from __future__ import division
import numpy as np
from scipy.sparse.linalg import spsolve
from scipy.sparse import csc_matrix
from scipy.io import savemat

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
pscale=2*etan[0,0]/(xstp+ystp)

# Horizontal shift index
ynum3=(ynum-1)*3


# Creating matrix
L=csc_matrix(((xnum-1)*(ynum-1)*3,(xnum-1)*(ynum-1)*3))
R=np.zeros(((xnum-1)*(ynum-1)*3,1))

# Solving of Stokes and continuity equations on nodes
for i in range(ynum-1):
    for j in range(xnum-1):
        # Indexes for P,vx,vy
        ivx=(j * (ynum-1) + i) * 3
        ivy=ivx+1
        ipr=ivx+2

        # x-Stokes equation dSIGMAxx/dx+dSIGMAxy/dy-dP/dx=RX
        if j < xnum - 2:
            # x-Stokes equation stensil
            #     +-------------------- -+----------------------+
            #     |                      |                      |
            #     |                      |                      |
            #     |                   vx[i-1,j]                 |
            #     |                      |                      |
            #     |                      |                      |
            #     +-----vy[i-1,j]---etas[i,j+1]---vy[i-1,j+1]---+
            #     |                      |                      |
            #     |                      |                      |
            # vx[i,j-1]  pr[i,j]      vx[i,j]     P[i,j+1]   vx[i,j+1]
            #     |     etan[i,j]        |       etan[i,j+1]    |
            #     |                      |                      |
            #     +------vy[i,j]---etas[i+1,j+1]---vy[i,j+1]----+
            #     |                      |                      |
            #     |                      |                      |
            #     |                   vx[i+1,j]                 |
            #     |                      |                      |
            #     |                      |                      |
            #     +-------------------- -+----------------------+
            # Right Part
            R[ivx, 0] = RX[i + 1, j + 1]
            # Computing Current x-Stokes coefficients
            # Central Vx node
            L[ivx, ivx] = -xkf2 * (etan[i, j + 1] + etan[i, j]) - ykf * (etas[i + 1, j + 1] + etas[i, j + 1])
            # Left Vx node
            if j > 0:
                ivxleft = ivx - ynum3
                L[ivx, ivxleft] = xkf2 * etan[i, j]

            # Right Vx node
            if j < xnum - 3:
                ivxright = ivx + ynum3
                L[ivx, ivxright] = xkf2 * etan[i, j + 1]

            # Top Vx node
            if i > 0:
                ivxtop = ivx - 3
                L[ivx, ivxtop] = ykf * etas[i, j + 1]
            else:
                L[ivx, ivx] = L[ivx, ivx] + btop * ykf * etas[i, j + 1]

            # Bottom Vx node
            if i < ynum - 2:
                ivxbottom = ivx + 3
                L[ivx, ivxbottom] = ykf * etas[i + 1, j + 1]
            else:
                L[ivx, ivx] = L[ivx, ivx] + bbottom * ykf * etas[i + 1, j + 1]

            # Top Left Vy node
            if i > 0:
                ivytopleft = ivx - 3 + 1
                L[ivx, ivytopleft] = xykf * etas[i, j + 1]

            # Top Right Vy node
            if i > 0:
                ivytopright = ivx - 3 + 1 + ynum3
                L[ivx, ivytopright] = -xykf * etas[i, j + 1]

            # Bottom Left Vy node
            if i < ynum - 2:
                ivybottomleft = ivx + 1
                L[ivx, ivybottomleft] = -xykf * etas[i + 1, j + 1]

            # Bottom Right Vy node
            if i < ynum - 2:
                ivybottomright = ivx + 1 + ynum3
                L[ivx, ivybottomright] = xykf * etas[i + 1, j + 1]

            # Left P node
            iprleft = ivx + 2
            L[ivx, iprleft] = pscale / xstp
            # Right P node
            iprright = ivx + 2 + ynum3
            L[ivx, iprright] = -pscale / xstp

        # Ghost Vx_parameter=0 used for numbering
        else:
            L[ivx, ivx] = 1
            R[ivx, 0] = 0

        # y-Stokes equation dSIGMAyy/dy+dSIGMAyx/dx-dP/dy=RY
        if i < ynum - 2:
            # y-Stokes equation stensil
            #     +-------------------- -+-------vy[i-1,j]------+----------------------+
            #     |                      |                      |                      |
            #     |                      |                      |                      |
            #     |                  vx[i,j-1]     P[i,j]    vx[i,j]                   |
            #     |                      |        etan[i,j]     |                      |
            #     |                      |                      |                      |
            #     +-----vy[i,j-1]---etas[i+1,j]---vy[i,j]--etas[i+1,j+1]---vy[i,j+1]---+
            #     |                      |                      |                      |
            #     |                      |                      |                      |
            #     |                  vx[i+1,j-1]  P[i+1,j]   vx[i+1,j]                 |
            #     |                      |      etan[i+1,j]     |                      |
            #     |                      |                      |                      |
            #     +----------------------+-------vy[i+1,j]------+----------------------+
            #
            # Right Part
            R[ivy, 0] = RY[i + 1, j + 1]
            # Computing Current y-Stokes coefficients
            # Central Vy node
            L[ivy, ivy] = -ykf2 * (etan[i + 1, j] + etan[i, j]) - xkf * (etas[i + 1, j + 1] + etas[i + 1, j])
            # Top Vy node
            if i > 0:
                ivytop = ivy - 3
                L[ivy, ivytop] = ykf2 * etan[i, j]

            # Bottom Vy node
            if i < ynum - 3:
                ivybottom = ivy + 3
                L[ivy, ivybottom] = ykf2 * etan[i + 1, j]

            # Left Vy node
            if j > 0:
                ivyleft = ivy - ynum3
                L[ivy, ivyleft] = xkf * etas[i + 1, j]
            else:
                L[ivy, ivy] = L[ivy, ivy] + bleft * xkf * etas[i + 1, j]

            # Right Vy node
            if j < xnum - 2:
                ivyright = ivy + ynum3
                L[ivy, ivyright] = xkf * etas[i + 1, j + 1]
            else:
                L[ivy, ivy] = L[ivy, ivy] + bright * xkf * etas[i + 1, j + 1]

            # Top left Vx node
            if j > 0:
                ivxtopleft = ivy - 1 - ynum3
                L[ivy, ivxtopleft] = xykf * etas[i + 1, j]

            # Bottom left Vx node
            if j > 0:
                ivxbottomleft = ivy - 1 + 3 - ynum3
                L[ivy, ivxbottomleft] = -xykf * etas[i + 1, j]

            # Top right Vx node
            if j < xnum - 2:
                ivxtopright = ivy - 1
                L[ivy, ivxtopright] = -xykf * etas[i + 1, j + 1]

            # Bottom right Vx node
            if j < xnum - 2:
                ivxbottomright = ivy - 1 + 3
                L[ivy, ivxbottomright] = xykf * etas[i + 1, j + 1]

            # Top P node
            iprtop = ivy + 1
            L[ivy, iprtop] = pscale / ystp
            # Bottom P node
            iprbottom = ivy + 1 + 3
            L[ivy, iprbottom] = -pscale / ystp

        # Ghost Vy_parameter=0 used for numbering
        else:
            L[ivy, ivy] = 1
            R[ivy, 0] = 0


        # Continuity equation dvx/dx+dvy/dy=RC
        if j > 0 or i > 0:
            # Continuity equation stensil
            #     +-----vy[i-1,j]--------+
            #     |                      |
            #     |                      |
            # vx[i,j-1]  pr[i,j]      vx[i,j]
            #     |                      |
            #     |                      |
            #     +------vy[i,j]---------+
            #
            # Right Part
            R[ipr, 0] = RC[i, j]
            # Computing Current Continuity coefficients
            # Left Vx node
            if j > 0:
                ivxleft = ipr - 2 - ynum3
                L[ipr, ivxleft] = -pscale / xstp

            # Right Vx node
            if j < xnum - 2:
                ivxright = ipr - 2
                L[ipr, ivxright] = pscale / xstp

            # Top Vy node
            if i > 0:
                ivytop = ipr - 1 - 3
                L[ipr, ivytop] = -pscale / ystp

            # Bottom Vy node
            if i < ynum - 2:
                ivybottom = ipr - 1
                L[ipr, ivybottom] = pscale / ystp


        # Pressure definition for the upper left node
        else:
            L[ipr, ipr] = 2 * pscale / (xstp + ystp)
            R[ipr, 0] = 2 * prnorm / (xstp + ystp)

# Solve matrix
S=spsolve(L, R)
# savemat("PY_LRS.mat", {"L": L.todense(), "R": R, "S": S})






def main():
    # main(prnorm,etas,etan,xnum,ynum,xstp,ystp,RX,RY,RC,bleft,bright,btop,bbottom)


    # return(vx, resx, vy, resy, pr, resc)
    pass


if __name__ == '__main__':
    main()

    # (vx1, resx1, vy1, resy1, pr1, resc1) \
    #     = main(prfirst, etas1, etan1, xnum, ynum, xstp, ystp, RX1, RY1, RC1, bleft, bright, btop, bbottom)




