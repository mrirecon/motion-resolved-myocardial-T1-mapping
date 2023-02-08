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

delays=($(ls -d delay*s*cfl))

data_folder=../data/phantom

for i in "${delays[@]}"
do	
	echo "$i"
	tnum=$(echo $i| cut -d'-' -f 1)
	echo $tnum
	NBR=256
	start_IR=1
	
	bart resize -c 0 $NBR 1 $NBR ${tnum}-reco_${start_IR}IR tmp_maps
	bart looklocker -t0.2 -D15.3e-3 tmp_maps ${tnum}-reco_T1

	bart fmac $data_folder/phan_mask ${tnum}-reco_T1 tmp-T1_masked

	bart roistat -M  $data_folder/ROIs tmp-T1_masked ${tnum}-${start_IR}IR-T1_mean
	bart roistat -D  $data_folder/ROIs tmp-T1_masked ${tnum}-${start_IR}IR-T1_std

	bart extract 0 64 192 1 59 187 tmp-T1_masked ${tnum}-reco_T1_resized
	python3 ../utils/save_maps.py ${tnum}-reco_T1_resized viridis 0 1.7 ../Figure2/${tnum}-reco_T1_resized.png

	delay=$(echo $tnum| cut -d'y' -f 2)
	echo $delay

	case $delay in

	0s)
	delay_time=0
	;;

	1s)
	delay_time=306
	;;

	2s)
	delay_time=612
	;;

	3s)
	delay_time=917
	;;

	4s)
	delay_time=1223
	;;

	5s)
	delay_time=1529
	;;

	6s)
	delay_time=1835
	;;

	*)
	echo -n "unknown"
	;;
	esac

	python3 ../utils/partial_LL_correct.py tmp_maps 3.27e-3 915 $delay_time tmp-corrected_T1
	bart fmac  $data_folder/phan_mask tmp-corrected_T1 tmp-corrected_T1_masked
	
	bart roistat -M  $data_folder/ROIs tmp-corrected_T1_masked ${tnum}-${start_IR}IR-corrected-T1_mean
	bart roistat -D  $data_folder/ROIs tmp-corrected_T1_masked ${tnum}-${start_IR}IR-corrected-T1_std

	bart extract 0 64 192 1 59 187 tmp-corrected_T1_masked ${tnum}-reco_corrected_T1_resized
	python3 ../utils/save_maps.py ${tnum}-reco_corrected_T1_resized viridis 0 1.7 ../Figure2/${tnum}-reco_corrected_T1_resized.png
done

# Display quantitaive T1 values #

echo "Display quantitative T1 values before and after correction: "

for i in "${delays[@]}"
do	
	tnum=$(echo $i| cut -d'-' -f 1)
	start_IR=1
	echo ""
	echo "$tnum: T1 before correction: "
	bart show ${tnum}-${start_IR}IR-T1_mean
	echo "$tnum: T1 after correction: "
	bart show ${tnum}-${start_IR}IR-corrected-T1_mean
done

rm tmp*
