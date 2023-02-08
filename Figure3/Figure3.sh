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

cd ../$dir

data_folder=../data/phantom

T1_SAVE () {

        T1_New_Corr=$1
        T1_ROI=$2
        T1_ROI_mean=$3
        T1_ROI_std=$4
	T1_out=$5

        # apply mask and extract the end-diastolic and end-expiration T1 map
 	bart fmac $data_folder/phan_mask $T1_New_Corr tmp-corrected_T1s_masked
	bart extract 2 16 17 3 1 2 tmp-corrected_T1s_masked tmp-corrected_T1_masked

        # apply ROI mask, calculate T1 mean/std values
        bart roistat -M $T1_ROI tmp-corrected_T1_masked $T1_ROI_mean
        bart roistat -D $T1_ROI tmp-corrected_T1_masked $T1_ROI_std

        bart show $T1_ROI_mean
        bart show $T1_ROI_std

	# save T1 maps
	bart extract 0 64 192 1 59 187 tmp-corrected_T1_masked $T1_out
	python3 ../utils/save_maps.py $T1_out viridis 0 1.7 ../Figure3/$T1_out.png

        rm tmp*
}



TR=3.27e-3
RES=256

# reco type 0, reg_para=0.005
reg_type=0
reg_para=0.005

prefix=phantom-r$reg_type-$reg_para

T1_SAVE $prefix-t1map_corrected $data_folder/ROIs $prefix-T1-mean $prefix-T1-std $prefix-T1


# reco type 0, reg_para=0.02
reg_type=0
reg_para=0.02

prefix=phantom-r$reg_type-$reg_para

T1_SAVE $prefix-t1map_corrected $data_folder/ROIs $prefix-T1-mean $prefix-T1-std $prefix-T1


# reco type 7, reg_para=0.005
reg_type=7
reg_para=0.005

prefix=phantom-r$reg_type-$reg_para

T1_SAVE $prefix-t1map_corrected $data_folder/ROIs $prefix-T1-mean $prefix-T1-std $prefix-T1

