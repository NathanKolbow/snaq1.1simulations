# julia -p8 -t8 ./find_seqgen_s.jl 0.25 "n10r1" "med"
# Finds the `-s#` that gives a desired gtee value for a given network

# All network -s params generated with:
#
# for netabbr in ../data/n*r*
# do
#   for ils in low med high
#   do
#     julia -p16 -t16 find_seqgen_s.jl 0.25 ${netabbr: -5} ${ils}
#   done
# done

if Threads.nthreads() == 1
    @warn "Only using 1 thread. Run with 'julia -tN network-to-est-gene-trees.jl ...' to use N threads."
end

using PhyloNetworks, PhyloCoalSimulations, StatsBase
rmsuppress(file) = try rm(file) catch e end     # used later

desired_gtee = parse(Float64, ARGS[1])
netabbr = ARGS[2]
ils = ARGS[3]

net = readTopology(joinpath("..", "data", netabbr, netabbr*".net"))
mod = ifelse(ils == "med", 1, ifelse(ils == "high", 2, ifelse(ils == "low", 0.5, -1)))
mod != -1 || error("ils value $ils not recognized.")
for edge in net.edge edge.length *= mod end

ntrees = 500
sims = simulatecoalescent(net, ntrees, 1)
tolerance = 0.025

global gtees = zeros(ntrees)
global min_s = 0.00001
global max_s = 0.1
global curr_s = 0.003

print("\r$netabbr $ils ILS: searching...")
while true
    global min_s, max_s, curr_s, gtees
    Threads.@threads for i=1:ntrees
        tree = sims[i]
        true_newick = writeTopology(tree)

        temp_seqfile = "./temp_data/seqgen_"*string(i)*".phy"
        temp_gtfile = "./temp_data/truegt_"*string(i)*".treefile"
        writeTopology(tree, temp_gtfile)

        # Seq-gen
        run(pipeline(`../software/seq-gen-linux -s$curr_s -n1 -f0.3,0.2,0.2,0.3 -mHKY -op -l1000 $temp_gtfile`, stdout=temp_seqfile, stderr=devnull))

        # IQ-tree
        run(pipeline(`../software/iqtree-1.6.12-linux -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))

        # Save the result
        est_newick = readlines(temp_seqfile*".treefile")[1]

        # Calculate gene tree estimation error
        gtee_nrf = Pipe()
        run(pipeline(`python3 ../scripts/compare_two_trees.py -t1 $true_newick -t2 $est_newick`, stdout=gtee_nrf))
        close(gtee_nrf.in)
        gtee_nrf = String(read(gtee_nrf))
        gtees[i] = parse(Float64, gtee_nrf)

        # Clean up
        rmsuppress(temp_gtfile)
        rmsuppress(temp_seqfile)
        rmsuppress(temp_seqfile*".bionj")
        rmsuppress(temp_seqfile*".ckp.gz")
        rmsuppress(temp_seqfile*".iqtree")
        rmsuppress(temp_seqfile*".log")
        rmsuppress(temp_seqfile*".mldist")
        rmsuppress(temp_seqfile*".model.gz")
        rmsuppress(temp_seqfile*".treefile")
    end

    avg_gtee = round(mean(gtees), sigdigits=4)
    print("\r$netabbr $ils ILS: -s$curr_s ($avg_gtee)")

    if mean(gtees) - desired_gtee > tolerance
        min_s = curr_s
        curr_s = mean([max_s, min_s])
        print("; increasing      ")
    elseif mean(gtees) - desired_gtee < -tolerance
        max_s = curr_s
        curr_s = mean([max_s, min_s])
        print("; reducing        ")
    else
        println("                     ")
        break
    end
    curr_s = round(curr_s, sigdigits=4)
end

treefile_dir = joinpath("..", "data", netabbr, "treefiles-$ils"*"ILS")
if !isdir(treefile_dir) mkdir(treefile_dir) end
open(joinpath(treefile_dir, "seqgen-s"), "w+") do f
    write(f, "$curr_s\n")
end