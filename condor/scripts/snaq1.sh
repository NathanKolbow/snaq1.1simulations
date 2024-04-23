#!/bin/bash
# $1: net_abbr
# $2: ils
# $3: nthreads
# $4: replicate
# $5: num gts
# $6: output df filepath

set -e

########################## BOILERPLATE ##########################
# Setup Julia
tar -xzf julia-1.9.3-linux-x86_64.tar.gz
tar -xzf snaq1-proj.tar.gz
export PATH=$PWD/julia-1.9.3/bin:$PATH      # these are exported in `snaq1-setup.sh` but those
export JULIA_DEPOT_PATH=$PWD/snaq1-proj     # exports don't seem to persist into this file
echo "JULIA_DEPOT_PATH: $JULIA_DEPOT_PATH"

# Arguments
net_abbr=$1
ils=$2
nthreads=$3
nprocs=$((nthreads - 1))    # we do this b/c -p2 gives 3 procs, not 2
replicate=$4
ngt=$5
output_df=$6

# Directories and filepaths
netdir="/mnt/ws/home/nkolbow/repos/snaq2/data/input/${net_abbr}"
treefiledir="${netdir}/treefiles/${ils}ILS"

estgt_file="${treefiledir}/estgts_${replicate}.treefile"
truegt_file="${treefiledir}/truegts_${replicate}.treefile"
seqgen_sfile="${treefiledir}/seqgen-s_${replicate}"
gtee_file="${treefiledir}/gtee_${replicate}"

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

# Function to easily generate temp data files later
mkdir "temp_data"
mk_tempdata_tempfile() {
    local mytempfile=`mktemp`
    tempfile="./temp_data/$(basename ${mytempfile})"
    mv ${mytempfile} ./temp_data/
}
#################################################################

mk_tempdata_tempfile
temp_snaq1_net_file=$tempfile

# Check whether this combo of params has already been run
echo "code=julia --project=snaq1-proj ./check-existence.jl ${ngt} ${nthreads} ${net_abbr} ${ils} ${replicate} ${output_df} 0 1 1"
julia --project=snaq1-proj ./check-existence.jl ${ngt} ${nthreads} ${net_abbr} ${ils} ${replicate} ${output_df} 0 1 1
code=$?
echo "code: ${code}"

if [ $code -eq 0 ]
then
    # Run SNaQ 1
    echo "julia --project=snaq1-proj -p${nprocs} -t${nthreads} ./snaq1.0-estimation.jl ${nhybrids} ${ngt} ${estgt_file} ${temp_snaq1_net_file} ${replicate} > /dev/null"
    julia --project=snaq1-proj -p${nprocs} -t${nthreads} ./snaq1.0-estimation.jl ${nhybrids} ${ngt} ${estgt_file} ${temp_snaq1_net_file} ${replicate} > /dev/null

    # Write results
    echo "julia --project=snaq1-proj ./write-results.jl 1 ${output_df} ${net_abbr} ${ngt} ${temp_snaq1_net_file} ${nthreads} ${ils} ${replicate} > /dev/null"
    julia --project=snaq1-proj ./write-results.jl 1 "${output_df}" ${net_abbr} ${ngt} ${temp_snaq1_net_file} ${nthreads} ${ils} ${replicate} > /dev/null
else
    echo "Skipping, result already exists."
fi