#!/bin/bash
# 
# Copyright 2022. TU Graz. Institute of Biomedical Imaging.
# Copyright 2020-2022. Uecker Lab. University Medical Center Göttingen.
#
# Author: Xiaoqing Wang, 2020-2022
# xwang@tugraz.at
# xiaoqingwang2010@gmail.com

# Wang X et al.
# Free-Breathing Myocardial T1 Mapping using Inversion-Recovery 
# Radial FLASH and Motion-Resolved Model-Based Reconstruction.
# Magn Reson Med. (2022), DOI: 10.1002/mrm.29521.
#

import numpy as np
from cfl import readcfl
import io


from matplotlib import rcParams
rcParams['font.family'] = 'Arial'

import matplotlib.pyplot as plt
import sys


#%%
class plot_septal_T1_regs(object):
    
    def plot_septal_T1(self, mean, std, outfile):
        
        plt.style.use('seaborn-whitegrid')

        T1_Prop_regs = [mean[0], mean[1], mean[2], mean[3]]
        STD_Prop_regs = [std[0], std[1], std[2], std[3]]

        print("The mean is: ", T1_Prop_regs)
        print("The std is: ", STD_Prop_regs) 

        x_pos = np.arange(len(T1_Prop_regs)) + 1

        plt.rcParams.update({'font.size': 15})


        fig, ax = plt.subplots(nrows=1, ncols=1, sharex=True, sharey=True)


        ax.errorbar(x_pos, T1_Prop_regs, STD_Prop_regs,
                fmt='d', capsize=4, elinewidth=2.0,
                ms=8, ecolor='b', color='b')


        ax.grid(which='major', color='#CCCCCC', linestyle='--')

        plt.xlim((0.5, 4.5)) 
        plt.ylim((1180, 1400)) 

        plt.xticks(x_pos, [0.004, 0.005, 0.006, 0.007])
        fig.set_size_inches(6.4, 4.2, forward=True)
        plt.xlabel('$\\alpha_{\\min}$', fontsize=16)
        plt.ylabel('$T_{1}$ / ms', fontsize=16)

        plt.savefig(outfile, format='pdf', bbox_inches='tight', transparent=True)



    def __init__(self, mean, std, outfile):  
        self.mean       = sys.argv[1]
        self.std        = sys.argv[2]
        self.outfile    = sys.argv[3]

        self.mean = np.abs(np.array(readcfl(self.mean).squeeze()))
        self.std  = np.abs(np.array(readcfl(self.std).squeeze()))
        
        self.plot_septal_T1(self.mean, self.std, self.outfile);


        
if __name__ == "__main__":
    #Error if wrong number of parameters
    if( len(sys.argv) != 4):
        print( "plot quantitative septal T1 values against regularization parameter." )
        print( "Usage: plot_septal_T1_regs.py <T1_mean> <T1_std> <outfile>" )
        exit()
        
    plot_septal_T1_regs( sys.argv[1], sys.argv[2], sys.argv[3] )