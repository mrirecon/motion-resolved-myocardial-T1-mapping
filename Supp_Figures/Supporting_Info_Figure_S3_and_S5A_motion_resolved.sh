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


#-------------vol_01--------------#
# mid-slice
# scan #1

prefix=vol-1-scan-1
startc=19
startr=1
startx=75
starty=52

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-1-scan-2
startc=16
startr=1
startx=75
starty=52

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# basal-slice
prefix=vol-1-basal
startc=19
startr=1
startx=70
starty=48

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# apical-slice
prefix=vol-1-apical
startc=14
startr=1
startx=75
starty=47

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

#-------------vol_02--------------#
# mid-slice
# scan #1

prefix=vol-2-scan-1
startc=18
startr=1
startx=83
starty=73

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-2-scan-2
startc=17
startr=1
startx=83
starty=73

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

#-------------vol_03--------------#
# mid-slice
# scan #1

prefix=vol-3-scan-1
startc=18
startr=1
startx=78
starty=55

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-3-scan-2
startc=19
startr=1
startx=78
starty=50

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

#-------------vol_04--------------#
# mid-slice
# scan #1

prefix=vol-4-scan-1
startc=19
startr=1
startx=72
starty=61

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-4-scan-2
startc=19
startr=1
startx=72
starty=61

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

#-------------vol_05--------------#
# mid-slice
# scan #1

prefix=vol-5-scan-1
startc=18
startr=1
startx=81
starty=68

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-5-scan-2
startc=18
startr=1
startx=81
starty=68

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

#-------------vol_06--------------#
# mid-slice
# scan #1

prefix=vol-6-scan-1
startc=17
startr=1
startx=74
starty=50

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-6-scan-2
startc=17
startr=1
startx=74
starty=50

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

#-------------vol_07--------------#
# mid-slice
# scan #1

prefix=vol-7-scan-1
startc=18
startr=1
startx=80
starty=50

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-7-scan-2
startc=18
startr=1
startx=80
starty=50

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

#-------------vol_08--------------#
# mid-slice
# scan #1

prefix=vol-8-scan-1
startc=15
startr=1
startx=70
starty=47

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-8-scan-2
startc=19
startr=1
startx=65
starty=45

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png


#-------------vol_09--------------#
# mid-slice
# scan #1

prefix=vol-9-scan-1
startc=19
startr=1
startx=87
starty=70

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-9-scan-2
startc=0
startr=1
startx=87
starty=70

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

#-------------vol_10--------------#
# mid-slice
# scan #1

prefix=vol-10-scan-1
startc=0
startr=1
startx=77
starty=68

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-10-scan-2
startc=17
startr=1
startx=77
starty=68

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# basal-slice
prefix=vol-10-basal
startc=17
startr=1
startx=85
starty=70

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# apical-slice
prefix=vol-10-apical
startc=11
startr=1
startx=70
starty=75

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

#-------------vol_11--------------#
# mid-slice
# scan #1

prefix=vol-11-scan-1
startc=17
startr=1
startx=79
starty=51

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png

# scan #2
prefix=vol-11-scan-2
startc=17
startr=1
startx=77
starty=68

Mask_Export_T1_Maps $prefix-t1map $prefix-t1map_corrected $startc $startr $startx $starty $prefix-t1map_corrected-crop.png
