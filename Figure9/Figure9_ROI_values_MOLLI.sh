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


cd ../invivo

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

data_folder=../data/volunteer/volunteer/MOLLI/mid/T1maps
ROI_folder=../data/volunteer/volunteer/MOLLI/mid/ROIs

#-------------vol_01--------------#
# scan #1

MOLLI=vol1-MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol1-MOLLI-2

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done



#-------------vol_02--------------#
# scan #1

MOLLI=vol2-MOLLI-1

bart flip $(bart bitmask 0) $data_folder/$MOLLI $MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $MOLLI-1 $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol2-MOLLI-2

bart flip $(bart bitmask 0) $data_folder/$MOLLI $MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $MOLLI-1 $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_03--------------#
# scan #1

MOLLI=vol3-MOLLI-1

bart transpose 0 1 $data_folder/$MOLLI tmp
bart flip $(bart bitmask 1) tmp tmp1
bart transpose 0 1 tmp1 $MOLLI-1
rm tmp*

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $MOLLI-1 $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol3-MOLLI-2

bart transpose 0 1 $data_folder/$MOLLI tmp
bart flip $(bart bitmask 1) tmp tmp1
bart transpose 0 1 tmp1 $MOLLI-1
rm tmp*

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $MOLLI-1 $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_04--------------#
# scan #1

MOLLI=vol4-MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol4-MOLLI-2

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done


#-------------vol_05--------------#
# scan #1

MOLLI=vol5-MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol5-MOLLI-2

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done


#-------------vol_06--------------#
# scan #1

MOLLI=vol6-MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol6-MOLLI-2

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done


#-------------vol_07--------------#
# scan #1

MOLLI=vol7-MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol7-MOLLI-2

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done


#-------------vol_08--------------#
# scan #1

MOLLI=vol8-MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol8-MOLLI-2

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done


#-------------vol_09--------------#
# scan #1

MOLLI=vol9-MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol9-MOLLI-2

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

#-------------vol_10--------------#
# scan #1

MOLLI=vol10-MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol10-MOLLI-2

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done


#-------------vol_11--------------#
# scan #1

MOLLI=vol11-MOLLI-1

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done

# scan #2

MOLLI=vol11-MOLLI-2

for (( r=7; r<=12; r++ ))
do 
        ROI_MOLLI_T1_Calc $data_folder/$MOLLI $ROI_folder/$MOLLI-ROI$r $MOLLI-ROI$r-mean $MOLLI-ROI$r-std
done
