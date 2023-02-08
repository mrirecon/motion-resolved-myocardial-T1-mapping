#!/bin/bash
# 
# Copyright 2022. TU Graz. Institute of Biomedical Imaging.
# Copyright 2020-2022. Uecker Lab. University Medical Center Göttingen.
#
# Author: Xiaoqing Wang, 2020-2022
# xwang@tugraz.at
# xiaoqingwang2010@gmail.com
#
# Wang X et al.
# Free-Breathing Myocardial T1 Mapping using Inversion‐Recovery 
# Radial FLASH and Motion-Resolved Model-Based Reconstruction.
# Magn Reson Med. (2022), DOI: 10.1002/mrm.29521.

set -e


dir=invivo

cd ../$dir

Mask_Export_T1_Maps () {

        T1_LL=$1
        T1_New_Corr=$2
        startc=$3
        startr=$4
        startx=$5
        starty=$6

        # extract the end-diastolic and end-expiration T1 map
        bart squeeze $T1_LL tmp_LL
        bart squeeze $T1_New_Corr tmp_New_Corr
        bart extract 2 $startc $((startc+1)) 3 $startr $((startr+1)) tmp_LL tmp_LL-diastolic
        bart extract 2 $startc $((startc+1)) 3 $startr $((startr+1)) tmp_New_Corr tmp_New_Corr-diastolic

        # create and apply mask 
        bart threshold -B 0.06 tmp_LL-diastolic tmp_mask

        bart fmac tmp_New_Corr-diastolic tmp_mask tmp_New_Corr-T1-masked

        # extract the centeral heart part
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) tmp_New_Corr-T1-masked tmp_New_Corr-T1-masked-crop

        # save maps
        python3 ../utils/save_maps.py tmp_New_Corr-T1-masked-crop viridis 0 1.7 $7.png

        rm tmp*
}

T1_line_profile () {

        T1_LL=$1
        T1_New_Corr=$2
        start_line=$3
        startr=$4
        startx=$5
        starty=$6
        line_axis=$7

        # extract the end-diastolic and end-expiration T1 map
        bart squeeze $T1_LL tmp_LL
        bart squeeze $T1_New_Corr tmp_New_Corr

        # create and apply mask 
        bart threshold -B 0.06 tmp_LL tmp_mask

        bart fmac tmp_New_Corr tmp_mask tmp_New_Corr-T1-masked

        # extract the centeral heart part
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) tmp_New_Corr-T1-masked tmp_New_Corr-T1-masked-crop

        bart extract $line_axis $start_line $((start_line+1)) 3 $startr $((startr+1)) tmp_New_Corr-T1-masked-crop tmp-line_profile

        # save maps
        python3 ../utils/save_maps.py tmp-line_profile viridis 0 1.7 $8.png

        rm tmp*
}

dir=../Figure8

# vol #2 scan#2
startc_dias=17
startc_sys=5
startr=1
startx=83
starty=73
start_line=58
line_axis=1

# reg = 0.005
prefix=vol-2-scan-2

# diastolic
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc_dias $startr $startx $starty $dir/$prefix-t1map_corrected-dias-crop.png

# systolic
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc_sys $startr $startx $starty $dir/$prefix-t1map_corrected-sys-crop.png

# line profile
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $line_axis $dir/$prefix-$start_line-line_profile.png


# vol #3 scan#1

startc_dias=18
startc_sys=6
startr=1
startx=78
starty=50
line_axis=0
start_line=56

# reg = 0.005
prefix=vol-3-scan-1

# diastolic
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc_dias $startr $startx $starty $dir/$prefix-t1map_corrected-dias-crop.png

# systolic
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc_sys $startr $startx $starty $dir/$prefix-t1map_corrected-sys-crop.png

# line profile
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $line_axis $dir/$prefix-$start_line-line_profile.png
