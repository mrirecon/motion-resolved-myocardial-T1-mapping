#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
# 
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Xiaoqing Wang. 2020
# xiaoqing.wang@med.uni-goettingen.de
"""

import numpy as np
import matplotlib.pyplot as plt
import time
import math
import sys

import cfl

import statistics 


from scipy.signal import find_peaks

class EOF_ECG(object):
    
    def EOF(self, data, m_phases):
               
        data = abs(data)
        peaks, _ = find_peaks(data, height=0)
        # plt.figure(figsize = [6.4*3, 4.8*3])
        # plt.plot(data)
        # plt.plot(peaks, data[peaks], "x")
        # plt.plot(np.zeros_like(data), "--", color="gray")
        # plt.show()
#       
        total_phases=int(m_phases)
        x_range = np.zeros(len(data))

        median_peak = statistics.median(data[peaks])
        print(median_peak)
        nIntensity_per_phase = int(median_peak/total_phases)
        
        
        for y in range(0, (peaks[0] + 1)):
                nIntensity_per_phase = (data[peaks[0]] + 1)/total_phases
                tmp = math.floor(data[y] / nIntensity_per_phase)
                
                if (tmp > (total_phases - 1)):
                        tmp = total_phases - 1
                x_range[y] = tmp
    
    
        for y in range(peaks[len(peaks)-1], len(data)):
                nIntensity_per_phase = (median_peak + 1)/total_phases
                tmp = math.floor(data[y] / nIntensity_per_phase)

                if (tmp > (total_phases - 1)):
                        tmp = total_phases - 1
                x_range[y] = tmp

        for x in range(1,len(peaks)):
#                nIntensity_per_phase = data[peaks[x]]/total_phases
                if (data[peaks[x]] < 0.8 * median_peak):
                    nIntensity_per_phase = (median_peak + 1)/total_phases
                else:
                     nIntensity_per_phase = (data[peaks[x]] + 1)/total_phases
                     
                for y in range(peaks[x-1]+1, peaks[x]+1):
                        tmp = math.floor(data[y] / nIntensity_per_phase)
                        
                        if (tmp > (total_phases - 1)):
                                tmp = total_phases - 1
                        x_range[y] = tmp
                        
        # plt.figure(figsize = [6.4*3, 4.8*3])
        # plt.plot(x_range)

        # plt.show()
        
        tmp1 = x_range*(2*math.pi/total_phases)

        store = np.zeros( (len(x_range), 2), dtype=complex) 

        store[:,0] = np.cos(tmp1)  + 0j
        store[:,1] = np.sin(tmp1)  + 0j
        
        # plt.figure(figsize = [6.4*3, 4.8*3])
        # plt.plot(store[:,0])

        # plt.show()
        
#        fig = plt.figure(figsize = [6.4*3, 4.8*3])
#        plt.plot(store[:,1])
#
#        plt.show()

        return store
    
   
        
    def __init__(self, infile, mphases, outfile1, outfile2):  
        self.infile = sys.argv[1]
        self.mphases = sys.argv[2]
        self.outfile1 = sys.argv[3]
        self.outfile2 = sys.argv[4]
        
        start = time.time()
       
        self.oridata = np.array( cfl.readcfl(self.infile).squeeze() ) 
        
        signal = np.zeros( (len(self.oridata), 2), dtype=complex) 
        
        signal = self.EOF( np.abs(self.oridata), self.mphases)
     
        cfl.writecfl(self.outfile1, signal[:,0])
        cfl.writecfl(self.outfile2, signal[:,1])
        
        end = time.time()
        print("Ellapsed time: " + str(end - start) + " s")


        
if __name__ == "__main__":
    #Error if wrong number of parameters
    if( len(sys.argv) != 5):
        print( "Function to generate EOF files from ECG cardiac signals." )
        print( "Usage: EOF_ECG.py <infile> <mphases> <outfile1> <outfile2>" )
        exit()
        
    EOF_ECG( sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] )
    
