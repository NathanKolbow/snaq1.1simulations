#!/bin/bash

# Runs the full pipeline for one each of:
# - network
# - number of gene trees
# - number of threads
#
# `snaq1.0-estimation.jl` is run once, but
# `snaq2.0-estimation.jl` is run once for each probQR value
#
# Usage: ./run-one.sh "<network newick>" <output dataframe> <N gene trees> <number of threads>
#   (output is appended to the data frame)
#
# USER MUST BE IN THE `pipelines` DIRECTORY WHEN RUNNING

net_newick=$1
output_df=$2
ngt=$3
nthreads=$4

if [ "${net_newick}" == "(((A,B),#H1), (((C,(D,#H2)))#H1,((E)#H2,F)));" ]
then
    nhybrids=2
fi


# Generate estimated gene trees
temp_gt_file=`mktemp -p ./temp_data/`
julia -t${nthreads} ./network-to-est-gene-trees.jl ${net_newick} ${temp_gt_file} ${ngt}

# Estimate w/ SNaQ 1.0
temp_snaq1_net_file=`mktemp -p ./temp_data/`
julia ./snaq1.0-estimation.jl ${nhybrids} ${temp_gt_file} ${temp_snaq1_net_file}

# Estimate w/ SNaQ 2.0
snaq2_netfiles=()
for probQR in 0 0.25 0.5
do
    currfile=`mktemp -p ./temp_data/`
    snaq2_netfiles+=${currfile}
    mv ${temp_snaq2_net_file} ${probQR}_${temp_snaq2_net_file}
    julia -t${nthreads} ./snaq2.0-estimation.jl ${nhybrids} ${temp_gt_file} ${currfile} ${probQR}
done

# Write to DF
juila ./compile-run.jl ${output_df} ${temp_snaq1_netfile} ${snaq2_netfiles}