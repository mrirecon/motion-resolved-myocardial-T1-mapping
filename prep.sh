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


helpstr=$(cat <<- EOF
Preparation of sorted traj, data and inversion times for motion-resolved IR Radial FLASH.

-R repetition time
-G nth tiny golden angle
-f number of spokes per frame (k-space)
-C number of spokes in the steady-state used for gradient delay correction
-r number of respiration motion states
-c number of cardiac motion states
-h help

EOF
)

usage="Usage: $0 [-h] [-R TR] [-G GA] [-f nspokes_per_frame] [-C nstate] [-r nresp] [-c ncardiac] [-A] [-E] [-I] [-O] <input_ksp> <input_pmu> <coil_index> <eof> <out_traj> <out_data> <out_TI>"

# amplitude binning option
amp_bin=0

# eof option (0 -- eof not given; 1 -- eof given)
input_EOF=0

# coil index (0 -- coil index not given; 1 -- coil index given)
input_coil_index=0

# output the output the oscillation removal figure (0 -- no; 1 -- yes)
out_oscillation=0

while getopts "hR:G:f:C:r:c:AEIO" opt; do
	case $opt in
	h) 
		echo "$usage"
		echo "$helpstr"
		exit 0 
		;;		
	R) 
		TR=${OPTARG}
		;;
	G) 
		GA=${OPTARG}
		;;
	f) 	
		NSPF=${OPTARG}
		;;
	C) 	
		nstate=${OPTARG}
		;;
        r) 	
		nresp=${OPTARG}
		;;
        c) 	
		ncardiac=${OPTARG}
		;;
	A)
		amp_bin=1
		;;
	E)
		input_EOF=1
		;;
	I)
		input_coil_index=1
		;;
	O)
		out_oscillation=1
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

echo $input_EOF


if (($input_coil_index == 1));
then
	coil_index=$(readlink -f "$3")
	eof=$(readlink -f "$4")
	traj=$(readlink -f "$5")
	data=$(readlink -f "$6")
	TI=$(readlink -f "$7")
else
	eof=$(readlink -f "$3")
	traj=$(readlink -f "$4")
	data=$(readlink -f "$5")
	TI=$(readlink -f "$6")
fi


echo $input_coil_index

if [ ! -e ${ksp}.cfl ] && [ ! -e ${ksp} ] ; then
        echo "Input ksp file does not exist." >&2
        echo "$usage" >&2
        exit 1
fi


#--- Config ---
RO=$(bart show -d0 $ksp)
SP=$(bart show -d1 $ksp)
FR=$(bart show -d10 $ksp)
REP=$(bart show -d12 $ksp)
echo $REP
nspokes_per_IR=$(($SP * $FR))

# Traj
topts="-x$RO -y1 -t$(($FR * $SP * $REP)) -G -s$GA -c"
bart traj $topts traj_bu
nf=$((nspokes_per_IR/NSPF))
nspokes_per_IR_new=$((nf * NSPF))

echo $nspokes_per_IR_new

OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 9 10 11) $nspokes_per_IR $REP 1 traj_bu t1
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 9 0 $nspokes_per_IR_new t1 t2

OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 1 10) 1 $((SP*FR)) $ksp ksp1
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 10 0 $nspokes_per_IR_new ksp1 ksp2

RO=$(bart show -d0 ksp2)
SP=$(bart show -d1 ksp2)
FR=$(bart show -d10 ksp2)
REP=$(bart show -d12 ksp2)


#--- k-space ---
# extract data from the second inversion on
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 12 1 $REP ksp2 ksp3

OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 0 1 2 10 12) 1 $RO 1 $(($SP * $FR * $((REP-1)))) 1 ksp3 k

NC=$(bart show -d3 k)

#--- Traj ---
#--- RING ---
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 9 $((nspokes_per_IR_new-nstate)) $nspokes_per_IR_new 10 1 2 t2 _tGD
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart transpose 9 2 _tGD _tGD1
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart flip $(bart bitmask 2) _tGD1 _tGD2 

OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 10 $((nspokes_per_IR_new-nstate)) $nspokes_per_IR_new 12 1 2 ksp2 _kGD
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart transpose 0 1 _kGD _kGD1
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart transpose 10 2 _kGD1 _kGD2
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart flip $(bart bitmask 2) _kGD2 _kGD3 
GD=$(bart estdelay -R _tGD2 _kGD3); echo $GD

bart traj $topts -O -q$GD tGD
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 9 10 11) $nspokes_per_IR $REP 1 tGD tGD1
bart extract 9 0 $nspokes_per_IR_new tGD1 tGD2
bart extract 10 1 $REP tGD2 tGD3
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 9 10) 1 $((nspokes_per_IR_new*((REP-1)))) tGD3 tGD1

