#!/bin/bash
# Tests the pipeline on a toy example that runs quickly.

resultfile="../results/results.csv"
netnewick="((A:1.0,((B:1.0,C:1.0):1.0,(D:1.0)#H1:1.0::0.5):1.0):1.0,(#H1:1.0::0.5,E:1.0):1.0);"
nproc=4
ngt=5

echo ./run-one.sh "${netnewick}" ${resultfile} ${ngt} ${nproc}
./run-one.sh "${netnewick}" ${resultfile} ${ngt} ${nproc}