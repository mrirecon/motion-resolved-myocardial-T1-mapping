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
# Free-Breathing Myocardial T1 Mapping using Inversion-Recovery 
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

        # extract the end-diastolic and end-expiration T1 map
        bart squeeze $T1_LL tmp_LL
        bart squeeze $T1_New_Corr tmp_New_Corr

        # create and apply mask 
        bart threshold -B 0.06 tmp_LL tmp_mask

        bart fmac tmp_New_Corr tmp_mask tmp_New_Corr-T1-masked

        # extract the centeral heart part
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) tmp_New_Corr-T1-masked tmp_New_Corr-T1-masked-crop

        bart extract 1 $start_line $((start_line+1)) 3 $startr $((startr+1)) tmp_New_Corr-T1-masked-crop tmp-line_profile

        # save maps
        python3 ../utils/save_maps.py tmp-line_profile viridis 0 1.7 $7.png

        rm tmp*
}


dir=../Figure6

startc=17
startr=1
startx=83
starty=73
start_line=58

# reg: l1 Wavelet with 0.02
prefix=vol-2-scan-2-r0-0.02
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $dir/$prefix-t1map_corrected-crop.png
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $dir/$prefix-$start_line-line_profile.png

# reg: temporal TV with 0.02
prefix=vol-2-scan-2-r9-0.02
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $dir/$prefix-t1map_corrected-crop.png
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $dir/$prefix-$start_line-line_profile.png

# reg: l1 Wavelet + temporal TV with 0.006
prefix=vol-2-scan-2-r1-0.006
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $dir/$prefix-t1map_corrected-crop.png
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $dir/$prefix-$start_line-line_profile.png

# reg: l1 Wavelet + spatiotemporal TV with 0.005
prefix=vol-2-scan-2-r7-0.005
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $dir/$prefix-t1map_corrected-crop.png
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $dir/$prefix-$start_line-line_profile.png
