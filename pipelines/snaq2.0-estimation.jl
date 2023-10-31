# Usage: julia -p<nprocs> -t<nprocs> ./snaq2.0-estimation.jl <nhybrids> <ngt> <treefile> <network output file> <probqr> <propq>
verifyargsSNaQ2(ARGS)

@warn "Using "*string(Threads.nthreads())*" threads."

# Load packages
using Distributed
@everywhere using Pkg
@everywhere cd(joinpath(Base.source_dir(), "../PhyloNetworks.jl-master/"))
@everywhere Pkg.activate(".")
@everywhere Pkg.update()
@everywhere Pkg.instantiate()
@everywhere using PhyloNetworks, StatsBase

include("helper-fxns.jl")
nhybrids, ngt, treefile, output_file, probqr, propq = parseSNaQ2estargs(ARGS)


# Put ourselves in the right dir
cd(joinpath(Base.source_dir(), ".."))

# Run SNaQ 2.0
trees, tempout, df = setupSNaQ(treefile, ngt)

println("\n\nRunning SNaQ\n\n")
timespent = @elapsed snaqnet = snaq!(trees[1], df, filename=tempout, hmax=nhybrids, probQR=probqr, propQuartets=propq, seed=42)

# Write output
writeTopology(snaqnet, output_file)
open(output_file, "a") do f
    write(f, string(timespent))
end

# Clean up
cleanSNaQ(tempout)

println("\nSNaQ 2.0 estimated network written to "*output_file)