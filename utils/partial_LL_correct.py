#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
# 
# Copyright 2021. Uecker Lab, University Medical Center Goettingen.
#
# Volkert Roeloffs, 2021
# volkert.roeloffs@med.uni-goettingen.de
"""
# derive an analytical signal model
# for an inversion recovery look-locker sequence 
# with partial recovery


import numpy as np
import matplotlib.pyplot as plt
import time
from scipy.optimize import curve_fit
import math
from pylab import *
import sys
import cfl
import os
import pdb
# path = os.environ["TOOLBOX_PATH"] + "/python/";
# sys.path.append(path);
import scipy
# from bart import bart

def corr_new(mss, mini, R1s, TR, M, N):
        Es = np.exp(-TR * M * R1s)
        E = lambda R1: np.exp(-TR * N * R1)
        f = lambda R1: (1/R1*mss*R1s*(1-E(R1))+E(R1)*mss*(1-Es))/(1+E(R1)*Es)-mini

        a = 1E-5
        b = 1E+6
        
        if (f(a)*f(b) < 0):
                R1_opt = scipy.optimize.bisect(f, a, b)
                T1 = 1/R1_opt
        else:
                T1 = 0
        return T1


def corr_new_maps(in_maps, TR, M, N):
        
        max_dim = np.shape(in_maps)

        store  = np.zeros((max_dim[0], max_dim[1]), dtype=float)

        mean = np.mean(np.mean(in_maps,0),1)
        mean_Mss = abs(mean[0])

        for x in range(max_dim[0]):       
                for y in range(max_dim[1]):
                    
        #                print( "Pixel: ("+str(x)+", "+str(y)+")" )

                        Mss  = abs(in_maps[x, y, 0])
                        Mini = abs(in_maps[x, y, 1])
                        R1s  = abs(in_maps[x, y, 2])

                        store[x,y] = corr_new(Mss, Mini, R1s, TR, M, N) + 2*15.3e-3
        return store
      
      

if __name__ == "__main__":
    # Error if wrong number of parameters

        if (len(sys.argv) != 6):
                print("Function for correcting T1 values for look-locker type sequence with partial recovery")
                print("Usage: partial_LL_correct.py <in_file> <TR> <M> <N> <out_file>")
                exit()

        infile  = sys.argv[1]
        TR      = float(sys.argv[2])
        M       = int(sys.argv[3])
        N       = int(sys.argv[4])
        outfile = sys.argv[5]

        in_maps = np.array(cfl.readcfl(infile).squeeze()) 
        

        start = time.time()
        map   = corr_new_maps(in_maps, TR, M, N)
        cfl.writecfl(outfile, map)
        end   = time.time()
        print("Ellapsed time: " + str(end - start) + " s")