REP=$((REP-1))

echo $REP


# ECG signal extraction
bart reshape $(bart bitmask 1 10) 1 $nspokes_per_IR $pmu _pmu1
bart extract 10 0 $nspokes_per_IR_new _pmu1 _pmu0

bart extract 12 1 $((REP+1)) _pmu0 _pmu1

head -n2 _pmu1.hdr

bart reshape $(bart bitmask 1 10 12) 1 $(($SP * $FR * $REP)) 1 _pmu1 _pmu2
bart reshape $(bart bitmask 9 10) $NSPF $(($SP * $FR * $REP / $NSPF)) _pmu2 _pmu3
bart extract 9 $((NSPF/2-1)) $((NSPF/2)) _pmu3 _pmu4

python3 ../utils/EOF_ECG.py _pmu4 200 _eof_c0 _eof_c1

# Adapted SSA-FARY for respiratory signal extraction
if (($input_EOF == 0));
then
	#--- Remove traj-dependent oscillation ---
	bart resize -c 1 1 k k_DC

	echo -e "perform EOF analysis"

        len=$(bart show -d10 k_DC)

	L=7
        bart resize -c 10 $((len + 2*L)) k_DC _dcpad

	echo -e "Padding is done."

	bart filter -a10 -l$((($L*2) + 1)) _dcpad _dcfilt

	echo -e "Filtering is done."


	bart rmfreq -M _dcfilt tGD1 k_DC kc_new

	# Compare
	if (($out_oscillation == 1));
	then
		OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 10 $((nspokes_per_IR_new*2)) $((nspokes_per_IR_new*3)) k_DC k_DC_1
		OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 10 $((nspokes_per_IR_new*2)) $((nspokes_per_IR_new*3)) kc_new kc_new1

		cfl2png -CC -l1e-4 -u5e-4 k_DC_1 k_DC_1.png
		cfl2png -CC -l1e-4 -u5e-4 kc_new1 kc_new1.png
	fi

	# stack IRs
	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart transpose 10 0 kc_new kc1
	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 0 1 10) $nspokes_per_IR_new $REP 1 kc1 _ac_1
	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 1 3) $(($REP*$NC)) 1 _ac_1 AC

	# remove IR contrast:
	for w_rm in 11; do 
		bart ssa -z -m0 -w $w_rm -g -$(bart bitmask 0 1) AC _eof_rm_$w_rm _s_rm_$w_rm AC_contrast_rm_$w_rm
	done

	echo -e "SSA is done."

	bart reshape $(bart bitmask 0 1 2) $nspokes_per_IR_new $REP $NC AC_contrast_rm_$w_rm AC_contrast_rm_${w_rm}_1

	for ((i=0;i<$NC;i++))
	do
        	bart extract 2 $i $((i+1)) AC_contrast_rm_${w_rm}_1 tmp
        	bart svd tmp U S V
        	bart extract 1 0 1 U tmp_U_${i}
	done

	bart join 3 `seq -f "tmp_U_%g" 0 $((NC-1))` U_svd

	rm tmp*


	python3 ../utils/phase_divide_svd.py AC AC_contrast_rm_$w_rm $REP AC_contrast_rm_phase_correct U_svd

	head -n2 AC_contrast_rm_phase_correct.hdr

	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 0 1 2) $nspokes_per_IR_new $REP $NC AC_contrast_rm_phase_correct _ac_contrast_rm_phase_correct_1


	# zero-pad ac-region to account for gap
	nspokes_with_gap=$((nspokes_per_IR_new + 915)) # 3 s:  920, 5 s: 1530
	bart resize 0 $nspokes_with_gap _ac_contrast_rm_phase_correct_1 _ac_gap 
	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 0 1 10) 1 1 $(($nspokes_with_gap * $REP)) _ac_gap _ac_gap1

	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 9 10) $NSPF $((nspokes_with_gap*REP/NSPF)) _ac_gap1 _ac2
	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart avg $(bart bitmask 9) _ac2 _ac-rs2

	#--- SSA-FARY ---
	# Prepare auto-calibration region
	bart transpose 0 10 _ac-rs2 _ac0
	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart squeeze _ac0 _ac1
	bart creal _ac1 _acreal
	bart scale -- -1i _ac1 _ac2_1
	bart creal _ac2_1 _acimag
	bart join 1 _acreal _acimag AC

	w=21 
	bart ssa -w$w AC EOF_${w}_${w_rm} S_$w
	# bart transpose 0 1 EOF_${w}_${w_rm} EOF_${w}_${w_rm}_tr
	# bart fmac EOF_${w}_${w_rm}_tr S_$w EOF_${w}_${w_rm}_tr_eig
	# bart transpose 0 1 EOF_${w}_${w_rm}_tr_eig EOF_${w}_${w_rm}_tr_eig_1
	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 0 1 2) $((nspokes_with_gap/NSPF)) $REP $(bart show -d1 EOF_${w}_${w_rm}) EOF_${w}_${w_rm} _eof

	# remove zero-padding
	bart resize 0 $((nspokes_per_IR_new/NSPF)) _eof _eof1 

	OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 0 1 2) $((nspokes_per_IR_new*REP/NSPF)) $(bart show -d1 EOF_${w}_${w_rm}) 1 _eof1 Eof_resp_${REP}

	r0=0
	r1=1

	if (($amp_bin == 1)); 
	then 
		r1=$r0; 
	fi

	echo $r0
	echo $r1
	bart slice 1 $r0 Eof_resp_${REP} _eof_r0
	bart slice 1 $r1 Eof_resp_${REP} _eof_r1
