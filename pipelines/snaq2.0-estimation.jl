# Usage: julia -p<nprocs> -t<nprocs> ./snaq2.0-estimation.jl <nhybrids> <ngt> <treefile> <network output file> <probqr>

if length(ARGS) != 5
    error("Usage: julia -p<nprocs> -t<nprocs> ./snaq2.0-estimation.jl <nhybrids> <ngt> <treefile> <network output file> <probqr>")
end
nhybrids = parse(Int64, ARGS[1])
ngt = parse(Int64, ARGS[2])
treefile = abspath(ARGS[3])
output_file = abspath(ARGS[4])
probqr = parse(Float64, ARGS[5])
isfile(treefile) || error("treefile "*string(treefile)*" not found.")

@warn "Using "*string(Threads.nthreads())*" threads."

# Load packages
using Distributed
@everywhere using Pkg
@everywhere cd(joinpath(Base.source_dir(), "../PhyloNetworks.jl-master/"))
@everywhere Pkg.activate(".")
@everywhere Pkg.update()
@everywhere Pkg.instantiate()
@everywhere using PhyloNetworks, StatsBase


# Put ourselves in the right dir
cd(joinpath(Base.source_dir(), ".."))

println("Reading treefile...")
trees = readMultiTopology(treefile)
trees = sample(trees, ngt, replace=false)

# Run SNaQ 2.0
println("\n\nReading quartet info...\n\n")
tempout = "./pipelines/temp_data/temp_snaq_"*string(abs(rand(Int64)))
q, t = countquartetsintrees(trees)
df = readTableCF(writeTableCF(q, t))

println("\n\nRunning SNaQ\n\n")
timespent = @elapsed snaqnet = snaq!(trees[1], df, filename=tempout, hmax=nhybrids, probQR=probqr, seed=42)

# Write output
writeTopology(snaqnet, output_file)
open(output_file, "a") do f
    write(f, string(timespent))
end

# Clean up
rmsuppress(file) = try rm(file) catch e end
rmsuppress(tempout*".err")
rmsuppress(tempout*".log")
rmsuppress(tempout*".out")
rmsuppress(tempout*".networks")

println("\nSNaQ 2.0 estimated network written to "*output_file)