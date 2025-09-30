# Usage: julia -p<nprocs> -t<nprocs> ./snaq2.0-estimation.jl <nhybrids> <ngt> <treefile> <network output file> <probqr> <propq>
@warn "Using "*string(Threads.nthreads())*" threads."

# Load packages
@everywhere using PhyloNetworks, StatsBase
@everywhere include("helper-fxns.jl")

verifyargsSNaQ2(ARGS)

# Put ourselves in the right dir
nhybrids, ngt, treefile, output_file, probqr, propq, replicate = parseSNaQ2estargs(ARGS)

@everywhere cd("/mnt/dv/wid/projects4/SolisLemus-snaq2/")

# Run SNaQ 2.0
trees, tempout, df = setupSNaQ(treefile, ngt)

println("\n\nRunning SNaQ\n\n")
timespent = @elapsed snaqnet = snaq!(trees[1], df, filename=tempout, hmax=nhybrids, probQR=probqr, propQuartets=propq, seed=42)

# Write output
if !isfile(output_file) touch(output_file) end
writeTopology(snaqnet, output_file)
open(output_file, "a") do f
    write(f, string(timespent))
end

# Clean up
cleanSNaQ(tempout)

println("\nSNaQ 2.0 estimated network written to "*output_file)
