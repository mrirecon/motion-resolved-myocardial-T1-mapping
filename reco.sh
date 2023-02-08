#!/bin/bash
# 
# Copyright 2022. TU Graz. Institute of Biomedical Imaging.
# Copyright 2020-2022. Uecker Lab. University Medical Center Göttingen.
#
# Author: Xiaoqing Wang, 2020-2022
# xwang@tugraz.at
# xiaoqingwang2010@gmail.com

# Wang X et al.
# Free-Breathing Myocardial T1 Mapping using Inversion-Recovery 
# Radial FLASH and Motion-Resolved Model-Based Reconstruction.
# Magn Reson Med. (2022), DOI: 10.1002/mrm.29521.
#

set -e

usage="Usage: $0 [-w reg_l1Wav] [-t reg_tv_resp] [-T reg_tv_cardiac] [-a alpha_min] [-u u] [-k] [-o overgrid] [-g] [-R reg_type] <TI> <traj> <ksp> <output> <output_sens>"

if [ $# -lt 4 ] ; then

        echo "$usage" >&2
        exit 1
fi

k_filter=0
use_gpu=0
reg_type=2

while getopts "hw:t:T:a:u:ko:gR:" opt; do
	case $opt in
	h) 
		echo "$usage"
		exit 0 
		;;		
	w) 
		reg_l1Wav=${OPTARG}
		;;
	t) 
		reg_tv_resp=${OPTARG}
		;;
        T) 
		reg_tv_cardiac=${OPTARG}
		;;
        a) 
		alpha_min=${OPTARG}
		;;
        u) 
		u=${OPTARG}
		;;
	k)
		k_filter=1
		;;
	o)
		overgrid=${OPTARG}
		;;
	g)
		use_gpu=1
		;;
	R)
		reg_type=${OPTARG}
		;;
	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done
shift $(($OPTIND -1 ))

TI=$(readlink -f "$1")
traj=$(readlink -f "$2")
ksp=$(readlink -f "$3")
reco=$(readlink -f "$4")

if [ "$#" -lt 5 ] ; then
	sens=""
else
	sens=$(readlink -f "$5")
fi

if [ ! -e ${TI}.cfl ] ; then
	echo "Input file 'TI' does not exist." >&2
	echo "$usage" >&2
	exit 1
fi

if [ ! -e ${traj}.cfl ] ; then
	echo "Input file 'traj' does not exist." >&2
	echo "$usage" >&2
	exit 1
fi

if [ ! -e ${ksp}.cfl ] ; then
	echo "Input file 'ksp' does not exist." >&2
	echo "$usage" >&2
	exit 1
fi


function calc() { awk "BEGIN { print "$*" }"; }

#WORKDIR=$(mktemp -d)
# Mac: http://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT
cd $WORKDIR

# Motion-resolved model-based T1 reconstruction:

START=$(date +%s)

which bart
bart version

opts="-L -d4 -R3 -i10 -C100 -u$u -o$overgrid -j$alpha_min -rS:0.0 -rQ:1.0 "

	  
case "$reg_type" in

	   
0)
	opts+="-rW:$(bart bitmask 0 1):$(bart bitmask 6):${reg_l1Wav}"

	echo -e "l1-Wavelet spatial regularization with joint thresholding 
		using the parameter ${reg_l1Wav}"
	;;
1) 
	opts+="-rW:$(bart bitmask 0 1):$(bart bitmask 6):${reg_l1Wav}
		-rT:$(bart bitmask 10):0:${reg_tv_cardiac}
		-rT:$(bart bitmask 11):0:${reg_tv_resp}"

	echo -e "l1-Wavelet spatial regularization with joint thresholding 
		using the parameter ${reg_l1Wav} +
		TV regularizations along the cardiac and respiration dimensions 
		separately using parameters ${reg_tv_cardiac} and ${reg_tv_resp}"
	;;
