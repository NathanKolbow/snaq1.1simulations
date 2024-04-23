#!/bin/bash

cd /mnt/ws/home/nkolbow/repos/snaq2/pipelines

for net_abbr in n10r1 n10r3 n20r1 n20r3
do
    for replicate in $(seq 1 100)
    do
        echo "${net_abbr} - ${replicate}"
        estgt_file="/mnt/ws/home/nkolbow/repos/snaq2/data/input/${net_abbr}/treefiles/medILS/estgts_${replicate}.treefile"
        if [ -f "${estgt_file}" ]
        then
            nlines=`wc -l < $estgt_file`
            if [ $nlines -eq 4430 ]
            then
                echo "    Skipping - already generated."
                echo ""
                continue
            fi
        fi

        julia -p15 -t16 ./network-to-est-gts.jl ${net_abbr} med ${replicate}
        echo ""
    done
done