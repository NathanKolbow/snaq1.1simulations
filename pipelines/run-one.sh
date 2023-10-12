#! /bin/bash

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
#
# Example: ./run-one.sh "(((A:1,B:1):1,#H1:1::0.7):1,(((C:1,(D:1,#H2:1::0.7):1):1)#H1:1::0.3,((E:1)#H2:1::0.3,F:1):1):1):1;" results/results.csv 5 4

net_newick=$1
output_df=$2
ngt=$3
nthreads=$4

if [ "${net_newick}" == "(((A:1,B:1):1,#H1:1::0.7):1,(((C:1,(D:1,#H2:1::0.7):1):1)#H1:1::0.3,((E:1)#H2:1::0.3,F:1):1):1):1;" ]
then
    nhybrids=2
fi


# Generate estimated gene trees
mytempfile=`mktemp`
temp_gt_file="./temp_data/$(basename ${mytempfile})"
mv ${mytempfile} ./temp_data/

echo "julia -t${nthreads} ./network-to-est-gts.jl \"${net_newick}\" ${temp_gt_file} ${ngt}"
julia -t${nthreads} ./network-to-est-gts.jl "${net_newick}" ${temp_gt_file} ${ngt}

# Estimate w/ SNaQ 1.0
mytempfile=`mktemp`
temp_snaq1_net_file="./temp_data/$(basename ${mytempfile})"
mv ${mytempfile} ./temp_data/

echo "julia ./snaq1.0-estimation.jl ${nhybrids} ${temp_gt_file} ${temp_snaq1_net_file}"
julia ./snaq1.0-estimation.jl ${nhybrids} ${temp_gt_file} ${temp_snaq1_net_file}

# Estimate w/ SNaQ 2.0
snaq2_netfiles=()
for probQR in 0 0.25 0.5
do
    mytempfile=`mktemp`
    currfile="./temp_data/${probQR}_$(basename ${mytempfile})"
    snaq2_netfiles+=(${currfile})
    mv ${mytempfile} ./${currfile}

    echo "julia -t${nthreads} ./snaq2.0-estimation.jl ${nhybrids} ${temp_gt_file} ${currfile} ${probQR}"
    julia -t${nthreads} ./snaq2.0-estimation.jl ${nhybrids} ${temp_gt_file} ${currfile} ${probQR}
done

# Write to DF
echo "juila ./compile-run.jl ${output_df} ${ngt} ${nthreads} ${temp_snaq1_netfile} ${snaq2_netfiles[@]}"
julia ./compile-run.jl ${output_df} ${ngt} ${nthreads} ${temp_snaq1_netfile} ${snaq2_netfiles[@]}

# Clean up temp files
echo "Cleaning up temp files"
rm ${temp_gt_file}
rm ${temp_snaq1_net_file}
for snaq2temp in ${snaq2_netfiles[@]}
do
    rm ${snaq2temp}
done