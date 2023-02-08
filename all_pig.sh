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
# run motion-resolved model-based reconstruction for the pig data
#

set -eux

# pig experiment (TR = 3.30e-3)
dir=pig

[ -d $dir ] || mkdir $dir

cd $dir


prefix=pig
folder=../data/pig/raw_data

TR=3.30e-3
RES=256

echo $prefix

./../run.sh -r7 -a0.005 -o1.25 -R3300 $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt $prefix-para-maps $prefix-sens $prefix-reco-log
./../post.sh -R$TR -r$RES $prefix-para-maps $prefix-para-maps-$RES $prefix-t1map $prefix-t1map_corrected
