#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Sep  6 10:19:22 2019

@author: xwang
"""

import sys
#sys.path.append('../')
#from options import path
#sys.path.append(path)
import cfl

import numpy as np



class phase_divide_svd(object):
 
    def __init__(self, iac, iac_contrast_rm, nIR, ac_contrast_rm_out, U_01): 
        
        self.iac = np.array(cfl.readcfl(sys.argv[1]).squeeze())
        self.iac_contrast_rm = np.array(cfl.readcfl(sys.argv[2]).squeeze())
        self.nIR = int(sys.argv[3])
        self.ac_contrast_rm_out = sys.argv[4]
        self.U_01 = np.abs(np.array(cfl.readcfl(sys.argv[5]).squeeze()))

#        mean_U_01 = np.mean(self.U_01)
        
        dim = np.shape( self.iac )
        
        ac1 = self.iac_contrast_rm.copy()

        for k in np.arange(dim[1]):
            x = abs(self.iac[:,k])
            row_min_index = np.where(x == np.min(x))
            index = row_min_index[0]
            ac1[0:index[0],k] = -1. *(self.iac_contrast_rm[0:index[0],k])
    
        nCoil=int(dim[1]/self.nIR)

        ac_contrast_conj_1 = np.reshape(ac1, (dim[0], nCoil, self.nIR))
        ac_contrast_conj_2 = np.transpose(ac_contrast_conj_1, (0, 2, 1))


        dim1 = np.shape(ac_contrast_conj_2)

#        x1 = np.zeros((dim1[0], dim1[2]), dtype=complex)
        ac2 = ac_contrast_conj_2

        for k in np.arange(dim1[2]):
            for j in np.arange(dim1[1]):
                ac2[:,j,k] = np.divide(ac2[:,j,k], self.U_01[:,k])
        

        cfl.writecfl(self.ac_contrast_rm_out, ac2)


if __name__ == "__main__":

    # Error if more than 1 argument
    if (len(sys.argv) != 6):
        print("phase_divide_svd.py: phase correction of ac and normalization.")
        print("Usage: python3 phase_divide_svd.py <ac> <ac_contrast_rm> <No. of IRs> <ac_contrast_rm_out> <U_01>")
        exit()

    phase_divide_svd( sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
    
#    , sys.argv[5], sys.argv[6]
#, otraj, odata, 

