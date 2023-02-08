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

data_folder=../data/volunteer
ksp=$data_folder/vol-2/scan-2/ksp

#--- Config ---
RO=$(bart show -d0 $ksp)
SP=$(bart show -d1 $ksp)
FR=$(bart show -d10 $ksp)
REP=$(bart show -d12 $ksp)
echo $REP
nspokes_per_IR=$(($SP * $FR))

GA=7
NSPF=15

# Traj
topts="-x$RO -y1 -t$(($FR * $SP * $REP)) -G -s$GA -c"
bart traj $topts traj_bu
nf=$((nspokes_per_IR/NSPF))
nspokes_per_IR_new=$((nf * NSPF))

echo $nspokes_per_IR_new

OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 9 10 11) $nspokes_per_IR $REP 1 traj_bu t1
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 9 0 $nspokes_per_IR_new t1 t2
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart reshape $(bart bitmask 9 10) 1 $((nspokes_per_IR_new*REP)) t2 t1

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
nstate=180
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


# Adapted SSA-FARY for respiratory signal extraction

#--- Remove traj-dependent oscillation ---#
bart resize -c 1 1 k k_DC

echo -e "perform EOF analysis"

len=$(bart show -d10 k_DC)

L=7
bart resize -c 10 $((len + 2*L)) k_DC _dcpad

echo -e "Padding is done."

bart filter -a10 -l$((($L*2) + 1)) _dcpad _dcfilt

echo -e "Filtering is done."


bart rmfreq -M _dcfilt tGD1 k_DC kc_DC


OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 10 $((nspokes_per_IR_new*2)) $((nspokes_per_IR_new*3)) k_DC singleIR_k_DC
OMP_NUM_THREADS=5 nice -n10 ionice -c2 -n7 bart extract 10 $((nspokes_per_IR_new*2)) $((nspokes_per_IR_new*3)) kc_DC singleIR_kc_DC

cfl2png -CC -l1e-4 -u5e-4 singleIR_k_DC ../Figure4/Figure4A.png
cfl2png -CC -l1e-4 -u5e-4 singleIR_kc_DC ../Figure4/Figure4B.png

rm _* k* t*

echo -e "Done."
