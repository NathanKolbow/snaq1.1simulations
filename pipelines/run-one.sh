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
#       2. add ILS, nhybrids, ntaxa to results.csv
#       3. pass a set seed for selecting same ngt gene trees for each SNaQ1 and SNaQ2 run
#       4. calculate mean_gtee for the actual selected gene trees, not just the whole file mean
#       5. use $ngt as the set seed
#       6. don't wait to the end to write results
#       7. add major tree RF distance to results (majorRF)
#       8. accuracy --> RF in results
#       9. 10,000 --> 4,430 gene trees, ngt=30 takes first 30, ngt=100 takes 31-130
#       10. reformat so that a replicate # is associated with each treefile, add replicate # to results csv
#
# TO TEST THIS SCRIPT: ./run-one.sh "simple-test" ../results/test.csv 30 16 "med"


net_abbr=$1
output_df=$2
ngt=$3
nprocs=$4
ils=$5
replicate=$6

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

echo "run-one.sh $1 $2 $3 $4 $5 $6"
echo "---------------------------------------------------------------------"
echo ""

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
netdir="/mnt/ws/home/nkolbow/repos/snaq2/data/input/${net_abbr}"
treefiledir="${netdir}/treefiles/${ils}ILS"

estgt_file="${treefiledir}/estgts_${replicate}.treefile"
truegt_file="${treefiledir}/truegts_${replicate}.treefile"
seqgen_sfile="${treefiledir}/seqgen-s_${replicate}"
gtee_file="${treefiledir}/gtee_${replicate}"

if [ ! -f "${estgt_file}" ]
then
    echo "julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils} ${replicate} > /dev/null" >> /mnt/ws/home/nkolbow/repos/snaq2/condor/condor_logs/_mylog.log


    echo "julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils} ${replicate} > /dev/null"
    julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils} ${replicate} > /dev/null
else
    # Make sure we have enough generated trees
    nlines=`wc -l < $estgt_file`
    if [ ! $nlines -eq 4430 ]
    then
        echo "Old treefile detected, redoing estimated tree generation." >> /mnt/ws/home/nkolbow/repos/snaq2/condor/condor_logs/_mylog.log
        echo "julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils} ${replicate} > /dev/null" >> /mnt/ws/home/nkolbow/repos/snaq2/condor/condor_logs/_mylog.log


        echo "Old treefile detected, redoing estimated tree generation."
        echo "julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils} ${replicate} > /dev/null"
        julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_abbr} ${ils} ${replicate} > /dev/null
    else
        echo "Treefiles already exist, skipping to estimation."
    fi
fi

# Estimate w/ SNaQ 1.0
mk_tempdata_tempfile
temp_snaq1_net_file=$tempfile

echo "julia -p${nprocs} -t${nprocs} ./snaq1.0-estimation.jl ${nhybrids} ${ngt} ${estgt_file} ${temp_snaq1_net_file} ${replicate} > /dev/null" >> /mnt/ws/home/nkolbow/repos/snaq2/condor/condor_logs/_mylog.log


echo "julia -p${nprocs} -t${nprocs} ./snaq1.0-estimation.jl ${nhybrids} ${ngt} ${estgt_file} ${temp_snaq1_net_file} ${replicate} > /dev/null"
julia -p${nprocs} -t${nprocs} ./snaq1.0-estimation.jl ${nhybrids} ${ngt} ${estgt_file} ${temp_snaq1_net_file} ${replicate} > /dev/null

# Write SNaQ 1.0 results
echo "julia ./write-results.jl 1 ${output_df} ${net_abbr} ${ngt} ${temp_snaq1_net_file} ${nprocs} ${ils} ${replicate} > /dev/null" >> /mnt/ws/home/nkolbow/repos/snaq2/condor/condor_logs/_mylog.log


echo "julia ./write-results.jl 1 ${output_df} ${net_abbr} ${ngt} ${temp_snaq1_net_file} ${nprocs} ${ils} ${replicate} > /dev/null"
julia ./write-results.jl 1 "${output_df}" ${net_abbr} ${ngt} ${temp_snaq1_net_file} ${nprocs} ${ils} ${replicate} > /dev/null

# Estimate w/ SNaQ 2.0
snaq2_netfiles=()
for probQR in 0 0.5 1
do
    for propQuartets in 1 0.9 0.7
    do
        mk_tempdata_tempfile
        currfile="${tempfile}_${probQR}_${propQuartets}"
        snaq2_netfiles+=(${currfile})
        mv ${tempfile} ${currfile}

        echo "julia -p${nprocs} -t${nprocs} ./snaq2.0-estimation.jl ${nhybrids} ${ngt} ${estgt_file} ${currfile} ${probQR} ${propQuartets} ${replicate} > /dev/null"
        julia -p${nprocs} -t${nprocs} ./snaq2.0-estimation.jl ${nhybrids} ${ngt} ${estgt_file} ${currfile} ${probQR} ${propQuartets} ${replicate} > /dev/null

        # Write SNaQ 2.0 results
        echo "julia ./write-results.jl 2 ${output_df} ${net_abbr} ${ngt} ${currfile} ${nprocs} ${ils} ${replicate} ${probQR} ${propQuartets} > /dev/null"
        julia ./write-results.jl 2 "${output_df}" ${net_abbr} ${ngt} ${currfile} ${nprocs} ${ils} ${replicate} ${probQR} ${propQuartets} > /dev/null
    done
done

# Clean up temp files
echo "Cleaning up temp files"
rm ${temp_snaq1_net_file}
for snaq2temp in ${snaq2_netfiles[@]}
do
    rm ${snaq2temp}
done