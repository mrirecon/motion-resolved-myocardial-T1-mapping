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

usage="Usage: $0 [-R TR] [-r res] <reco> <reco_maps> <t1map> <t1map_corrected>"

if [ $# -lt 3 ] ; then

        echo "$usage" >&2
        exit 1
fi
while getopts "hR:r:" opt; do
	case $opt in
	h) 
		echo "$usage"
		exit 0 
		;;		
	R) 
		TR=${OPTARG}
		;;
	r) 
		res=${OPTARG}
		;;
	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done
shift $(($OPTIND -1 ))


reco=$(readlink -f "$1")
reco_maps=$(readlink -f "$2")
t1map=$(readlink -f "$3")
t1map_corrected=$(readlink -f "$4")
TR=$TR
res=$res

if [ ! -e ${reco}.cfl ] ; then
        echo "Input file 'reco' does not exist." >&2
        echo "$usage" >&2
        exit 1
fi


bart resize -c 0 $res 1 $res $reco $reco_maps 
bart looklocker -t0.3 -D15.3e-3 $reco_maps $t1map 

ncardiac=$(bart show -d10 $reco_maps)
nresp=$(bart show -d11 $reco_maps)


for ((i=0;i<$nresp;i++))
do
     for ((j=0;j<$ncardiac;j++))
     do
          bart extract 10 ${j} $((j+1)) 11 ${i} $((i+1)) $reco_maps tmp
          python3 ../utils/partial_LL_correct.py tmp $TR 915 920 tmp_cardiac${j}
     done
     bart join 2 `seq -f "tmp_cardiac%g" 0 $((ncardiac-1))` tmp_cardiac_all_resp${i}
done
 
bart join 3 `seq -f "tmp_cardiac_all_resp%g" 0 $((nresp-1))` $t1map_corrected

rm tmp*
