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

# Basal T1 values (subset)
data_folder=../data/volunteer/volunteer/MOLLI/basal/T1maps
ROI_folder=../data/volunteer/volunteer/MOLLI/basal/ROIs

#-------------vol_01--------------#
MOLLI=vol1-MOLLI-base

for (( r=1; r<=6; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_04--------------#
MOLLI=vol4-MOLLI-base

for (( r=1; r<=6; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_08--------------#
MOLLI=vol8-MOLLI-base

for (( r=1; r<=6; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_09--------------#
MOLLI=vol9-MOLLI-base

for (( r=1; r<=6; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_10--------------#
MOLLI=vol10-MOLLI-base

for (( r=1; r<=6; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_11--------------#
MOLLI=vol11-MOLLI-base

for (( r=1; r<=6; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done


# Apical T1 values (subset)
# Basal T1 values (subset)
data_folder=../data/volunteer/volunteer/MOLLI/apex/T1maps
ROI_folder=../data/volunteer/volunteer/MOLLI/apex/ROIs

#-------------vol_1--------------#
MOLLI=vol1-MOLLI-apex

for (( r=13; r<=16; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_4--------------#
MOLLI=vol4-MOLLI-apex

for (( r=13; r<=16; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_8--------------#
MOLLI=vol8-MOLLI-apex

for (( r=13; r<=16; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_9--------------#
MOLLI=vol9-MOLLI-apex

for (( r=13; r<=16; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_10--------------#
MOLLI=vol10-MOLLI-apex

for (( r=13; r<=16; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_11--------------#
MOLLI=vol11-MOLLI-apex

for (( r=13; r<=16; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done
