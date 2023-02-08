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
# Free‐Breathing Myocardial T1 Mapping using Inversion‐Recovery 
# Radial FLASH and Motion‐Resolved Model‐Based Reconstruction.
# Magn Reson Med. (2022), DOI: 10.1002/mrm.29521.


set -e

dir=invivo

cd ../$dir

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

dir3=../data/volunteer/volunteer/ROIs

dir2=$PWD

#-------------vol_01--------------#
# basal

prefix=vol-1-basal
startc=19
startr=1

T1=$prefix-t1map_corrected

for (( r=1; r<=6; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# apical

prefix=vol-1-apical
startc=15
startr=1


T1=$prefix-t1map_corrected

for (( r=13; r<=16; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done


#-------------vol_04--------------#
# basal

prefix=vol-4-basal
startc=17
startr=1

T1=$prefix-t1map_corrected

for (( r=1; r<=6; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# apical

prefix=vol-4-apical
startc=19
startr=1

T1=$prefix-t1map_corrected

for (( r=13; r<=16; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_08--------------#
# basal

prefix=vol-8-basal
startc=19
startr=1


T1=$prefix-t1map_corrected

for (( r=1; r<=6; r++ ))
do 
        ROI_T1_Calc $dir2//$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# apical

prefix=vol-8-apical
startc=19
startr=1


T1=$prefix-t1map_corrected

for (( r=13; r<=16; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_09--------------#
# basal

prefix=vol-9-basal
startc=19
startr=1


T1=$prefix-t1map_corrected

for (( r=1; r<=6; r++ ))
do 
        ROI_T1_Calc $dir2//$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# apical

prefix=vol-9-apical
startc=2
startr=1


T1=$prefix-t1map_corrected

for (( r=13; r<=16; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_10--------------#
# basal

prefix=vol-10-basal
startc=17
startr=1


T1=$prefix-t1map_corrected

for (( r=1; r<=6; r++ ))
do 
        ROI_T1_Calc $dir2//$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# apical

prefix=vol-10-apical
startc=11
startr=1


T1=$prefix-t1map_corrected

for (( r=13; r<=16; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done


#-------------vol_11--------------#
# basal

prefix=vol-11-basal
startc=17
startr=1


T1=$prefix-t1map_corrected

for (( r=1; r<=6; r++ ))
do 
        ROI_T1_Calc $dir2//$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# apical

prefix=vol-11-apical
startc=16
startr=1


T1=$prefix-t1map_corrected

for (( r=13; r<=16; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# join all quantitative values

# basal
u=1
for k in 1 4 8 9 10 11
do
        bart join 10 `seq -f "vol-$k-basal-t1map_corrected-ROI%g-mean" 1 6` tmp-vols-basal-ROI-mean-$u
        u=$((u+1))
done

bart join 11 `seq -f "tmp-vols-basal-ROI-mean-%g" 1 6` vols-basal-ROI-mean

bart avg $(bart bitmask 11) vols-basal-ROI-mean vols-basal-ROI-mean-bullseye

bart show vols-basal-ROI-mean-bullseye

# apical

u=1
for k in 1 4 8 9 10 11
do
        bart join 10 `seq -f "vol-$k-apical-t1map_corrected-ROI%g-mean" 13 16` tmp-vols-apical-ROI-mean-$u
        u=$((u+1))
done

bart join 11 `seq -f "tmp-vols-apical-ROI-mean-%g" 1 6` vols-apical-ROI-mean

bart avg $(bart bitmask 11) vols-apical-ROI-mean vols-apical-ROI-mean-bullseye

bart show vols-apical-ROI-mean-bullseye

rm tmp*