else	
	bart slice 1 0 $eof _eof_r0
	bart slice 1 0 $eof _eof_r1
fi
	
bart scale 20 _eof_r0 _eof_r01
bart scale 20 _eof_r1 _eof_r11



bart join 1 _eof_r{01,11} _eof_c{0,1} _tmp
bart transpose 1 11 _tmp _tmp1
bart transpose 0 10 _tmp1 $eof

# coil selection
if (($input_coil_index == 1));
then
	# get the coil index
	n=0
	while read line; do
		bart slice 3 $line k tmpd-${n}.coo
		n=$(($n+1))
	done < $coil_index

	bart join 3 $(seq -f "tmpd-%g.coo" 0 $(($n-1))) k
fi

NC=$(bart show -d3 k)

echo $NC

OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 9 10) $NSPF $((nspokes_per_IR_new*REP/NSPF)) k K_reshape
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 9 10) $NSPF $((nspokes_per_IR_new*REP/NSPF)) tGD1 TGD_reshape

ncoils=8

bart cc -p$ncoils -A K_reshape K_cc_reshape

rm K_reshape.*

#------------- Sort the data into $nresp respiration and $ncardiac cardiac states --------------#
R=$nresp
C=$ncardiac

echo -e "Sorting the data into $R respiration and $C cardiac bins..."

# Quadrature or Amplitude Binning
bin_opts="-r0:1 -R$R -c2:3 -C$C $eof"

if (($amp_bin == 1)); 
then 
	bin_opts="-M ${bin_opts}"; 
fi

bart bin $bin_opts K_cc_reshape ksg
bart bin $bin_opts TGD_reshape tsg

#--- Prepration for MOBA ---
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart transpose 2 5 ksg _ksg
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart transpose 2 5 tsg _tsg

OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart transpose 9 2 _tsg tsg1
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart transpose 9 2 _ksg ksg1

#--- TI ---
nframes=$(($SP * $FR / $NSPF))
bart index 5 $nframes tmp1
bart scale $(($NSPF * $TR)) tmp1 tmp2
bart ones 6 1 1 1 1 1 $nframes tmp1
bart saxpy $((($NSPF / 2) * $TR)) tmp1 tmp2 tmp3
bart scale 0.000001 tmp3 TI
bart transpose 5 10 TI TI1

bart repmat 11 $REP TI1 TI2
bart reshape $(bart bitmask 10 11) $(($SP * $FR * $REP / $NSPF)) 1 TI2 TI1

bart bin $bin_opts TI1 TIsg

bart transpose 2 5 TIsg TIsg1

#--- sort the data ---
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 10 11) $((R * C)) 1 TIsg1 TIsg1_1
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 10 11) $((R * C)) 1 ksg1 _ksg
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 10 11) $((R * C)) 1 tsg1 _tsg

python3 ../utils/sort_input_moba.py _tsg _ksg TIsg1_1 tsg1_1 ksg1_1 TIsg1

echo $data

#--- reshape the sorted data ---
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 0 1 2 3 4 5 10 11) 1 $RO $NSPF $ncoils 1 $(bart show -d3 tsg1_1) $C $R  ksg1_1 $data
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 0 1 2 3 4 5 10 11) 3 $RO $NSPF 1 1 $(bart show -d3 tsg1_1) $C $R  tsg1_1 $traj
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 0 1 2 3 4 5 10 11) 1 1 1 1 1 $(bart show -d0 TIsg1) $C $R  TIsg1 $TI

rm _*.cfl _*.hdr k*.cfl k*.hdr t*.cfl t*.hdr TI*.cfl TI*.hdr K_cc_reshape* TGD_reshape* AC* U* V* S* || true

echo -e "Done."
