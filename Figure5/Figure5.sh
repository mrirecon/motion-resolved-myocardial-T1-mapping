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

dir=../invivo

cd $dir

rtnlinv_and_eof () {

    ksp=$1
    rtnlinv=$2
    eof=$3

    #--- Config ---
    RO=$(bart show -d0 $ksp)
    SP=$(bart show -d1 $ksp)
    FR=$(bart show -d10 $ksp)
    REP=$(bart show -d12 $ksp)
    echo $REP
    nspokes_per_IR=$(($SP * $FR))

    # Traj
    NSPF=15
    GA=7
    topts="-x$RO -y1 -t$(($FR * $SP * $REP)) -G -s$GA -c"
    bart traj $topts traj_bu
    nf=$((nspokes_per_IR/NSPF))
    nspokes_per_IR_new=$((nf * NSPF))

    echo $nspokes_per_IR_new

    bart reshape $(bart bitmask 9 10 11) $nspokes_per_IR $REP 1 traj_bu t1
    bart extract 9 0 $nspokes_per_IR_new t1 t2

    bart reshape $(bart bitmask 1 10) 1 $((SP*FR)) $ksp ksp1
    bart extract 10 0 $nspokes_per_IR_new ksp1 ksp2

    RO=$(bart show -d0 ksp2)
    SP=$(bart show -d1 ksp2)
    FR=$(bart show -d10 ksp2)
    REP=$(bart show -d12 ksp2)


    #--- k-space ---
    # extract data from the second inversion on
    bart extract 12 1 $REP ksp2 ksp3

    bart reshape $(bart bitmask 0 1 2 10 12) 1 $RO 1 $(($SP * $FR * $((REP-1)))) 1 ksp3 k

    NC=$(bart show -d3 k)

    #--- Traj ---
    #--- RING ---
    nstate=180
    bart extract 9 $((nspokes_per_IR_new-nstate)) $nspokes_per_IR_new 10 1 2 t2 _tGD
    bart transpose 9 2 _tGD _tGD1
    bart flip $(bart bitmask 2) _tGD1 _tGD2 

    bart extract 10 $((nspokes_per_IR_new-nstate)) $nspokes_per_IR_new 12 1 2 ksp2 _kGD
    bart transpose 0 1 _kGD _kGD1
    bart transpose 10 2 _kGD1 _kGD2
    bart flip $(bart bitmask 2) _kGD2 _kGD3 
    GD=$(bart estdelay -R _tGD2 _kGD3); echo $GD

    bart traj $topts -O -q$GD tGD
    bart reshape $(bart bitmask 9 10 11) $nspokes_per_IR $REP 1 tGD tGD1
    bart extract 9 0 $nspokes_per_IR_new tGD1 tGD2
    bart extract 10 1 $REP tGD2 tGD3
    bart reshape $(bart bitmask 9 10) 1 $((nspokes_per_IR_new*((REP-1)))) tGD3 tGD1

    REP=$((REP-1))

    bart reshape $(bart bitmask 9 10) $NSPF $((nspokes_per_IR_new*REP/NSPF)) k K_reshape
    bart reshape $(bart bitmask 9 10) $NSPF $((nspokes_per_IR_new*REP/NSPF)) tGD1 TGD_reshape

    # rtnlinv
    ncoils=8
    bart cc -p$ncoils -A K_reshape K_cc_reshape

    bart resize -c 1 256 K_cc_reshape K_cc_reshape-256
    bart resize -c 1 256 TGD_reshape TGD_reshape-256
    bart transpose 9 2 TGD_reshape-256 TGD_reshape-256-1
    bart transpose 9 2 K_cc_reshape-256 K_cc_reshape-256-1

    bart rtnlinv -i6 -d4 -g -t TGD_reshape-256-1 K_cc_reshape-256-1 rtnlinv-256

    bart resize -c 0 128 1 128 rtnlinv-256 $rtnlinv


    # self-gating via adapted SSA-FARY
    bart resize -c 1 1 k k_DC

	echo -e "perform EOF analysis"

    len=$(bart show -d10 k_DC)

	L=7
    bart resize -c 10 $((len + 2*L)) k_DC _dcpad

	echo -e "Padding is done."

	bart filter -a10 -l$((($L*2) + 1)) _dcpad _dcfilt

	echo -e "Filtering is done."


	bart rmfreq -M _dcfilt tGD1 k_DC kc_new

	# stack IRs
	bart transpose 10 0 kc_new kc1
	bart reshape $(bart bitmask 0 1 10) $nspokes_per_IR_new $REP 1 kc1 _ac_1
	bart reshape $(bart bitmask 1 3) $(($REP*$NC)) 1 _ac_1 AC

	# remove IR contrast:
	for w_rm in 11; do
        bart ssa -z -m0 -w $w_rm -g -$(bart bitmask 0 1) AC _eof_rm_$w_rm _s_rm_$w_rm AC_contrast_rm_$w_rm
	done

	echo -e "SSA is done."

    bart reshape $(bart bitmask 0 1 2) $nspokes_per_IR_new $REP $NC AC_contrast_rm_$w_rm AC_contrast_rm_${w_rm}_1

    # perform svd coil-by-coil
    for ((i=0;i<$NC;i++))
    do
        bart extract 2 $i $((i+1)) AC_contrast_rm_${w_rm}_1 tmp
        bart svd tmp U S V
        bart extract 1 0 1 U tmp_U_${i}
    done

    bart join 3 `seq -f "tmp_U_%g" 0 $((NC-1))` U_svd

    rm tmp*


    python3 ../utils/phase_divide_svd.py AC AC_contrast_rm_$w_rm $REP AC_contrast_rm_phase_correct U_svd

    bart reshape $(bart bitmask 0 1 2) $nspokes_per_IR_new $REP $NC AC_contrast_rm_phase_correct _ac_contrast_rm_phase_correct_1


	# zero-pad ac-region to account for gap
    nspokes_with_gap=$((nspokes_per_IR_new + 915)) # 3 s
    bart resize 0 $nspokes_with_gap _ac_contrast_rm_phase_correct_1 _ac_gap 
    bart reshape $(bart bitmask 0 1 10) 1 1 $(($nspokes_with_gap * $REP)) _ac_gap _ac_gap1
    bart reshape $(bart bitmask 9 10) $NSPF $((nspokes_with_gap*REP/NSPF)) _ac_gap1 _ac2
    bart avg $(bart bitmask 9) _ac2 _ac-rs2

	#--- SSA-FARY ---
	# Prepare auto-calibration region
    bart transpose 0 10 _ac-rs2 _ac0
    bart squeeze _ac0 _ac1
    bart creal _ac1 _acreal
    bart scale -- -1i _ac1 _ac2_1
    bart creal _ac2_1 _acimag
    bart join 1 _acreal _acimag AC

    # Perform SSA-FARY
    w=21 
    bart ssa -w$w AC $eof S_$w
    
    rm _* k* AC* U* t* S* T* K* V*
}


