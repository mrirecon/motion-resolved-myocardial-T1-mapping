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
# scan #1

prefix=vol-1-scan-1
startc=19
startr=1

T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-1-scan-2
startc=16
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done


#-------------vol_02--------------#
# scan #1

prefix=vol-2-scan-1
startc=18
startr=1

T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-2-scan-2
startc=17
startr=1

T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_03--------------#
# scan #1

prefix=vol-3-scan-1
startc=18
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2//$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-3-scan-2
startc=19
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_04--------------#
# scan #1

prefix=vol-4-scan-1
startc=19
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-4-scan-2
startc=19
startr=1

T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_05--------------#
# scan #1

prefix=vol-5-scan-1
startc=18
startr=1

T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-5-scan-2
startc=18
startr=1

T1=$prefix-t1map_corrected


for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_06--------------#
# scan #1

prefix=vol-6-scan-1
startc=17
startr=1

T1=$prefix-t1map_corrected


for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-6-scan-2
startc=18
startr=1

T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_07--------------#
# scan #1

prefix=vol-7-scan-1
startc=17
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-7-scan-2
startc=18
startr=1

T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_08--------------#
# scan #1

prefix=vol-8-scan-1
startc=15
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-8-scan-2
startc=19
startr=1

T1=$prefix-t1map_corrected


for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_09--------------#
# scan #1

prefix=vol-9-scan-1
startc=19
startr=1

T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-9-scan-2
startc=0
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

#-------------vol_10--------------#
# scan #1

prefix=vol-10-scan-1
startc=0
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done


prefix=vol-10-scan-2
startc=17
startr=1

T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done


#-------------vol_11--------------#
# scan #1

prefix=vol-11-scan-1
startc=17
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done

# scan #2

prefix=vol-11-scan-2
startc=19
startr=1


T1=$prefix-t1map_corrected

for (( r=7; r<=12; r++ ))
do 
        ROI_T1_Calc $dir2/$T1 $startc $startr $dir3/$prefix-ROI$r $T1-ROI$r-mean $T1-ROI$r-std
done


# join all quantitative values
for (( r=7; r<=12; r++ ))
do
        for ((j=1; j<=2; j++))
        do
                bart join 10 `seq -f "vol-%g-scan-$j-t1map_corrected-ROI$r-mean" 1 11` tmp-vols-scan-$j-ROI$r-mean
        done
        bart join 11 `seq -f "tmp-vols-scan-%g-ROI$r-mean" 1 2` tmp-vols-scans-ROI$r-mean
done
bart join 12 `seq -f "tmp-vols-scans-ROI%g-mean" 7 12` vols-scans-ROIs-mean

# Bull's eye mean values
bart reshape $(bart bitmask 10 11) 22 1 vols-scans-ROIs-mean vols-scans-ROIs-mean-1
bart avg $(bart bitmask 10) vols-scans-ROIs-mean-1 vols-scans-ROIs-mean-bullseye
bart show vols-scans-ROIs-mean-bullseye

rm tmp*
