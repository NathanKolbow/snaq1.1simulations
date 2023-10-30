# Input: network
# Output: treefile with N estimated gene trees
#
# Steps:
#   1. simulate gene trees with PhyloCoalSimluations.jl
#   2. simulate sequences with seq-gen
#   3. estimate gene trees with IQTree
#
# Usage: julia ./network-to-est-gene-trees.jl <network directory> <ils (low/med/high)>

if length(ARGS) != 2
    println(ARGS)
    error("Usage: julia ./network-to-est-gene-trees.jl <network directory> <ils (low/med/high)>")
end

if Threads.nthreads() == 1
    @warn "Only using 1 thread. Run with 'julia -tN network-to-est-gene-trees.jl ...' to use N threads."
end

println("Loading Julia packages...")
using PhyloNetworks, PhyloCoalSimulations, StatsBase

# Read in command-line arguments
netabbr = ARGS[1]
ils = ARGS[2]
ntrees = 10000  # more than our max # of gene trees so that we get random variation

# Create the output dir if it doesn't exist
netdir = abspath(joinpath("..", "data", netabbr))
treedir = joinpath(netdir, "treefiles-"*ils*"ILS/")
if !isdir(treedir) mkdir(treedir) end

# Read net and set output file vars
net = readTopology(joinpath(netdir, netabbr*".net"))
gtee_file = joinpath(treedir, "gtee")
est_treefile = joinpath(treedir, "est-gts.treefile")
true_treefile = joinpath(treedir, "true-gts.treefile")

# Adjust branch lengths for given ILS level
if ils == "low"
    for edge in net.edge edge.length *= 0.5 end
elseif ils == "high"
    for edge in net.edge edge.length *= 2 end
elseif ils != "med"
    error("Second argument must be either 'low', 'med', or 'high'; received "*ils)
end

# Set seq_gen -s param for the given net and ILS level
seqgen_s = 0.002
if net.numTaxa == 20
    if net.numHybrids == 3
        if ils == "med"
            seqgen_s = 0.0011
        end
    end
else
    @error "seq_gen -s param not specified for this network."
end

rmsuppress(file) = try rm(file) catch e end     # used later

# Step 0: move to the correct directly
cd(Base.source_dir()*"/..")

# Step 1: simulate gene trees
println("Simulating true gene trees...")
sims = simulatecoalescent(net, ntrees, 1)

# Clear old files
if !isdir("pipelines/temp_data/") mkdir("pipelines/temp_data/") end
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
truelk = ReentrantLock()
gteelk = ReentrantLock()
newicklk = ReentrantLock()
Threads.@threads for i=1:ntrees
    tree = sims[i]
    true_newick = writeTopology(tree)

    temp_seqfile = "pipelines/temp_data/seqgen_"*string(i)*".phy"
    temp_gtfile = "pipelines/temp_data/truegt_"*string(i)*".treefile"
    writeTopology(tree, temp_gtfile)

    # Seq-gen
    if Sys.isapple()
        run(pipeline(`software/seq-gen-macos -s$seqgen_s -n1 -f0.3,0.2,0.2,0.3 -mHKY -op -l1000 $temp_gtfile`, stdout=temp_seqfile, stderr=devnull))
    elseif Sys.islinux()
        run(pipeline(`software/seq-gen-linux -s$seqgen_s -n1 -f0.3,0.2,0.2,0.3 -mHKY -op -l1000 $temp_gtfile`, stdout=temp_seqfile, stderr=devnull))
    else
        run(pipeline(`software/seq-gen-windows.exe -s$seqgen_s -n1 -f0.3,0.2,0.2,0.3 -t3.0 -mHKY -op -l1000 $temp_gtfile`, stdout=temp_seqfile, stderr=devnull))
    end

    # IQ-tree
    if Sys.isapple()
        run(pipeline(`software/iqtree-1.6.12-macos -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    elseif Sys.islinux()
        run(pipeline(`software/iqtree-1.6.12-linux -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    else
        run(pipeline(`software/iqtree-1.6.12-windows.exe -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    end

    # Save the result
    est_newick = readlines(temp_seqfile*".treefile")[1]
    lock(newicklk)
    open(est_treefile, "a", lock=true) do f
        write(f, est_newick*"\n")
    end
    unlock(newicklk)

    # Calculate gene tree estimation error
    gtee_nrf = Pipe()
    run(pipeline(`python3 scripts/compare_two_trees.py -t1 $true_newick -t2 $est_newick`, stdout=gtee_nrf))
    close(gtee_nrf.in)
    gtee_nrf = String(read(gtee_nrf))

    # Save the result
    lock(gteelk)
    open(gtee_file, "a", lock=true) do f
        write(f, gtee_nrf)  # \n is already in the string
    end
    unlock(gteelk)

    lock(truelk)
    open("true_gts", "a", lock=true) do f
        write(f, true_newick*"\n")  # \n is already in the string
    end
    unlock(truelk)

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
    
    Threads.atomic_add!(count, 1)
    print("\rSimulating sequences and estimating gene trees ("*string(count[])*"/"*string(ntrees)*")")
end

gtee_lines = readlines(gtee_file)
avg_gtee = mean([parse(Float64, val) for val in gtee_lines])

println("\nDone! Results stored in \`"*est_treefile*"\`. Average gtee: "*string(round(avg_gtee, digits=3)))