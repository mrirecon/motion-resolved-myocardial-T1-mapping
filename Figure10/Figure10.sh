#!/bin/bash
# 
# Copyright 2022. TU Graz. Institute of Biomedical Imaging.
# Copyright 2022. Uecker Lab. University Medical Center Göttingen

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

set -e

dir=invivo

cd ../$dir

# create synthesized T1-weighted images by moba
# generate a time vector
TR=3270
nspokes_per_frame=15
nf=$((3000 * 1000 / $((TR*nspokes_per_frame))))
bart index 5 $nf tmp1.coo
# use local index from newer bart with older bart
#./index 5 $num tmp1.coo
bart scale $(($nspokes_per_frame * $TR)) tmp1.coo tmp2.coo
bart ones 6 1 1 1 1 1 $nf tmp1.coo 
bart saxpy $((($nspokes_per_frame / 2) * $TR)) tmp1.coo tmp2.coo tmp3.coo
bart scale 0.000001 tmp3.coo TI

#------------------------------------#
# Volunteer #2
#------------------------------------#

maps=vol-2-scan-2-para-maps

bart resize -c 0 256 1 256 $dir/$maps maps_0

bart extract 11 1 2 maps_0 maps_1

bart extract 6 0 1 maps_1 Mss
bart extract 6 1 2 maps_1 M0
bart extract 6 2 3 maps_1 R1s


bart fmac TI R1s tmp_result
bart scale  -- -1.0 tmp_result tmp_result1
bart zexp tmp_result1 tmp_exp
bart saxpy 1. M0 Mss tmp_result2
bart fmac tmp_exp tmp_result2 tmp_result3
bart repmat 5 $nf Mss tmp_Mss
bart saxpy -- -1.0 tmp_result3 tmp_Mss synthesized_T1_images
rm tmp*

bart squeeze synthesized_T1_images synthesized_T1_images_1
startx=83
starty=73

# bright blood
bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 15 16 3 17 18 synthesized_T1_images_1 syn_bright_blood_diastolic
bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 15 16 3 5 6 synthesized_T1_images_1 syn_bright_blood_systolic

l=0.0
u=0.5

cfl2png -z1 -A -l$l -u$u syn_bright_blood_diastolic ../Figure10/syn_bright_blood_diastolic.png
cfl2png -z1 -A -l$l -u$u syn_bright_blood_systolic ../Figure10/syn_bright_blood_systolic.png

# dark blood
bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 23 24 3 17 18 synthesized_T1_images_1 syn_dark_blood_diastolic
bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 23 24 3 5 6 synthesized_T1_images_1 syn_dark_blood_systolic

l=0.0
u=0.55

cfl2png -z1 -A -l$l -u$u syn_dark_blood_diastolic ../Figure10/syn_dark_blood_diastolic.png
cfl2png -z1 -A -l$l -u$u syn_dark_blood_systolic ../Figure10/syn_dark_blood_systolic.png

# quantitative T1 maps
bart looklocker -t0.3 -D15.3e-3 maps_0 maps_0_T1
bart threshold -B 0.05 maps_0_T1 masks
T1map=vol-2-scan-2-t1map_corrected

bart squeeze masks masks1
bart fmac $dir/$T1map masks1 T1_corrected-masked

bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 5 6 3 1 2 T1_corrected-masked syn_T1map

python3 ../utils/save_maps.py syn_T1map viridis 0 1.7 ../Figure10/T1map-masked_systolic.png

bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 17 18 3 1 2 T1_corrected-masked dias_T1map

python3 ../utils/save_maps.py dias_T1map viridis 0 1.7 ../Figure10/T1map-masked_diastolic.png


# bright blood image series
l=0.0
u=0.5
TI=15
startx=83
starty=73
nCardiac=20
mkdir data_syn_cardiac_TI${TI}
cd data_syn_cardiac_TI${TI}
for ((j = 0; j < nCardiac; j++)); 
do
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 $TI $((TI+1)) 3 $j $((j+1)) ../synthesized_T1_images_1 tmp
        cfl2png -z1 -A -l$l -u$u tmp ../../Figure10/synthe_image_TI${j}_c${i}.png
        rm *.cfl *.hdr
done
cd ..

# dark blood image series
l=0.0
u=0.55
TI=23
startx=83
starty=73
mkdir data_syn_cardiac_TI${TI}
cd data_syn_cardiac_TI${TI}
for ((j = 0; j < nCardiac; j++)); 
do
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 $TI $((TI+1)) 3 $j $((j+1)) ../synthesized_T1_images_1 tmp
        cfl2png -z1 -A -l$l -u$u tmp ../../Figure10/synthe_image_TI${j}_c${i}.png
        rm *.cfl *.hdr
done
cd ..


