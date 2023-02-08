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

[ -d $dir ] || mkdir $dir

cd $dir

infile=../data/phantom/raw_data
delays=($(ls -d $infile/delay*))

nIRs=3

for i in "${delays[@]}"
do	
	echo "$i"
	tnum=$(echo $i| cut -d'/' -f 5)
	echo $tnum
	bart extract 12 0 $nIRs $i/ksp tmp_ksp0
	NSPK=$(bart show -d1 tmp_ksp0)
	NFRM=$(bart show -d10 tmp_ksp0)
	bart transpose 1 9 tmp_ksp0 tmp_ksp1
	FLAG=$(bart bitmask 9 10 12)
	bart reshape $FLAG 1 $((NSPK*NFRM*nIRs)) 1 tmp_ksp1 tmp_ksp2


	GA=7
	overgrid=1.0
	nspokes_per_frame=15
	alpha_min=0.002
	TR=3270
	READ=$(bart show -d0 tmp_ksp2)
	NBR=$((READ/2))
	nspokes=$(bart show -d10 tmp_ksp2)

	opts_prep="-s$READ -R$TR -G$GA -p$nspokes -f$nspokes_per_frame"

	./../prep_single_shot.sh $opts_prep tmp_ksp2 tmp-data tmp-traj tmp-TI

	NF=$(bart show -d5 tmp-TI)

	# reco data from the second inversion 
	start_IR=1

	bart extract 5 $((start_IR*NF/3)) $(((start_IR+1)*NF/3)) tmp-traj tmp-traj1
	bart extract 5 $((start_IR*NF/3)) $(((start_IR+1)*NF/3)) tmp-data tmp-data1

	bart extract 5 0 $((1*NF/3)) tmp-TI tmp-TI1

	./../reco_single_shot.sh -a$alpha_min -k -o$overgrid tmp-TI1 tmp-traj1 tmp-data1 ${tnum}-reco_${start_IR}IR		
done

rm tmp*
