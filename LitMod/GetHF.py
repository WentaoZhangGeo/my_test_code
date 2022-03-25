#!python
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 25 00:09:45 2022

Q = - K * dT/dz, where K is thermal conductivity, T is temperature and z is depth

对比热流结果（温度计算和软件计算）的差异

实验结果表明
大部分结果与 LitMod2D 相似。 NA 和 Dinarides 下方存在一些差异，这是由较薄的沉积层造成的。

@author: wzhang
"""

import numpy as np
import matplotlib.pyplot as plt

def test1():
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
        K = 2.4             # thermal conductivity of sediment
        plt.plot(x,- K * dT[0]/dz[0], 'r*')
        
        dat = Tem2[np.where(Tem2[:,0] == x),:][0,:,:]
        dz = dat[1:,1] - dat[:-1,1]
        dT = dat[1:,2] - dat[:-1,2]  
        plt.plot(x,- K * dT[0]/dz[0], 'b*')
        
    plt.plot(x,- K * dT[0]/dz[0], 'r*', label='Q = - K * dT/dz, tempout.dat')
    plt.plot(x,- K * dT[0]/dz[0], 'b*', label='Q = - K * dT/dz, post_processing_output.dat')
    plt.plot(HF[:,0], HF[:,1], '-', label='LitMod2D')

    plt.legend(ncol=1,fontsize=10,loc=0)

    plt.show()

def test2():
    fig = plt.figure(figsize = (12, 5)) 
    
    dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/laptop'
    HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
    # Label = '0.8 μW/m3, LAB 75 km'
    Label = 'V_F02_5'
    plt.plot(HF[:,0], HF[:,1], 'r-', label=Label)
    
# =============================================================================
    
#     # dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/V_F02_5_HF01'
#     # HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
#     # Label = '1.6 μW/m3, LAB 75 km'
#     # plt.plot(HF[:,0], HF[:,1], '-', label=Label)
    
#     # dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/V_F02_5_HF02'
#     # HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
#     # Label = '8.0 μW/m3, LAB 75 km'
#     # plt.plot(HF[:,0], HF[:,1], '-', label=Label)
    
#     # dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/V_F02_5_HF03'
#     # HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
#     # Label = '0.8 μW/m3, LAB 60 km'
#     # plt.plot(HF[:,0], HF[:,1], '-', label=Label)
# =============================================================================
    
    
# =============================================================================
#     dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/V_F02_5_HF04'
#     HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
#     Label = '1.5 μW/m3'
#     plt.plot(HF[:,0], HF[:,1], '--', label=Label)
# 
#     dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/V_F02_5_HF05'
#     HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
#     Label = '2 μW/m3'
#     plt.plot(HF[:,0], HF[:,1], '--', label=Label)   
# 
#     dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/V_F02_5_HF06'
#     HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
#     Label = '5 μW/m3'
#     plt.plot(HF[:,0], HF[:,1], '--', label=Label)  
# =============================================================================

    dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/V_F02_5_HF09'
    HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
    Label = 'V_F02_5_HF09'
    plt.plot(HF[:,0], HF[:,1], '--', label=Label)  

    dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/V_F02_5_HF07'
    HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
    Label = '2.0 μW/m3 NA'
    plt.plot(HF[:,0], HF[:,1], '--', label=Label)  
    
    dir = '/home/ictja/ownCloud/PhD_Fig/NorProfile_Fig/2021-12-13_V_F02_5/V_F02_5_HF08'
    HF = np.loadtxt(dir + '/SHF_out.dat', skiprows=1)
    Label = '5.0 μW/m3 NA'
    plt.plot(HF[:,0], HF[:,1], '--', label=Label)  
    
    # plt.legend(ncol=1,fontsize=10,loc=0)
    plt.legend(ncol=1,fontsize=12,loc=0, title = "$Sediment$")
    plt.ylabel('Suface Heat flow ($km$)')
    plt.xlabel('Distance ($km$)')
    plt.show()


if __name__ == '__main__':
    test2()