# Usage: julia -p<nprocs> -t<nprocs> ./snaq1.0-estimation.jl <nhybrids> <ngt> <treefile> <network output file>
include("helper-fxns.jl")
verifyargsSNaQ1(ARGS)

println("Loading packages...")
using Distributed
@everywhere using PhyloNetworks, StatsBase

nhybrids, ngt, treefile, output_file = parseSNaQ1estargs(ARGS)

# Put ourselves in the right dir
cd(joinpath(Base.source_dir(), ".."))

# Run SNaQ 1.0
trees, tempout, df = setupSNaQ(treefile, ngt)

println("\n\nRunning SNaQ\n\n")
timespent = @elapsed snaqnet = snaq!(trees[1], df, filename=tempout, hmax=nhybrids, seed=42)

# Write output
writeTopology(snaqnet, output_file)
open(output_file, "a") do f
    write(f, string(timespent))
end

# Clean up
cleanSNaQ(tempout)

println("\nSNaQ 1.0 estimated network written to "*output_file)