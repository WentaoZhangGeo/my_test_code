#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jun 17 18:14:31 2021

@author: wzhang
"""
       

# Cell-Particles Projections
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import linalg

import scipy.io as scio
import pandas as pd
import matplotlib.pyplot as plt


from pylab import rcParams

LitModOutputName='post_processing_output.dat';
LitMod=np.loadtxt(LitModOutputName);



# Solve matrix
# S=L\R;
dataFile = '/home/wzhang/ownCloud/Stoke/CH21_online/saveA.mat'
# dataFile = '/home/ictja/Music/stokes/120km2/Air120km_Step9.mat'
data = scio.loadmat(dataFile)


L = data['L']
R = data['R']
S = data['S']

XX = linalg.solve(L, R)
# x = linalg.solve(a, b)