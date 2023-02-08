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


usage="Usage: $0 [-r reg_type] [-a alpha_min] [-o overgrid] [-I] [-E] [-N] [-O] [-P] [-R TR] <ksp> <pmu> <resp_index> <length> <coil_index> <EOF> <out_maps> <out_sens> <out_log>"

# default: spatial (l1-Wavelet) + spatial-temporal TV
reg_type=7 

# minimum regularization strength 
alpha_min=0.005

# coil index (0 -- coil index not given; 1 -- coil index given)
input_coil_index=0

# whether to input EOF or not
input_EOF=0 

# whether to perform nufft on the sorted data
nufft=0 

# overgridding factor
overgrid=1.25

# echo train length
ETL=20

# whether to output the oscillation removal figure
out_oscillation=0 

# whether to call prep.sh
prep=1

while getopts "r:a:o:IENOPR:" opt; do
	case $opt in
	r) 
		reg_type=${OPTARG}
		;;
	a) 
		alpha_min=${OPTARG}
		;;
	o) 
		overgrid=${OPTARG}
		;;
        I)
                input_coil_index=1
                ;;
        E)
                input_EOF=1
                ;;
        N)
                nufft=1
                ;;
        O)
                out_oscillation=1
                ;;
        P)
                prep=0
                ;;
        R)
                TR=${OPTARG}
                ;;

	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done

shift $(($OPTIND -1 ))

ksp=$(readlink -f "$1")
pmu=$(readlink -f "$2")
resp_index=$(readlink -f "$3")
length=$(readlink -f "$4")


if (($input_coil_index == 1));
then
        if (($input_EOF == 1));
        then
                coil_index=$(readlink -f "$5")
                EOF=$(readlink -f "$6")
                out_maps=$(readlink -f "$7")
                out_sens=$(readlink -f "$8")
                out_log=$(readlink -f "$9")
        else
                coil_index=$(readlink -f "$5")
                out_maps=$(readlink -f "$6")
                out_sens=$(readlink -f "$7")
                out_log=$(readlink -f "$8")
        fi
else
        if (($input_EOF == 1));
        then
                EOF=$(readlink -f "$5")
                out_maps=$(readlink -f "$6")
                out_sens=$(readlink -f "$7")
                out_log=$(readlink -f "$8")
        else
                out_maps=$(readlink -f "$5")
                out_sens=$(readlink -f "$6")
                out_log=$(readlink -f "$7")
        fi
fi                             


if [ ! -e ${ksp}.cfl ] ; then
	echo "Input file 'ksp' does not exist." >&2
	echo "$usage" >&2
	exit 1
fi

if [ ! -e ${pmu}.cfl ] ; then
	echo "Input file 'pmu' does not exist." >&2
	echo "$usage" >&2
	exit 1
fi

echo $ksp

prefix=$(basename $(dirname $(dirname $ksp)))-$(basename $(dirname $ksp))
READ=$(bart show -d0 $ksp)
SP=$(bart show -d1 $ksp)
FR=$(bart show -d10 $ksp)
nIRs=$(bart show -d12 $ksp)
NBR=$((READ / 2))
echo $TR
GA=7
nstate=180

# self-gating parameters
NSPF=15
nresp=6
ncardiac=20
amp_bin=1

# reco parameters
reg_l1Wav=0.2
reg_tv_resp=0.2
reg_tv_cardiac=1.0
u=0.01 # for ADMM


opts_prep="-R$TR -G$GA -f$NSPF -C$nstate -c$ncardiac -r$nresp"

if (($amp_bin == 1)); then 
        opts_prep+=" -A"; 
fi

if (($amp_bin == 1)); then 
        prefix+="-A"; 
fi

if (($input_EOF == 1)); then 
        opts_prep+=" -E";
        EOF=$EOF
else
        EOF=${prefix}-eof-gap3s_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac
fi

if (($out_oscillation == 1)); then 
        opts_prep+=" -O"; 
fi

echo $opts_prep

echo $prefix

if (($prep == 1));
then
if (($input_coil_index == 1));
then
        opts_prep+=" -I"
          ./../prep.sh $opts_prep $ksp $pmu $coil_index $EOF \
	           ${prefix}-traj_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac \
	           ${prefix}-data_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac \
	           ${prefix}-TI_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac
else
          ./../prep.sh $opts_prep $ksp $pmu $EOF \
                  ${prefix}-traj_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac \
                  ${prefix}-data_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac \
                  ${prefix}-TI_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac
        echo $nufft
fi
fi                         

