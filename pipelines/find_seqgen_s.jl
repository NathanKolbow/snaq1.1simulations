# julia -p8 -t8 ./find_seqgen_s.jl 0.30 "((((((1:1.0,#H1:1.0::0.5):1.0,(3:1.0,(2:1.0)#H1:1.0::0.5):1.0):1.0,4:1.0):1.0,(((5:1.0,(6:1.0,7:1.0):1.0):1.0,8:1.0):1.0,(9:1.0,((10:1.0,#H2:1.0::0.5):1.0,(12:1.0,(11:1.0)#H2:1.0::0.5):1.0):1.0):1.0):1.0):1.0,((((13:1.0,14:1.0):1.0,(15:1.0,16:1.0):1.0):1.0,#H3:1.0::0.5):1.0,((17:1.0,18:1.0):1.0,(19:1.0)#H3:1.0::0.5):1.0):1.0):1.0,20:1.0);"
# Finds the `-s#` that gives a desired gtee value for a given network
if Threads.nthreads() == 1
    @warn "Only using 1 thread. Run with 'julia -tN network-to-est-gene-trees.jl ...' to use N threads."
end

using PhyloNetworks, PhyloCoalSimulations, StatsBase
rmsuppress(file) = try rm(file) catch e end     # used later

desired_gtee = parse(Float64, ARGS[1])
net = readTopology(ARGS[2])
ntrees = 100
sims = simulatecoalescent(net, ntrees, 1)
tolerance = 0.05

ntrees = 100
global gtees = zeros(ntrees)
global min_s = 0.00001
global max_s = 0.1
global curr_s = 0.003

while true
    global min_s, max_s, curr_s, gtees
    println("\nTrying -s`"*string(curr_s)*"`...")

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

    avg_gtee = mean(gtees)
    print("- mean gtee: "*string(avg_gtee))

    if mean(gtees) - desired_gtee > tolerance
        min_s = curr_s
        curr_s = mean([max_s, min_s])
        println("; increasing")
    elseif mean(gtees) - desired_gtee < -tolerance
        max_s = curr_s
        curr_s = mean([max_s, min_s])
        println("; reducing")
    else
        println("\n\nFound `-s"*string(curr_s)*"` with mean gtee "*string(mean(gtees)))
        break
    end
end