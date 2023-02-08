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
        bart threshold -B 0.05 tmp_LL-diastolic tmp_mask

        bart fmac tmp_New_Corr-diastolic tmp_mask tmp_New_Corr-T1-masked

        # extract the centeral heart part
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) tmp_New_Corr-T1-masked tmp_New_Corr-T1-masked-crop

        # save maps
        python3 ../utils/save_maps.py tmp_New_Corr-T1-masked-crop viridis 0 1.7 $7.png
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
        bart threshold -B 0.05 tmp_LL tmp_mask

        bart fmac tmp_New_Corr tmp_mask tmp_New_Corr-T1-masked

        # extract the centeral heart part
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) tmp_New_Corr-T1-masked tmp_New_Corr-T1-masked-crop

        bart extract 1 $start_line $((start_line+1)) 3 $startr $((startr+1)) tmp_New_Corr-T1-masked-crop tmp-line_profile

        # save maps
        python3 ../utils/save_maps.py tmp-line_profile viridis 0 1.7 $7.png

        rm tmp*
}

ROI_T1_Calc () {

        T1_New_Corr=$1
        startc=$2
        startr=$3
        T1_ROI=$4
        T1_ROI_mean=$5
        T1_ROI_std=$6

        # extract the end-diastolic and end-expiration T1 map
        bart squeeze $T1_New_Corr tmp_New_Corr
        bart extract 2 $startc $((startc+1)) 3 $startr $((startr+1)) tmp_New_Corr tmp_New_Corr-diastolic

        # apply ROI mask, calculate T1 mean/std values
        bart roistat -M $T1_ROI tmp_New_Corr-diastolic $T1_ROI_mean
        bart roistat -D $T1_ROI tmp_New_Corr-diastolic $T1_ROI_std

        bart show $T1_ROI_mean
        bart show $T1_ROI_std

        rm tmp*
}

dir=../Figure7

startc=17
startr=1
startx=83
starty=73
start_line=58

# reg = 0.005
prefix=vol-2-scan-2-r7-0.005
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $dir/$prefix-t1map_corrected-crop.png
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $dir/$prefix-$start_line-line_profile.png
ROI_T1_Calc $prefix-t1map_corrected $startc $startr ../data/volunteer/vol-2/scan-2/vol-2-scan-2-septum-mask $prefix-t1map_corrected-septum-mean $prefix-t1map_corrected-septum-std

# reg = 0.004
prefix=vol-2-scan-2-r7-0.004
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $dir/$prefix-t1map_corrected-crop.png
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $dir/$prefix-line_profile.png
ROI_T1_Calc $prefix-t1map_corrected $startc $startr ../data/volunteer/vol-2/scan-2/vol-2-scan-2-septum-mask $prefix-t1map_corrected-septum-mean $prefix-t1map_corrected-septum-std

# reg = 0.006
prefix=vol-2-scan-2-r7-0.006
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $dir/$prefix-t1map_corrected-crop.png
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $dir/$prefix-line_profile.png
ROI_T1_Calc $prefix-t1map_corrected $startc $startr ../data/volunteer/vol-2/scan-2/vol-2-scan-2-septum-mask $prefix-t1map_corrected-septum-mean $prefix-t1map_corrected-septum-std

# reg = 0.007
prefix=vol-2-scan-2-r7-0.007
Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $dir/$prefix-t1map_corrected-crop.png
T1_line_profile $prefix-t1map $prefix-t1map_corrected $start_line $startr $startx $starty $dir/$prefix-line_profile.png
ROI_T1_Calc $prefix-t1map_corrected $startc $startr ../data/volunteer/vol-2/scan-2/vol-2-scan-2-septum-mask $prefix-t1map_corrected-septum-mean $prefix-t1map_corrected-septum-std

# join the mean T1 values
bart join 10 vol-2-scan-2-r7-0.004-t1map_corrected-septum-mean vol-2-scan-2-r7-0.005-t1map_corrected-septum-mean vol-2-scan-2-r7-0.006-t1map_corrected-septum-mean vol-2-scan-2-r7-0.007-t1map_corrected-septum-mean vol-2-scan-2-regs-mean
bart join 10 vol-2-scan-2-r7-0.004-t1map_corrected-septum-std vol-2-scan-2-r7-0.005-t1map_corrected-septum-std vol-2-scan-2-r7-0.006-t1map_corrected-septum-std vol-2-scan-2-r7-0.007-t1map_corrected-septum-std vol-2-scan-2-regs-std

python3 ../utils/plot_septal_T1_regs.py vol-2-scan-2-regs-mean vol-2-scan-2-regs-std $dir/Figure7B.pdf
