#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jun 17 18:14:31 2021

@author: wzhang
"""

from __future__ import division
import numpy as np
import matplotlib.pyplot as plt
# from scipy import linalg
from scipy.sparse.linalg import spsolve
from scipy.io import loadmat
# import scipy.io as scio

#########################################


#########################################
# Acceleration of Gravity, m/s^2
g=9.81
# Pressure in the upermost, leftmost [first ] cell
prfirst=0


# Maximal timestep, s
timemax=1e+8 * (365.25*24*3600)
# Maximal marker displacement step, number of gridsteps
markmax=0.5
# Amount of timesteps
stepmax=100 - 99

# Model size, m
xsize=500000
ysize=500000

# Velocity Boundary condition specified by bleft,bright,btop,bbot
# [1=free slip -1=no slip ] are implemented from ghost nodes
# directly into Stokes and continuity equations
bleft=1
bright=1
btop=1
bbottom=1

# Defining resolution
xnum=51
ynum=51

# Defining gridsteps
xstp=xsize/(xnum-1 )
ystp=ysize/(ynum-1 )

# Defining number of markers and steps between them in the horizontal and vertical direction
xmx=5 #number of markers per cell in horizontal direction
ymy=5 #number of markers per cell in vertical direction
mxnum=(xnum-1 )*xmx #total number of markers in horizontal direction
mynum=(ynum-1 )*ymy #total number of markers in vertical direction
mxstep=xsize/mxnum #step between markers in horizontal direction
mystep=ysize/mynum #step between markers in vertical direction


# Creating nodes, center & markers arrays
x1 = np.arange(0 * xstp, xsize + xstp, xstp)
y1 = np.arange(0 * ystp, ysize + ystp, ystp)
NX,NY = np.meshgrid(x1, y1)

x2 = np.arange(0.5 * xstp, xsize, xstp)
y2 = np.arange(0.5 * ystp, ysize, ystp)
CX,CY = np.meshgrid(x2, y2)

x3 = np.arange(0.5 * mxstep, xsize, mxstep)
y3 = np.arange(0.5 * mxstep, ysize, mxstep)
MX,MY = np.meshgrid(x3, y3)
del x1, y1, x2, y2, x3, y3

# Rock type, density and viscosity arrays
MI=np.zeros((mynum,mxnum)) # Type
MRHO = np.zeros((mynum,mxnum))
META = np.zeros((mynum,mxnum))

typ1 = np.zeros((ynum,xnum))
etas1 = np.zeros((ynum,xnum))
etan1 = np.zeros((ynum-1,xnum-1))
rho1 = np.zeros((ynum,xnum))


# Defining intial position of markers
# Defining lithological structure of the model
for xm in range(mxnum):
    for ym in range(mynum):
        MI[ym,xm ]=1
        MRHO[ym, xm] = 3200.0
        META[ym, xm] = 1.0e+21
        # Density, viscosity structure definition for block
        # Relative distances for the marker inside the grid
        dx=MX[ym,xm ]/xsize
        dy=MY[ym,xm ]/ysize

        if dx>=0.4 and dx<=0.6 and dy>=0.1 and dy<=0.3 :
            MI[ym,xm ]=2
            MRHO[ym, xm] = 3300.0
            META[ym, xm] = 1.0e+27




# Initial time, s
timesum=0

# Main Time cycle
# Backup rock type, density and viscosity arrays
for ntimestep in range(stepmax):
    typ0 = typ1
    etas0 = etas1
    etan0 = etan1
    rho0 = rho1
    # Clear rock type, density and viscosity arrays
    typ1 = np.zeros((ynum,xnum ))
    etas1 = np.zeros((ynum,xnum ))
    etan1 = np.zeros((ynum-1,xnum-1))
    rho1 = np.zeros((ynum,xnum))
    # Clear wights for basic nodes
    wtnodes=np.zeros((ynum,xnum))
    # Clear wights for etas
    wtetas=np.zeros((ynum,xnum))
    # Clear wights for etan
    wtetan=np.zeros((ynum-1,xnum-1))

    # Interpolating parameters from markers to nodes
    for xm in range(mxnum):
        for ym in range(mynum):

            #  xn    rho[xn,yn ]--------------------rho[xn+1,yn ]
            #           ?           ^                  ?
            #           ?           ?                  ?
            #           ?          dy                  ?
            #           ?           ?                  ?
            #           ?           v                  ?
            #           ?<----dx--->o Mrho[xm,ym ]       ?
            #           ?                              ?
            #           ?                              ?
            #  xn+1  rho[xn,yn+1 ]-------------------rho[xn+1,yn+1 ]
            #
            # Define indexes for upper left node in the cell where the marker is
            xn=round(MX[ym,xm]/xstp-0.5)
            yn=round(MY[ym,xm]/ystp-0.5)
            if xn<0:
                xn=0

            if xn>xnum-2:
                xn=xnum-2

            if yn<0:
                yn=0

            if yn>ynum-2:
                yn=ynum-2


            # Define normalized distances from marker to the upper left node
            dx=MX[ym,xm ]/xstp-xn
            dy=MY[ym,xm ]/ystp-yn

            # Add density to 4 surrounding nodes
            rho1[yn,xn ]=rho1[yn,xn ]+(1.0-dx ) * (1.0-dy ) * MRHO[ym, xm]
            wtnodes[yn,xn ]=wtnodes[yn,xn ]+(1.0-dx ) * (1.0-dy )
            rho1[yn+1,xn ]=rho1[yn+1,xn ]+(1.0-dx ) * dy * MRHO[ym, xm]
            wtnodes[yn+1,xn ]=wtnodes[yn+1,xn ]+(1.0-dx ) * dy
            rho1[yn,xn+1 ]=rho1[yn,xn+1 ]+dx * (1.0-dy ) * MRHO[ym, xm]
            wtnodes[yn,xn+1 ]=wtnodes[yn,xn+1 ]+dx * (1.0-dy )
            rho1[yn+1,xn+1 ]=rho1[yn+1,xn+1 ]+dx * dy * MRHO[ym, xm]
            wtnodes[yn+1,xn+1 ]=wtnodes[yn+1,xn+1 ]+dx * dy

            # Add shear viscosity etas[ ] and rock type typ[ ] to 4 surrounding nodes
            # only using markers located at <=0.5 gridstep distances from nodes
            if dx<=0.5 and dy<=0.5:
                etas1[yn,xn ]=etas1[yn,xn ]+(1.0-dx ) * (1.0-dy ) * META[ym, xm]
                typ1[yn,xn ]=typ1[yn,xn ]+(1.0-dx ) * (1.0-dy ) * MI[ym,xm ]
                wtetas[yn,xn ]=wtetas[yn,xn ]+(1.0-dx ) * (1.0-dy )

            if dx<=0.5 and dy>=0.5:
                etas1[yn+1,xn ]=etas1[yn+1,xn ]+(1.0-dx ) * dy * META[ym, xm]
                typ1[yn+1,xn ]=typ1[yn+1,xn ]+(1.0-dx ) * dy * MI[ym,xm ]
                wtetas[yn+1,xn ]=wtetas[yn+1,xn ]+(1.0-dx ) * dy

            if dx>=0.5 and dy<=0.5:
                etas1[yn,xn+1 ]=etas1[yn,xn+1 ]+dx * (1.0-dy ) * META[ym, xm]
                typ1[yn,xn+1 ]=typ1[yn,xn+1 ]+dx * (1.0-dy ) * MI[ym,xm ]
                wtetas[yn,xn+1 ]=wtetas[yn,xn+1 ]+dx * (1.0-dy )

            if dx>=0.5 and dy>=0.5:
                etas1[yn+1,xn+1 ]=etas1[yn+1,xn+1 ]+dx * dy * META[ym, xm]
                typ1[yn+1,xn+1 ]=typ1[yn+1,xn+1 ]+dx * dy * MI[ym,xm ]
                wtetas[yn+1,xn+1 ]=wtetas[yn+1,xn+1 ]+dx * dy


            # Add normal viscosity etan[ ] to the center of current cell
            etan1[yn,xn ]=etan1[yn,xn ]+(1.0-abs(0.5-dx ) ) * (1.0-abs(0.5-dy ) ) * META[ym, xm]
            wtetan[yn,xn ]=wtetan[yn,xn ]+(1.0-abs(0.5-dx ) ) * (1.0-abs(0.5-dy ) )

    # Computing  Viscosity, density, rock type for nodal points
    for i in range(ynum):
        for j in range(xnum):
            # Density
            if wtnodes[i,j ]!=0 :
                # Compute new value interpolated from markers
                rho1[i,j ]=rho1[i,j ]/wtnodes[i,j ]
            else:
                # If no new value is interpolated from markers old value is used
                rho1[i,j ]=rho0[i,j ]

            # Shear viscosity and type
            if wtetas[i,j ]!=0:
                # Compute new value interpolated from markers
                etas1[i,j ]=etas1[i,j ]/wtetas[i,j ]
                typ1[i,j ]=typ1[i,j ]/wtetas[i,j ]
            else:
                # If no new value is interpolated from markers old value is used
                etas1[i,j ]=etas0[i,j ]
                typ1[i,j ]=typ0[i,j ]

            # Normal viscosity
            if i<ynum - 1 and j<xnum - 1 :
                if wtetan[i,j ]!=0 :
                    # Compute new value interpolated from markers
                    etan1[i,j ]=etan1[i,j ]/wtetan[i,j ]
                else:
                    # If no new value is interpolated from markers old value is used
                    etan1[i,j ]=etan0[i,j ]

    # Computing right part of Stokes [RX, RY ] and Continuity [RC ] equation
    # vx, vy, P
    vx1=np.zeros((ynum+1,xnum))
    vy1=np.zeros((ynum,xnum+1))
    pr1=np.zeros((ynum-1,xnum-1))
    # Right parts of equations
    RX1=np.zeros((ynum+1,xnum))
    RY1=np.zeros((ynum,xnum+1))
    RC1=np.zeros((ynum-1,xnum-1))
    # Grid points cycle
    for i in range(ynum):
        for j in range(xnum):
            # Right part of x-Stokes Equation
            if j>0 and i>0 and j<xnum - 1:
                RX1[i,j ]=0

            # Right part of y-Stokes Equation
            if j>0 and i>0 and i<ynum - 1:
                RY1[i,j ]=-g * (rho1[i,j ]+rho1[i,j-1 ])/2



np.savez('PYout', prfirst=prfirst,etas1=etas1,etan1=etan1,
         xnum=xnum,ynum=ynum,xstp=xstp,ystp=ystp,RX1=RX1,RY1=RY1,RC1=RC1,
         bleft=bleft, bright=bright, btop=btop, bbottom=bbottom)


def main():
    pass

if __name__ == '__main__':
    main()
    