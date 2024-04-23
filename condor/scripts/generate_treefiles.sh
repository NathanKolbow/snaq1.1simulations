#!/bin/bash
# $1: network abbreviation
# $2: ils level
# $3: number of processors
# $4: replicate id

set -e

########################## BOILERPLATE ##########################
# Setup Julia
./julia_setup.sh
export PATH=$PWD/julia-1.9.3/bin:$PATH

# Arguments
net_abbr=$1
ils=$2
nthreads=$3
nprocs=$((nthreads - 1))    # we do this b/c -p2 gives 3 procs, not 2
replicate=$4

# Directories and filepaths
netdir="/mnt/ws/home/nkolbow/repos/snaq2/data/input/${net_abbr}"
treefiledir="${netdir}/treefiles/${ils}ILS"

estgt_file="${treefiledir}/estgts_${replicate}.treefile"
truegt_file="${treefiledir}/truegts_${replicate}.treefile"
seqgen_sfile="${treefiledir}/seqgen-s_${replicate}"
gtee_file="${treefiledir}/gtee_${replicate}"
#################################################################

if [ -f "${estgt_file}" ]
then
    nlines=`wc -l < $estgt_file`
    if [ $nlines -eq 4430 ]
    then
        echo "[INFO] Skipping estimated gene tree generation for ${net_abbr} with ${ils} ILS replicate ${replicate}; already exists."
        
        exit
    else
        echo "[INFO] Old treefile detected for ${net_abbr} with ${ils} ILS replicate ${replicate}. Redoing estimated tree generation."
    fi
fi

echo "[EXEC] julia -p${nprocs} -t${nthreads} ./network-to-est-gts.jl ${net_abbr} ${ils} ${replicate} > /dev/null"
julia -p${nprocs} -t${nthreads} ./network-to-est-gts.jl ${net_abbr} ${ils} ${replicate} > /dev/null