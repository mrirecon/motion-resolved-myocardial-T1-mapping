#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Sep  6 10:19:22 2019

@author: nscho xwang
"""

import sys
#sys.path.append('../')
#from options import path
#sys.path.append(path)
import cfl

import numpy as np
from numpy import *


class sort_input_moba(object):
 
    def __init__(self, itraj, idata, iTI, otraj, odata, oTI): 
        
        self.itraj = np.array(cfl.readcfl(sys.argv[1]).squeeze())
        self.idata = np.array(cfl.readcfl(sys.argv[2]).squeeze())
        self.iTI = np.array(cfl.readcfl(sys.argv[3]).squeeze())
        self.otraj = sys.argv[4]
        self.odata = sys.argv[5]
        self.oTI = sys.argv[6]
        
        sorted_TI = self.iTI
        where_are_NaNs = isnan(sorted_TI)
        sorted_TI[where_are_NaNs] = 0
        
        sorted_traj = self.itraj
        sorted_data = self.idata
        
        dim = np.shape( self.iTI )
        
#        index = np.zeros( (dim[0], dim[1]), dtype=np.int8) # 6 = 3 parameter maps with 3 error maps
        
        sorted_TI[sorted_TI < 1e-6] = 1000
        
        for k in range(dim[1]):
            tmp_index = abs(sorted_TI[:,k].argsort())
            tmp_index = abs(tmp_index)
            sorted_TI[:,k] = self.iTI[tmp_index,k]
            sorted_traj[:,:,:,:,k] = self.itraj[:,:,:,tmp_index,k]
            sorted_data[:,:,:,:,k] = self.idata[:,:,:,tmp_index,k]
            
        sorted_TI[sorted_TI > 999] = 0                                
        cfl.writecfl(self.oTI, sorted_TI)
        cfl.writecfl(self.otraj, sorted_traj)
        cfl.writecfl(self.odata, sorted_data)

if __name__ == "__main__":

    # Error if more than 1 argument
    if (len(sys.argv) != 7):
        print("sort_input_moba.py: sort the inputs for moba reco.")
        print("Usage: python3 sort_input_moba.py <itraj> <idata> <iTI> <otraj> <odata> <oTI>")
        exit()

    sort_input_moba( sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6])
    
#    , sys.argv[5], sys.argv[6]
#, otraj, odata, 

