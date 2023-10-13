#! /bin/bash

# TODO: X. add -p<number of procs> and -t<number of procs> to all Julia calls
#       X. use Distributed for SNaQ 1.0 and SNaQ 2.0 (https://github.com/crsl4/PhyloNetworks.jl/wiki/SNaQ)
#           - 1 thread per CPU
#       X. make sure CPUTime works with Distributed
#           - it does NOT, just using @elapsed instead :(
#       4. add gene tree estimation error (gtee) to outputs
#           - https://github.com/ekmolloy/fastmulrfs
#       5. make sure everything has a set seed
#       6. test SNaQ 1.0 and 2.0 runtime on 8 processors on CHTC (single run each)
#       7. estimate concatenated species tree w/ IQTree to use as SNaQ 1.0/2.0 starting points
#       8. update compile-run.jl to reflect the new columns in results.csv

# 10 taxa, 3 retic network:
# ((1,(2)#H3),(((3,#H3),(((4,((5,(6)#H1),(7,#H1))),(8))#H2),((9,10),#H2))));

# Setting branch lengths for low/med/high ILS settings:
#
# net = <topology>
# for edge in net.edge
#     if edge.length != 0
#         if high ILS
#             edge.length = 0.2
#         elseif medium ILS
#             edge.length = 1
#         else
#             edge.length = 2
#         end
#     end
# end


# Runs the full pipeline for one each of:
# - network
# - number of gene trees
# - number of processors
#
# `snaq1.0-estimation.jl` is run once, but
# `snaq2.0-estimation.jl` is run once for each probQR value
#
# Usage: ./run-one.sh "<network newick>" <output dataframe> <N gene trees> <number of processors>
#   (output is appended to the data frame)
#
# USER MUST BE IN THE `pipelines` DIRECTORY WHEN RUNNING
#
# Example: ./run-one.sh "((A:1.0,((B:1.0,C:1.0):1.0,(D:1.0)#H1:1.0::0.5):1.0):1.0,(#H1:1.0::0.5,E:1.0):1.0);" ../results/results.csv 5 4

net_newick=$1
output_df=$2
ngt=$3
nprocs=$4

if [ "${net_newick}" == "(((A:1,B:1):1,#H1:1::0.7):1,(((C:1,(D:1,#H2:1::0.7):1):1)#H1:1::0.3,((E:1)#H2:1::0.3,F:1):1):1):1;" ]
then
    nhybrids=2
else
    nhybrids=3
fi


# Generate estimated gene trees
mkdir temp_data
mytempfile=`mktemp`
temp_gt_file="./temp_data/$(basename ${mytempfile})"
mv ${mytempfile} ./temp_data/

echo "julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_newick} ${temp_gt_file} ${ngt}"
julia -p${nprocs} -t${nprocs} ./network-to-est-gts.jl ${net_newick} ${temp_gt_file} ${ngt}

# Estimate w/ SNaQ 1.0
mytempfile=`mktemp`
temp_snaq1_net_file="./temp_data/$(basename ${mytempfile})"
mv ${mytempfile} ./temp_data/

echo "julia -p${nprocs} -t${nprocs} ./snaq1.0-estimation.jl ${nhybrids} ${temp_gt_file} ${temp_snaq1_net_file}"
julia -p${nprocs} -t${nprocs} ./snaq1.0-estimation.jl ${nhybrids} ${temp_gt_file} ${temp_snaq1_net_file}

# Estimate w/ SNaQ 2.0
snaq2_netfiles=()
for probQR in 0 0.25 0.5 0.75 1
do
    mytempfile=`mktemp`
    currfile="./temp_data/${probQR}_$(basename ${mytempfile})"
    snaq2_netfiles+=(${currfile})
    mv ${mytempfile} ./${currfile}

    echo "julia -p${nprocs} -t${nprocs} ./snaq2.0-estimation.jl ${nhybrids} ${temp_gt_file} ${currfile} ${probQR}"
    julia -p${nprocs} -t${nprocs} ./snaq2.0-estimation.jl ${nhybrids} ${temp_gt_file} ${currfile} ${probQR}
done

# Write to DF
echo "julia ./compile-run.jl ${output_df} ${ngt} ${nprocs} ${temp_snaq1_netfile} ${snaq2_netfiles[@]}"
julia ./compile-run.jl ${output_df} "${net_newick}" ${ngt} ${nprocs} ${temp_snaq1_netfile} ${snaq2_netfiles[@]}

# Clean up temp files
echo "Cleaning up temp files"
rm ${temp_gt_file}
rm ${temp_snaq1_net_file}
for snaq2temp in ${snaq2_netfiles[@]}
do
    rm ${snaq2temp}
done






