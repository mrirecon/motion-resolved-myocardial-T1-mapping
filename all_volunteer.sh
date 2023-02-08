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
# run motion-resolved model-based reconstruction for all in vivo volunteer data sets
#

set -eux

dir=invivo

[ -d $dir ] || mkdir $dir

cd $dir

# path for raw data
data_folder=../data/volunteer

# regularization comparison
TR=3.27e-3
RES=256

reg_type=(0 1 7 9)
reg_para=(0.02 0.006 0.005 0.02)

k=0

for i in ${reg_type[@]} ; do
        prefix=vol-2-scan-2-r$i-${reg_para[$k]}
        folder=$data_folder/vol-2/scan-2

        echo $prefix

        ./../run.sh -r$i -a${reg_para[$k]} -o1.25 -R3270 $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt $prefix-para-maps $prefix-sens $prefix-reco-log
        ./../post.sh -R$TR -r$RES $prefix-para-maps $prefix-para-maps-$RES $prefix-t1map $prefix-t1map_corrected

        k=$((k+1))
done

reg_type=7 # L1-Wav + Spatiotemporal TV
reg_para=(0.004 0.005 0.006 0.007)

for i in ${reg_para[@]} ; do
        prefix=vol-2-scan-2-r${reg_type}-${i}
        folder=$data_folder/vol-2/scan-2

        echo $prefix

        ./../run.sh -r7 -a$i -o1.25 -R3270 $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt $prefix-para-maps $prefix-sens $prefix-reco-log
        ./../post.sh -R$TR -r$RES $prefix-para-maps $prefix-para-maps-$RES $prefix-t1map $prefix-t1map_corrected
done


# mid-ventricular slices, two repetitions (TR = 3.27e-3)

TR=3.27e-3
RES=256

vols=(2 3 5)
scans=(1 2)

for i in ${vols[@]} ; do
        for j in ${scans[@]} ; do
                prefix=vol-${i}-scan-${j}
                folder=$data_folder/vol-${i}/scan-${j}

                echo $prefix

                ./../run.sh -r7 -a0.005 -o1.25 -R3270 $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt $prefix-para-maps $prefix-sens $prefix-reco-log
                ./../post.sh -R$TR -r$RES $prefix-para-maps $prefix-para-maps-$RES $prefix-t1map $prefix-t1map_corrected
	done
done

# mid-ventricular slices, two repetitions (TR = 3.30e-3)

TR=3.30e-3

vols=(1 4 6 7 8 9 10 11)

for i in ${vols[@]} ; do
        for j in ${scans[@]} ; do
                prefix=vol-${i}-scan-${j}
                folder=$data_folder/vol-${i}/scan-${j}

                echo $prefix

                ./../run.sh -r7 -a0.005 -o1.25 -R3300 $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt $prefix-para-maps $prefix-sens $prefix-reco-log
                ./../post.sh -R$TR -r$RES $prefix-para-maps $prefix-para-maps-$RES $prefix-t1map $prefix-t1map_corrected
	done
done


# basal slice (TR = 3.30e-3)

vols=(1 4 8 9 10 11)

for i in ${vols[@]} ; do
        prefix=vol-${i}-basal
        folder=$data_folder/vol-${i}/basal

        echo $prefix

        ./../run.sh -r7 -a0.005 -o1.25 -R3300 $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt $prefix-para-maps $prefix-sens $prefix-reco-log
        ./../post.sh -R$TR -r$RES $prefix-para-maps $prefix-para-maps-$RES $prefix-t1map $prefix-t1map_corrected
done

# apical slice (TR = 3.30e-3)

for i in ${vols[@]} ; do
        prefix=vol-${i}-apical
        folder=$data_folder/vol-${i}/apical

        echo $prefix

        ./../run.sh -r7 -a0.005 -o1.25 -R3300 $folder/ksp $folder/pmu $folder/resp_index.txt $folder/length.txt $prefix-para-maps $prefix-sens $prefix-reco-log
        ./../post.sh -R$TR -r$RES $prefix-para-maps $prefix-para-maps-$RES $prefix-t1map $prefix-t1map_corrected
done
