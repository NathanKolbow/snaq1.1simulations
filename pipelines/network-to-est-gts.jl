# Input: network
# Output: treefile with N estimated gene trees
#
# Steps:
#   1. simulate gene trees with PhyloCoalSimluations.jl
#   2. simulate sequences with seq-gen
#   3. estimate gene trees with IQTree
#
# Usage: julia ./network-to-est-gene-trees.jl <network directory> <ils (low/med/high)> <replicateID>

include("helper-fxns.jl")

verifyargs_nettogts(ARGS)
warnsinglethread()

println("Loading Julia packages...")
using PhyloNetworks, PhyloCoalSimulations, StatsBase

# Read in command-line arguments
netabbr = ARGS[1]
ils = ARGS[2]
replicate = parse(Int64, ARGS[3])
ntrees = 4430   # 30 + 100 + 300 + 1000 + 3000

# Create the output dir if it doesn't exist
netdir = getnetdir(netabbr)
treedir = joinpath(netdir, "treefiles-"*ils*"ILS/")
if !isdir(treedir) mkdir(treedir) end

# Read net and set output file vars
net = readTopology(gettruenewick(netabbr))
gtee_file = getgteefilepath(netabbr, ils, replicate)
est_treefile = getestgtfilepath(netabbr, ils, replicate)
true_treefile = gettruegtfilepath(netabbr, ils, replicate)

# Adjust branch lengths for given ILS level
if ils == "low"
    for edge in net.edge edge.length *= 0.5 end
elseif ils == "high"
    for edge in net.edge edge.length *= 2 end
elseif ils != "med"
    error("Second argument must be either 'low', 'med', or 'high'; received "*ils)
end

# Set seq_gen -s param for the given net and ILS level
seqgen_s = getseqgen_sfilepath(netabbr, ils)
seqgen_s = readlines(seqgen_s)[1]
seqgen_s = parse(Float64, seqgen_s)

rmsuppress(file) = try rm(file) catch e end     # used later

# Step 0: move to the correct directly
cd("/mnt/ws/home/nkolbow/repos/snaq2/")

# Step 1: simulate gene trees
println("Simulating true gene trees...")
sims = simulatecoalescent(net, ntrees, 1)

# Clear old files
if !isdir("./pipelines/") mkdir("./pipelines/") end     # this line just for condor scratch directory
if !isdir("./pipelines/temp_data/") mkdir("./pipelines/temp_data/") end
if isfile(est_treefile) rm(est_treefile) end
touch(est_treefile)
if isfile(gtee_file) rm(gtee_file) end
touch(gtee_file)
if isfile(true_treefile) rm(true_treefile) end
touch(true_treefile)

# Write sims to true treefile
writeMultiTopology(sims, true_treefile)

# Step 2: simulate sequences with seq-gen
# Step 3: estimate gene trees with IQ tree
println("Simulating sequences and estimating gene trees...")
count = Threads.Atomic{Int}(0)
lk = ReentrantLock()
Threads.@threads for i=1:ntrees
    tree = sims[i]
    true_newick = writeTopology(tree)

    temp_seqfile = "./pipelines/temp_data/seqgen_"*string(i)*".phy"
    temp_gtfile = "./pipelines/temp_data/truegt_"*string(i)*".treefile"
    writeTopology(tree, temp_gtfile)

    # Seq-gen
    runseqgen(seqgen_s, temp_gtfile, temp_seqfile)

    # IQ-tree
    runiqtree(temp_seqfile)

    # Save the result
    est_newick = readlines(temp_seqfile*".treefile")[1]

    # Calculate gene tree estimation error
    gtee_nrf = calc_gtee(true_newick, est_newick)

    # Save the results
    appendtolockedfiles([est_treefile, gtee_file], lk, [est_newick*"\n", gtee_nrf])

    # Clean up
    cleanestgtfiles(temp_gtfile, temp_seqfile)
    
    Threads.atomic_add!(count, 1)
    print("\rSimulating sequences and estimating gene trees ("*string(count[])*"/"*string(ntrees)*")")
end

gtee_lines = readlines(gtee_file)
avg_gtee = mean([parse(Float64, val) for val in gtee_lines])

println("\nDone! Results stored in \`"*est_treefile*"\`. Average gtee: "*string(round(avg_gtee, digits=3)))