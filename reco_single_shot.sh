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
#

set -e

usage="Usage: $0 [-a alpha_min] [-k] [-o overgrid] <TI> <traj> <ksp> <output> <output_sens>"

if [ $# -lt 4 ] ; then

        echo "$usage" >&2
        exit 1
fi

k_filter=0

while getopts "ha:ko:" opt; do
	case $opt in
	h) 
		echo "$usage"
		exit 0 
		;;		
        a) 
		alpha_min=${OPTARG}
		;;
	k)
		k_filter=1
		;;
	o)
		overgrid=${OPTARG}
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


# single-slice model-based T1 reconstruction:

START=$(date +%s)

which bart
bart version

if [ $k_filter -eq 1 ] ; then
	opts+=" -k"
fi


opts+=" -L -g -i10 -d4 -B0.0 -C250 -s0.95 -N -o$overgrid -j$alpha_min "


readout=$(bart show -d1 $traj)
img_size=`calc $readout/2*$overgrid`
opts+=" --img_dims $img_size:$img_size:1 --normalize_scaling --scale_data 5000 --scale_psf 1000"
opts+=" --other pinit=1:1:1.5:1" 

echo $opts

bart scale 0.5 $traj traj

OMP_NUM_THREADS=30 nice -n15 bart moba $opts -t traj $ksp $TI $reco $sens

END=$(date +%s)
DIFF=$(($END - $START))
echo "It took $DIFF seconds"