# T1 map image series
resp=1
l=0.0
u=1.7
startx=83
starty=73
mkdir data_cardiac_T1map_resp${resp}
cd data_cardiac_T1map_resp${resp}
for ((j = 0; j < nCardiac; j++)); 
do
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 $j $((j+1)) 3 $resp $((resp+1)) ../T1_corrected-masked tmp
        cfl2png -z1 -A -l$l -u$u -CV tmp ../../Figure10/cardiac_T1map_c${j}.png
        rm *.cfl *.hdr
done
cd ..

#------------------------------------#
# Volunteer #3
#------------------------------------#

maps=vol-3-scan-1-para-maps

bart resize -c 0 256 1 256 $dir/$maps maps_0
bart extract 11 1 2 maps_0 maps_1

bart extract 6 0 1 maps_1 Mss
bart extract 6 1 2 maps_1 M0
bart extract 6 2 3 maps_1 R1s


bart fmac TI R1s tmp_result
bart scale  -- -1.0 tmp_result tmp_result1
bart zexp tmp_result1 tmp_exp
bart saxpy 1. M0 Mss tmp_result2
bart fmac tmp_exp tmp_result2 tmp_result3
bart repmat 5 $nf Mss tmp_Mss
bart saxpy -- -1.0 tmp_result3 tmp_Mss synthesized_T1_images
rm tmp*

bart squeeze synthesized_T1_images synthesized_T1_images_1
startx=78
starty=50

# bright blood
bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 15 16 3 18 19 synthesized_T1_images_1 syn_bright_blood_diastolic
bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 15 16 3 6 7 synthesized_T1_images_1 syn_bright_blood_systolic

l=0.0
u=0.5

cfl2png -z1 -A -l$l -u$u syn_bright_blood_diastolic ../Figure10/syn_bright_blood_diastolic.png
cfl2png -z1 -A -l$l -u$u syn_bright_blood_systolic ../Figure10/syn_bright_blood_systolic.png

# dark blood
bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 22 23 3 18 19 synthesized_T1_images_1 syn_dark_blood_diastolic
bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 22 23 3 6 7 synthesized_T1_images_1 syn_dark_blood_systolic

l=0.0
u=0.55

cfl2png -z1 -A -l$l -u$u syn_dark_blood_diastolic ../Figure10/syn_dark_blood_diastolic.png
cfl2png -z1 -A -l$l -u$u syn_dark_blood_systolic ../Figure10/syn_dark_blood_systolic.png

T1=vol-3-scan-1-t1map
bart threshold -B 0.05 $dir/$T1 masks
T1map=dvol-3-scan-1-t1map_corrected

bart squeeze masks masks1
bart fmac $dir/$T1map masks1 T1_corrected-masked

bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 6 7 3 1 2 T1_corrected-masked sys_T1map

python3 ../utils/save_maps.py sys_T1map viridis 0 1.7 ../Figure10/T1map-masked_systolic.png

bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 18 19 3 1 2 T1_corrected-masked dias_T1map

python3 ../utils/save_maps.py dias_T1map viridis 0 1.7 ../Figure10/T1map-masked_diastolic.png

nTI=$(bart show -d2 synthesized_T1_images_1)
nCardiac=$(bart show -d3 synthesized_T1_images_1)
# nCardiac=1
# export synthesized images

# bright blood
l=0.0
u=0.5
TI=15
startx=78
starty=50
mkdir data_syn_cardiac_TI${TI}
cd data_syn_cardiac_TI${TI}
for ((j = 0; j < nCardiac; j++)); 
do
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 $TI $((TI+1)) 3 $j $((j+1)) ../synthesized_T1_images_1 tmp
        cfl2png -z1 -A -l$l -u$u tmp ../Figure10/synthe_image_TI${j}_c${i}.png
        rm *.cfl *.hdr
done
cd ..

# dark blood
l=0.0
u=0.55
TI=23
startx=78
starty=50
mkdir data_syn_cardiac_TI${TI}
cd data_syn_cardiac_TI${TI}
for ((j = 0; j < nCardiac; j++)); 
do
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 $TI $((TI+1)) 3 $j $((j+1)) ../synthesized_T1_images_1 tmp
        cfl2png -z1 -A -l$l -u$u tmp ../../Figure10/synthe_image_TI${j}_c${i}.png
        rm *.cfl *.hdr
done
cd ..

# T1 maps
resp=1
l=0.0
u=1.7
startx=78
starty=50
mkdir data_cardiac_T1map_resp${resp}
cd data_cardiac_T1map_resp${resp}
for ((j = 0; j < nCardiac; j++)); 
do
        bart extract 0 $startx $((startx+128)) 1 $starty $((starty+128)) 2 $j $((j+1)) 3 $resp $((resp+1)) ../T1_corrected-masked tmp
        cfl2png -z1 -A -l$l -u$u -CV tmp ../../Figure10/cardiac_T1map_c${j}.png
        rm *.cfl *.hdr
done
cd ..
