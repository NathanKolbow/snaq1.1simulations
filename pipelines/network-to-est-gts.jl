# Input: network
# Output: treefile with N estimated gene trees
#
# Steps:
#   1. simulate gene trees with PhyloCoalSimluations.jl
#   2. simulate sequences with seq-gen
#   3. estimate gene trees with IQTree
#
# Usage: julia ./network-to-est-gene-trees.jl <network newick> <output file> <number of trees>

if Threads.nthreads() == 1
    @warn "Only using 1 thread. Run with 'julia -tN network-to-est-gene-trees.jl ...' to use N threads."
end

println("Loading Julia packages...")
using PhyloNetworks, PhyloCoalSimulations

# Read in command-line arguments
if length(ARGS) != 3
    error("Usage: julia network-to-est-gene-trees.jl <file with network> <output file> <number of trees>")
end
input_newick = ARGS[1]
output_file = ARGS[2]
ntrees = parse(Int64, ARGS[3])

net = readTopology(input_newick)

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

println("Simulating sequences and estimating gene trees...")
count = Threads.Atomic{Int}(0)
Threads.@threads for i=1:ntrees
    Threads.atomic_add!(count, 1)
    print("\rSimulating sequences and estimating gene trees ("*string(count[])*"/"*string(ntrees)*")")
    tree = sims[i]

    temp_seqfile = "pipelines/temp_data/seqgen_"*string(i)*".phy"
    temp_gtfile = "pipelines/temp_data/truegt_"*string(i)*".treefile"
    writeTopology(tree, temp_gtfile)

    # Seq-gen
    run(pipeline(`software/seq-gen-macos-m1 -mGTR -op -l1000 $temp_gtfile`, stdout=temp_seqfile, stderr=devnull))

    # IQ-tree
    if isfile(temp_seqfile*".treefile")
        run(pipeline(`software/iqtree-1.6.12-macos -quiet -redo -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    else
        run(pipeline(`software/iqtree-1.6.12-macos -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    end

    # Save the result
    newick = readlines(temp_seqfile*".treefile")
    open(output_file, "a") do f
        write(f, newick[1]*"\n")
    end

    # Clean up
    rm(temp_gtfile)
    rm(temp_seqfile)
    rm(temp_seqfile*".bionj")
    rm(temp_seqfile*".ckp.gz")
    rm(temp_seqfile*".iqtree")
    rm(temp_seqfile*".log")
    rm(temp_seqfile*".mldist")
    rm(temp_seqfile*".model.gz")
    rm(temp_seqfile*".treefile")
end

println("Done! Results stored in \`"*output_file*"\`.")