#!/bin/bash
# 
# Copyright 2022. TU Graz. Institute of Biomedical Imaging.
# Copyright 2022. Uecker Lab. University Medical Center Göttingen.
#
# Author: 
# Xiaoqing Wang, 2020-2022
# xwang@tugraz.at
# xiaoqingwang2010@gmail.com
#
# Wang X et al.
# Free-Breathing Myocardial T1 Mapping using Inversion-Recovery 
# Radial FLASH and Motion-Resolved Model-Based Reconstruction.
# Magn Reson Med. (2022), DOI: 10.1002/mrm.29521.

set -eux

dir=phantom

[ -d $dir ] || mkdir $dir

cd $dir


infile=../data/phantom/raw_data

delays=($(ls -d $infile/delay*3s))
nIRs=21
tnum=$(echo $delays | cut -d'/' -f 9)


folder=../data/phantom/raw_data/delay3s

eof=$folder/vol-3_scan-1-eof

bart squeeze $eof EOF

TR=3.27e-3
RES=256

# reco type 0, reg_para=0.005
reg_type=0
reg_para=0.005

prefix=phantom-r$reg_type-$reg_para

./../run.sh -r$reg_type -a$reg_para -o1.0 -R3270 -E $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt \
	EOF $prefix-maps $prefix-sens $prefix-log

./../post.sh -R$TR -r$RES $prefix-maps $prefix-maps-$RES $prefix-t1map $prefix-t1map_corrected


# reco type 0, reg_para=0.02
reg_type=0
reg_para=0.02

bart squeeze $eof EOF

prefix=phantom-r$reg_type-$reg_para

./../run.sh -r$reg_type -a$reg_para -o1.0 -R3270 -E $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt \
	EOF $prefix-maps $prefix-sens $prefix-log

./../post.sh -R$TR -r$RES $prefix-maps $prefix-maps-$RES $prefix-t1map $prefix-t1map_corrected


# reco type 7, reg_para=0.005
reg_type=7
reg_para=0.005

bart squeeze $eof EOF

prefix=phantom-r$reg_type-$reg_para

./../run.sh -r$reg_type -a$reg_para -o1.0 -R3270 -E $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt \
	EOF $prefix-maps $prefix-sens $prefix-log

./../post.sh -R$TR -r$RES $prefix-maps $prefix-maps-$RES $prefix-t1map $prefix-t1map_corrected

