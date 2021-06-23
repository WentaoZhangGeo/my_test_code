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
MRHO = np.zeros(100)
META = np.zeros(100)

#########################################
# Acceleration of Gravity, m/s^2
g=9.81
# Pressure in the upermost, leftmost [first ] cell
prfirst=0
# Rock density [kg/m3 ], viscosity [Pa s ]
# Medium
MRHO[1 ]=3200.0
META[1 ]=1e+21
# Block
MRHO[2 ]=3300.0
META[2 ]=1e+27

# Maximal timestep, s
timemax=1e+8*[365.25*24*3600 ]
# Maximal marker displacement step, number of gridsteps
markmax=0.5
# Amount of timesteps
stepmax=100

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


def main():
    pass

if __name__ == '__main__':
    main()
    