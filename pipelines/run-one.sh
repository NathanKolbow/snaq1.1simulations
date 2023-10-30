#! /bin/bash
set -e  # forces quit on error

# Runs the full pipeline for one each of:
# - network
# - number of gene trees
# - number of processors
#
# `snaq1.0-estimation.jl` is run once, but
# `snaq2.0-estimation.jl` is run once for each probQR value
#
# Usage: ./run-one.sh "<network abbreviation>" <output csv> <N gene trees> <number of processors> <ILS level ("low"/"med"/"high")>
#   (output is appended to the data frame)
#
# USER MUST BE IN THE `pipelines` DIRECTORY WHEN RUNNING
#
# TODO: 1. make sure everything has a set seed
#
# Good test example: ./run-one.sh "simple-test" ../results/test.csv 5 4 "med"


net_abbr=$1
output_df=$2
ngt=$3
nprocs=$4
ils=$5

if [ "${net_abbr: -1}" == "1" ]
then
    nhybrids=1
elif [ "${net_abbr: -1}" == "2" ]
then
    nhybrids=2
elif [ "${net_abbr: -1}" == "3" ]
then
    nhybrids=3
elif [ "${net_abbr: -1}" == "4" ]
then
    nhybrids=4
elif [ "${net_abbr: -1}" == "5" ]
then
    nhybrids=5
else
    nhybrids=1
fi

# Make temp_data dir if it doesn't exist in this instance
if [ ! -d "temp_data" ]; then
    mkdir temp_data
fi

# Function to easily generate temp data files later
mk_tempdata_tempfile() {
    local mytempfile=`mktemp`
    tempfile="./temp_data/$(basename ${mytempfile})"
    mv ${mytempfile} ./temp_data/
}

# If treefiles don't already exist, generate them
netdir="../data/${net_abbr}/"
if [ ! -f "../data/${net_abbr}/treefiles-${ils}ILS/est-gts.treefile" ]
then
    echo "julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils}"
    julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils}
else
    # Make sure we have enough generated trees
    nlines=`wc -l < ../data/${net_abbr}/treefiles-${ils}ILS/est-gts.treefile`
    if [ ! $nlines -ge $ngt ]
    then
        echo "Old treefile detected, redoing estimated tree generation."
        echo "julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils}"
        julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils}
    else
        echo "Treefiles already exist, skipping to estimation."
    fi
fi

estgt_file="../data/${net_abbr}/treefiles-${ils}ILS/est-gts.treefile"
gtee_file="../data/${net_abbr}/treefiles-${ils}ILS/gtee"

# Estimate w/ SNaQ 1.0
mk_tempdata_tempfile
temp_snaq1_net_file=$tempfile

echo "julia -p${nprocs} -t${nprocs} ./snaq1.0-estimation.jl ${nhybrids} ${ngt} ${estgt_file} ${temp_snaq1_net_file}"
julia -p${nprocs} -t${nprocs} ./snaq1.0-estimation.jl ${nhybrids} ${ngt} ${estgt_file} ${temp_snaq1_net_file}

# Estimate w/ SNaQ 2.0
snaq2_netfiles=()
for probQR in 0 0.25 0.5 0.75 1
do
    mk_tempdata_tempfile
    currfile="${tempfile}_${probQR}"
    snaq2_netfiles+=(${currfile})
    mv ${tempfile} ${currfile}

    echo "julia -p${nprocs} -t${nprocs} ./snaq2.0-estimation.jl ${nhybrids} ${estgt_file} ${currfile} ${probQR}"
    julia -p${nprocs} -t${nprocs} ./snaq2.0-estimation.jl ${nhybrids} ${estgt_file} ${currfile} ${probQR}
done

# Write to DF
echo "julia ./compile-run.jl ${output_df} ${net_abbr} ${ngt} ${nprocs} ${gtee_file} ${temp_snaq1_net_file} ${snaq2_netfiles[@]}"
julia ./compile-run.jl ${output_df} "${net_abbr}" ${ngt} ${nprocs} ${gtee_file} ${temp_snaq1_net_file} ${snaq2_netfiles[@]}

# Clean up temp files
echo "Cleaning up temp files"
rm ${temp_snaq1_net_file}
for snaq2temp in ${snaq2_netfiles[@]}
do
    rm ${snaq2temp}
done