# perform nufft on the binned data
if (($nufft == 1)); then
        NBINS=$(bart show -d5 ${prefix}-traj_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac) 
	
        bart reshape $(bart bitmask 2 5) $((NBINS*NSPF)) 1 ${prefix}-traj_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac tmp
        bart reshape $(bart bitmask 2 10) $((NBINS*NSPF*ncardiac)) 1 tmp tmp_traj

        bart reshape $(bart bitmask 2 5) $((NBINS*NSPF)) 1 ${prefix}-data_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac tmp
        bart reshape $(bart bitmask 2 10) $((NBINS*NSPF*ncardiac)) 1 tmp tmp_data

        res0=256
        NBR0=$((res0/2))

        bart resize -c 1 $res0 tmp_traj tmp_traj_1
        bart resize -c 1 $res0 tmp_data tmp_data_1

        for ((i=0;i<$nresp;i++))
        do	
	        start=$i
	        end=$((start+1))
	        bart extract 11 $start $end tmp_traj_1 tmp_tsg_rs_1
	        bart extract 11 $start $end tmp_data_1 tmp_ksg_rs_1
	        bart nufft -i -d $res0:$res0:1 -l1.0 tmp_tsg_rs_1 tmp_ksg_rs_1 tmp_nufft_reco_tsg_$i
        done

        bart join 10 $(seq -f "tmp_nufft_reco_tsg_%1g" 0 $((nresp-1))) nufft_reco_sg
        bart rss $(bart bitmask 3) nufft_reco_sg ${prefix}_nufft_reco_sg_amp_rss_${nresp}resp
        bart resize -c 0 $NBR0 1 $NBR0 ${prefix}_nufft_reco_sg_amp_rss_${nresp}resp ${prefix}_nufft_reco1_sg_amp_rss_${nresp}resp_$NBR0
        cfl2png -l1e-3 -u10e-2 ${prefix}_nufft_reco1_sg_amp_rss_${nresp}resp_$NBR0 ${prefix}_nufft_reco1_sg_amp_rss_${nresp}resp_images
fi

# respiration motion state extraction
# get desired the motion state index for reco
n=0
while read line; do
        bart slice 11 $line ${prefix}-traj_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac tmp_traj-${n}.coo
        bart slice 11 $line ${prefix}-data_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac tmp_data-${n}.coo
        bart slice 11 $line ${prefix}-TI_S${NSPF}_${nIRs}IRs_${nresp}resp_${ncardiac}cardiac tmp_TI-${n}.coo
        n=$(($n+1))
done < $resp_index

bart join 11 $(seq -f "tmp_traj-%g.coo" 0 $(($n-1))) ${prefix}-traj
bart join 11 $(seq -f "tmp_data-%g.coo" 0 $(($n-1))) ${prefix}-data
bart join 11 $(seq -f "tmp_TI-%g.coo" 0 $(($n-1))) ${prefix}-TI
rm tmp*.coo

bart extract 3 0 6 ${prefix}-data ${prefix}-data1

while read line; do
        ETL=$line
done < $length

echo $ETL


bart extract 5 0 $ETL ${prefix}-traj ${prefix}-traj2
bart extract 5 0 $ETL ${prefix}-TI ${prefix}-TI2
bart extract 5 0 $ETL ${prefix}-data1 ${prefix}-data3


if (($reg_type == 7));
then
        ./../reco.sh -w$reg_l1Wav -t$reg_tv_resp -T$reg_tv_cardiac -a$alpha_min -u$u -k -g -o$overgrid -R$reg_type \
 	        ${prefix}-TI2 ${prefix}-traj2 ${prefix}-data3 $out_maps $out_sens > $out_log
fi


if (($reg_type == 9));
then
        ./../reco.sh -w$reg_l1Wav -t$reg_tv_resp -T$reg_tv_cardiac -a$alpha_min -u$u -k -o$overgrid -R$reg_type \
 	        ${prefix}-TI2 ${prefix}-traj2 ${prefix}-data3 $out_maps $out_sens > $out_log
fi
 
 
if (($reg_type == 1));
then
        ./../reco.sh -w$reg_l1Wav -t$reg_tv_resp -T$reg_tv_cardiac -a$alpha_min -u$u -k -o$overgrid -R$reg_type \
 	        ${prefix}-TI2 ${prefix}-traj2 ${prefix}-data3 $out_maps $out_sens > $out_log
fi

if (($reg_type == 0));
then
        ./../reco.sh -w$reg_l1Wav -t$reg_tv_resp -T$reg_tv_cardiac -a$alpha_min -u$u -k -g -o$overgrid -R$reg_type \
 	        ${prefix}-TI2 ${prefix}-traj2 ${prefix}-data3 $out_maps $out_sens > $out_log
fi


rm *data3.* *traj2.* *data1.* *data.* *traj.* *TI2.*