2) 	
	opts+="-rW:$(bart bitmask 0 1):$(bart bitmask 6):${reg_l1Wav}
	  	-rT:$(bart bitmask 10 11):0:${reg_tv_cardiac}"

	echo -e "l1-Wavelet spatial regularization with joint thresholding 
		using the parameter ${reg_l1Wav} +
		TV regularizations along the cardiac and respiration dimensions 
		jointly using the parameter ${reg_tv_cardiac}"
	;;
3) 	
	opts+="-rT:$(bart bitmask 10 11):0:${reg_tv_cardiac}"

	echo -e "TV regularizations along the cardiac and respiration dimensions 
		jointly using the parameter ${reg_tv_cardiac}"
	;;
4) 	
	opts+="rT:$(bart bitmask 0 1):$(bart bitmask 6):${reg_tv_cardiac}
		-rT:$(bart bitmask 10 11):0:${reg_tv_cardiac}"

	echo -e "Spatial TV with joint thresholding using the parameter ${reg_tv_cardiac} +
		TV regularizations along the cardiac and respiration dimensions 
		jointly using the parameter ${reg_tv_cardiac}"
	;;
5) 	
	opts+="-rT:$(bart bitmask 0 1 10 11):$(bart bitmask 6):${reg_tv_cardiac}"

	echo -e "TV regularizations along the spatial, cardiac and respiration 
		dimensions jointly with a joint thresholding using the parameter 
		${reg_tv_cardiac}"
	;;
6) 	
	opts+="-rT:$(bart bitmask 0 1 10 11):$(bart bitmask 6):${reg_tv_cardiac}
		-rW:$(bart bitmask 0 1):$(bart bitmask 6):${reg_l1Wav}"

	echo -e "l1-Wavelet spatial regularization with joint thresholding 
		using the parameter ${reg_l1Wav} + 
		TV regularizations along the spatial, cardiac and respiration 
		dimensions jointly with a joint thresholding using the parameter 
		${reg_tv_cardiac}"
	;;
7) 	
	opts+="-rT:$(bart bitmask 0 1 10 11):0:${reg_tv_cardiac}
		-rW:$(bart bitmask 0 1):$(bart bitmask 6):${reg_l1Wav} --other tvscale=0.4:0.4:1.0:0.2"

	echo -e "l1-Wavelet spatial regularization with joint thresholding 
		using the parameter ${reg_l1Wav} + 
		TV regularizations along the spatial, cardiac and respiration 
		dimensions jointly
		${reg_tv_cardiac}"
	;;
8) 	
	opts+="-rT:$(bart bitmask 10):0:${reg_tv_cardiac}
		-rW:$(bart bitmask 0 1):$(bart bitmask 6):${reg_l1Wav}"

	echo -e "l1-Wavelet spatial regularization with joint thresholding 
		using the parameter ${reg_l1Wav} + 
		TV regularizations along the cardiac dimension only ${reg_tv_cardiac}"
	;;
9) 
	opts+="-rT:$(bart bitmask 10):0:${reg_tv_cardiac}
		-rT:$(bart bitmask 11):0:${reg_tv_resp}"

	echo -e "TV regularizations along the cardiac and respiration dimensions 
		separately using parameters ${reg_tv_cardiac} and ${reg_tv_resp}"
	;;
esac


if [ $k_filter -eq 1 ] ; then
	opts+=" -k --kfilter-2 -e1e-2"
fi

if [ $use_gpu -eq 1 ] ; then
	opts+=" -g --multi-gpu 1"
fi


readout=$(bart show -d1 $traj)
img_size=`calc $readout/2*$overgrid`
opts+=" --img_dims $img_size:$img_size:1 --normalize_scaling --scale_data 500 --scale_psf 250"
opts+=" --other pinit=1:1:1.5:1" 

echo $opts

bart scale 0.5 $traj traj

OMP_NUM_THREADS=40 nice -n15 bart moba $opts -t traj $ksp $TI $reco $sens

END=$(date +%s)
DIFF=$(($END - $START))
echo "It took $DIFF seconds"
