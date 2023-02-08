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

set -e

dir=pig

cd ../$dir

# Native T1 maps
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
        python3 ../utils/save_maps.py tmp_New_Corr-T1-masked-crop viridis 0 2.3 $7.png
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

ROI_MOLLI_T1_Calc () {

        T1_MOLLI=$1
        T1_ROI=$2
        T1_ROI_mean=$3
        T1_ROI_std=$4

        bart roistat -M $T1_ROI $T1_MOLLI $T1_ROI_mean
        bart roistat -D $T1_ROI $T1_MOLLI $T1_ROI_std

        bart show $T1_ROI_mean
        bart show $T1_ROI_std
}


# diastolic

prefix=pig
startc=19
startr=1
startx=60
starty=65

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-diastolic-crop.png

# systolic

startc=12
startr=1
startx=60
starty=65

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-systolic-crop.png

# quantitative results 
# diastolic
startc=19
startr=1

T1=$prefix-t1map_corrected

dir2=../data/pig/ROIs/FB-diastolic

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $T1 $startc $startr $dir2/$prefix-diastolic-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done


# systolic
startc=12
startr=1

T1=$prefix-t1map_corrected

dir2=../data/pig/ROIs/FB-systolic

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $T1 $startc $startr $dir2/$prefix-systolic-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#MOLLI 
MOLLI=Pig-diastolic-nativ

dir2=../data/pig/MOLLI

python3 ../utils/save_maps.py $dir2/$MOLLI viridis 0 2300 $MOLLI.png

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $dir2/$MOLLI $dir2/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done
