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

include("helper-fxns.jl")
warnsinglethread()

using PhyloNetworks, PhyloCoalSimulations, StatsBase

desired_gtee, netabbr, ils = parseargsseqgen(ARGS)
net = readnetwithILS(netabbr, ils)

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
        runseqgen(curr_s, temp_gtfile, temp_seqfile)

        # IQ-tree
        runiqtree(temp_seqfile)

        # Save the result
        est_newick = readlines(temp_seqfile*".treefile")[1]

        # Calculate gene tree estimation error
        gtee_nrf = calc_gtee(true_newick, est_newick)
        gtees[i] = parse(Float64, gtee_nrf)

        # Clean up
        cleanestgtfiles(temp_gtfile, temp_seqfile)
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