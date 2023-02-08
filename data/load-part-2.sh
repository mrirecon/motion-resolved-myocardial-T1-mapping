#!/bin/bash

ZENODO_RECORD=7350323

# load volunteer 2 ROI
for i in vol-2-septal-ROI; do

	./load.sh ${ZENODO_RECORD} ${i} .
	tar -xzvf ${i}.tgz
done

# load remaining volunteer data
for i in vol-6 vol-7 vol-8 vol-9 vol-10 vol-11; do

	./load.sh ${ZENODO_RECORD} ${i} .
	tar -xzvf ${i}.tgz
done

