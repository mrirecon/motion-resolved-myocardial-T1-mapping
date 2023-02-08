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

import matplotlib.font_manager as font_manager
import sys


def array_plot(Line_Profile, EOF_RESP, outfile):
        color = ["#CDCDCD","#ef4846","#52ba9b","#f48b37", "#89c2d4","#ef8e8d","#a0ccc5","#f4b481", "#ffffff", "#c51b8a", "#fdf7bc", "#f95f0e"]
        DPI=200
        fig, ax =plt.subplots(nrows=1, ncols=1, figsize=(3600/DPI, 1000/DPI))
        ax.imshow(Line_Profile,  cmap='gray', vmin=0, vmax=0.18, extent=[0, len(EOF_RESP), -70,70])
        ax.plot(EOF_RESP,  linewidth=2.0, color=color[-2], label="Self-Gating", alpha=0.8) # consider indexing
        plt.rcParams.update({'font.size': 20})
        font = font_manager.FontProperties(family='Arial', style='normal', size=20)
        ax.legend(loc='lower left', bbox_to_anchor= (-0.005, 1.01), ncol=3, facecolor=color[0], prop=font)
        ax.axis("off")
        plt.axis('off')
        ax.get_xaxis().set_visible(False)
        plt.savefig(outfile, dpi=350, bbox_inches='tight',pad_inches = 0)
            
#%%
class self_gating(object):
    
    def plot_self_gating(self, eof, rtnlinv, outfile):
        # sequence parameters:
        nIRs = 20

        # EOF from SSA-FARY
        eof_resp = eof[:,0]

        # real-time images
        dims = np.shape(rtnlinv)

        t_per_cycle = len(eof_resp)

        imgs1 = np.zeros([dims[0], dims[1], t_per_cycle], dtype=rtnlinv.dtype)

        t_per_cycle_per_IR = int(t_per_cycle/nIRs)

        t_acq_per_IR = int(t_per_cycle/(2*nIRs))

        for k in range(nIRs):
            imgs1[:,:,(k * t_per_cycle_per_IR) : (k * t_per_cycle_per_IR + t_acq_per_IR)] = \
            rtnlinv[:,:,(k * t_acq_per_IR) : ((k + 1) * t_acq_per_IR)]
  
        eof_resp1 = 0.3*eof_resp + 0.015

        line_profile=np.squeeze(abs(imgs1[53,35:53,:]))
        line_profile1 = np.flip(line_profile,0)

        # Plot the first 12 IRs
        plot_nIR = 12
        t_allIRs = t_per_cycle_per_IR*plot_nIR

        array_plot(line_profile1[:,:t_allIRs], 1400.0*eof_resp1[0:t_allIRs]-25, outfile)

    def __init__(self, eof, rtnlinv, outfile):  
        self.eof     = sys.argv[1]
        self.rtnlinv = sys.argv[2]
        self.outfile = sys.argv[3]
        
        
        # self-gating signal
        self.eof = np.array(readcfl(self.eof).squeeze())
        
        # real-time images
        self.rtnlinv = np.squeeze(readcfl(self.rtnlinv))
        
        self.plot_self_gating(self.eof, self.rtnlinv, self.outfile);


        
if __name__ == "__main__":
    #Error if wrong number of parameters
    if( len(sys.argv) != 4):
        print( "plot self-gating signal against rtnlinv images." )
        print( "Usage: self_gating.py <eof> <rtnlinv> <outfile>" )
        exit()
        
    self_gating( sys.argv[1], sys.argv[2], sys.argv[3] )
