#!/bin/bash

ZENODO_RECORD=5707688

# load phantom data
for i in phantom; do

	./load.sh ${ZENODO_RECORD} ${i} .
	tar -xzvf ${i}.tgz
done

# load volunteer data
for i in vol-1 vol-2 vol-3 vol-4 vol-5; do

	./load.sh ${ZENODO_RECORD} ${i} .
	tar -xzvf ${i}.tgz
done

# load additional volunteer data
for i in volunteer; do

	./load.sh ${ZENODO_RECORD} ${i} .
	tar -xzvf ${i}.tgz
done

# load pig data
for i in pig; do

	./load.sh ${ZENODO_RECORD} ${i} .
	tar -xzvf ${i}.tgz
done