#------------------------------------#
# Volunteer 
#------------------------------------#

# Figure 5 (A)

rtnlinv_and_eof ../data/volunteer/vol-2/scan-2/ksp rtnlinv eof

belt=../data/volunteer/volunteer/self-gating/belt.txt

python3 ../utils/self_gating.py eof $belt rtnlinv ../Figure5/Figure5A.png

# Figure 5 (B)

thresh=1.6 # extract data after zero-crossing
ID=vol-2-scan-2
bart threshold -B $thresh $ID-A-TI_S15_21IRs_6resp_20cardiac TI_ss_binary

bart fmac $ID-A-traj_S15_21IRs_6resp_20cardiac TI_ss_binary traj_ss
bart fmac $ID-A-data_S15_21IRs_6resp_20cardiac TI_ss_binary data_ss


NSPK=$(bart show -d2 traj_ss)
NCOL=$(bart show -d3 data_ss)
NTI=$(bart show -d5 traj_ss)
NCAR=$(bart show -d10 traj_ss)
NRSP=$(bart show -d11 traj_ss)

bart reshape $(bart bitmask 2 5 10) $((NSPK*NTI*NCAR)) 1 1 traj_ss traj_ss-1

bart transpose 2 4 data_ss data_ss-1
bart reshape $(bart bitmask 4 5 10) $((NSPK*NTI*NCAR)) 1 1 data_ss-1 data_ss-2
bart transpose 4 2 data_ss-2 data_ss-3


