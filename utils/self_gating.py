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


from cfl import readcfl
import numpy as np

import matplotlib.pyplot as plt

import io

#import statsmodels.api as sm
from scipy.interpolate import interp1d
import matplotlib.font_manager as font_manager
import sys


def array_plot(Line_Profile, Belt, EOF_RESP, outfile):
        color = ["#CDCDCD","#ef4846","#52ba9b","#f48b37", "#89c2d4","#ef8e8d","#a0ccc5","#f4b481", "#ffffff", "#c51b8a", "#fdf7bc", "#f95f0e"]
        DPI=200
        fig, ax =plt.subplots(nrows=1, ncols=1, figsize=(3600/DPI, 1000/DPI))
        ax.imshow(Line_Profile,  cmap='gray', extent=[0, len(Belt), -70,70])
        ax.plot(-70 * Belt + 3,  linewidth=1., color=color[-1], label="Respiratory Belt", alpha=0.75) # consider indexing
        ax.plot(640 * EOF_RESP + 15,  linewidth=1.5, color=color[-2], label="Self-Gating", alpha=0.8) # consider indexing
        plt.rcParams.update({'font.size': 20})
        font = font_manager.FontProperties(family='Arial', style='normal', size=20)
        ax.legend(loc='lower left', bbox_to_anchor= (-0.005, 1.01), ncol=3, facecolor=color[0], prop=font)
        ax.axis("off")
        plt.axis('off')
        ax.get_xaxis().set_visible(False)
        plt.savefig(outfile, dpi=350, bbox_inches='tight',pad_inches = 0)
        
            
def interp(ys, mul):
    # linear extrapolation for last (mul - 1) points
    ys = list(ys)
    ys.append(2*ys[-1] - ys[-2])
    # make interpolation function
    xs = np.arange(len(ys))
    fn = interp1d(xs, ys, kind="cubic")
    # call it on desired data points
    new_xs = np.arange(len(ys) - 1, step=1./mul)
    return fn(new_xs)
#%%
class self_gating(object):
    
    def plot_self_gating(self, eof, belt, rtnlinv, outfile):
        # sequence parameters:
        nIRs = 20
        nspokes_per_IR = 915
        TR = 3.27 # ms
        time_break = 3000 # ms

        # EOF from SSA-FARY
        eof_resp = eof[:,0]

        # Belt signals
       
        # read raw belt signal 
        k=0
        with io.open(self.belt , mode="r", encoding="utf-8") as f:
            for line in f:
                tmp = line.split()
                print(tmp)
                k = k + 1
        tmp1 = np.asarray(tmp)

        tmp2 = np.zeros(len(tmp1))

        for k in range(len(tmp1)):
            tmp2[k] = int(tmp1[k])

        # start from the second inversion
        start = 3775 
        t_acq = int(np.ceil(nspokes_per_IR*TR/2.5))
        t_break = int(np.ceil(time_break/2.5))

        end = start + t_acq * nIRs + t_break * nIRs # 15 inversions + 14 breaks
        c = tmp2[start:end]


        i, = np.where(c > 3599)

        c = c/max(abs(c))

        for k in np.arange(len(i)):
            c[i[k]] = c[i[k]-1] 
    
        # extract the acquisition period of the belt signal
        belt_interp2 = 1.5*interp(c, (len(eof_resp)-0.5)/len(c))-0.7


        # real-time images
        dims = np.shape(rtnlinv)

        t_per_cycle = len(eof_resp)

        imgs1 = np.zeros([dims[0], dims[1], t_per_cycle], dtype=rtnlinv.dtype)

        t_per_cycle_per_IR = int(t_per_cycle/nIRs)

        t_acq_per_IR = int(t_per_cycle/(2*nIRs))

        for k in range(nIRs):
            imgs1[:,:,(k * t_per_cycle_per_IR) : (k * t_per_cycle_per_IR + t_acq_per_IR)] = \
            rtnlinv[:,:,(k * t_acq_per_IR) : ((k + 1) * t_acq_per_IR)]
  
        eof_resp1 = -eof_resp
        line_profile=np.squeeze(abs(imgs1[35,33:60,:]))
        line_profile1 = np.flip(line_profile,0)

        # Plot the first 12 IRs
        plot_nIR = 12
        t_allIRs = t_per_cycle_per_IR*plot_nIR

        array_plot(line_profile1[:,:t_allIRs], belt_interp2[:t_allIRs], eof_resp1[:t_allIRs], outfile)

    def __init__(self, eof, belt, rtnlinv, outfile):  
        self.eof     = sys.argv[1]
        self.belt    = sys.argv[2]
        self.rtnlinv = sys.argv[3]
        self.outfile = sys.argv[4]
        
        
        # self-gating signal
        self.eof = np.array(readcfl(self.eof).squeeze())
        
        # real-time images
        self.rtnlinv = np.squeeze(readcfl(self.rtnlinv))
        
        self.plot_self_gating(self.eof, self.belt, self.rtnlinv, self.outfile);


        
if __name__ == "__main__":
    #Error if wrong number of parameters
    if( len(sys.argv) != 5):
        print( "plot self-gating signal against belt signal and rtnlinv images." )
        print( "Usage: self_gating.py <eof> <belt>  <rtnlinv> <outfile>" )
        exit()
        
    self_gating( sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] )



