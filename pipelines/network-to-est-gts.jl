# Input: network
# Output: treefile with N estimated gene trees
#
# Steps:
#   1. simulate gene trees with PhyloCoalSimluations.jl
#   2. simulate sequences with seq-gen
#   3. estimate gene trees with IQTree
#
# Usage: julia ./network-to-est-gene-trees.jl <network newick> <output file> <number of trees> <gtee file>

if Threads.nthreads() == 1
    @warn "Only using 1 thread. Run with 'julia -tN network-to-est-gene-trees.jl ...' to use N threads."
end

println("Loading Julia packages...")
using PhyloNetworks, PhyloCoalSimulations, StatsBase

# Read in command-line arguments
if length(ARGS) != 4
    println(ARGS)
    error("Usage: julia ./network-to-est-gene-trees.jl <network newick> <output file> <number of trees> <gtee file>")
end
input_newick = ARGS[1]
output_file = abspath(ARGS[2])
ntrees = parse(Int64, ARGS[3])
gtee_file = abspath(ARGS[4])

net = readTopology(input_newick)

seqgen_s = 0.
if net.numTaxa == 20
    if net.numHybrids == 3
        # All branch lengths 1
        seqgen_s = 0.0011
    end
end

rmsuppress(file) = try rm(file) catch e end     # used later

# Step 0: move to the correct directly
cd(Base.source_dir()*"/..")

# Step 1: simulate gene trees
println("Simulating true gene trees...")
sims = simulatecoalescent(net, ntrees, 1)

# Step 2: simulate sequences with seq-gen
# Step 3: estimate gene trees with IQ tree
if !isdir("pipelines/temp_data/") mkdir("pipelines/temp_data/") end
if isfile(output_file) rm(output_file) end
touch(output_file)
if isfile(gtee_file) rm(gtee_file) end
touch(gtee_file)

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
        # RAxML also bad
        # run(pipeline(`software/raxml-ng --msa $temp_seqfile --model GTR`, stdout=devnull, stderr=devnull))
        run(pipeline(`software/iqtree-1.6.12-linux -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    else
        run(pipeline(`software/iqtree-1.6.12-windows.exe -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    end

    # Save the result
    est_newick = readlines(temp_seqfile*".treefile")[1]
    lock(newicklk)
    open(output_file, "a", lock=true) do f
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

println("\nDone! Results stored in \`"*output_file*"\`. Average gtee: "*string(round(avg_gtee, digits=3)))