bart resize -c 1 256 traj_ss-1 traj_ss-2
bart resize -c 1 256 data_ss-3 data_ss-3-1

bart nufft -i -g traj_ss-2 data_ss-3-1 reco_nufft

bart rss $(bart bitmask 3) reco_nufft reco_nufft-rss

bart resize -c 0 128 1 128 reco_nufft-rss reco_nufft-rss-128

nframes=$(bart show -d10 reco_nufft-rss-128)

for (( k=0; k<$nframes; k++ )); do
    bart extract 10 $k $((k+1)) reco_nufft-rss-128 tmp
    cfl2png -A -l 6e-6 -u 1.3e-4 tmp ../Figure5/Figure5B-${k}.png
done

#------------------------------------#
# pig 
#------------------------------------#

cd ../

dir=pig

[ -d $dir ] || mkdir $dir

cd $dir

rtnlinv_and_eof ../data/pig/raw_data/ksp rtnlinv eof

python3 ../utils/self_gating_pig.py $eof $rtnlinv ../Figure5/Figure5C.png


# Figure 5 (D)

thresh=0.7 # extract data after zero-crossing
ID=pig-raw_data
bart threshold -B $thresh $ID-A-TI_S15_21IRs_6resp_20cardiac TI_ss_binary

bart fmac $ID-A-traj_S15_21IRs_6resp_20cardiac TI_ss_binary traj_ss
bart fmac $ID-A-data_S15_21IRs_6resp_20cardiac TI_ss_binary data_ss

NSPK=$(bart show -d2 traj_ss)
NCOL=$(bart show -d3 data_ss)
NTI=$(bart show -d5 traj_ss)
NCAR=$(bart show -d10 traj_ss)
NRSP=$(bart show -d11 traj_ss)

bart reshape $(bart bitmask 2 5 10) $((NSPK*NTI*NCAR)) 1 1 traj_ss traj_ss-1

bart transpose 2 4 data_ss data_ss-1
bart reshape $(bart bitmask 4 5 10) $((NSPK*NTI*NCAR)) 1 1 data_ss-1 data_ss-2
bart transpose 4 2 data_ss-2 data_ss-3


bart resize -c 1 256 traj_ss-1 traj_ss-2
bart resize -c 1 256 data_ss-3 data_ss-3-1

bart transpose 11 10 traj_ss-2 traj_ss-2-1
bart transpose 11 10 data_ss-3-1 data_ss-3-2

bart flip $(bart bitmask 10) traj_ss-2-1 traj_ss-2-2
bart flip $(bart bitmask 10) data_ss-3-2 data_ss-3-3

bart rtnlinv -i10 -g -t traj_ss-2-2 data_ss-3-3 rt-nlinv

bart resize -c 0 128 1 128 rt-nlinv rt-nlinv-128

nframes=$(bart show -d10 rt-nlinv-128)

for (( k=0; k<$nframes; k++ )); do
    bart extract 10 $k $((k+1)) rt-nlinv-128 tmp
    cfl2png -A -l 6e-6 -u 1e-2 tmp ../Figure5/Figure5D-${k}.png
done

rm data*
