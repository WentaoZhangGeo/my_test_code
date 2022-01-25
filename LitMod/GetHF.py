#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 25 00:09:45 2022

Q = - K * dT/dz, where K is thermal conductivity, T is temperature and z is depth


@author: wzhang
"""


import numpy as np
import matplotlib.pyplot as plt

dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/laptop'

Tem = np.loadtxt(dir + '/tempout.dat', skiprows=2)
Tem2 = np.loadtxt(dir + '/post_processing_output.dat', skiprows=0)
HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)

# X = np.unique(data[:,0])
X = np.arange(0, 1070 + 5, 5)


fig = plt.figure(figsize = (12, 5)) 
for x in X:
    dat = Tem[np.where(Tem[:,0] == x),:][0,:,:]
    dz = dat[1:,1] - dat[:-1,1]
    dT = dat[1:,2] - dat[:-1,2]
    K = 2.4
    plt.plot(x,- K * dT[0]/dz[0], 'r*')
    
    dat = Tem2[np.where(Tem2[:,0] == x),:][0,:,:]
    dz = dat[1:,1] - dat[:-1,1]
    dT = dat[1:,2] - dat[:-1,2]  
    plt.plot(x,- K * dT[0]/dz[0], 'b*')
    
plt.plot(x,- K * dT[0]/dz[0], 'r*', label='Q = - K * dT/dz')
plt.plot(HF[:,0], HF[:,1], '-', label='LitMod2D')




plt.legend(ncol=1,fontsize=10,loc=0)