# Usage: julia -p<nprocs> -t<nprocs> ./snaq1.0-estimation.jl <nhybrids> <treefile> <network output file>

println("Loading packages...")
using Distributed
@everywhere using PhyloNetworks

if length(ARGS) != 3
    error("Usage: julia -p<nprocs> -t<nprocs> ./snaq1.0-estimation.jl <nhybrids> <treefile> <network output file>")
end
nhybrids = parse(Int64, ARGS[1])
treefile = abspath(ARGS[2])
output_file = abspath(ARGS[3])
isfile(treefile) || error("treefile "*string(treefile)*" not found.")

# Put ourselves in the right dir
cd(joinpath(Base.source_dir(), ".."))

println("Reading treefile...")
trees = readMultiTopology(treefile)

# Run SNaQ 1.0
println("\n\nReading quartet info...\n\n")
tempout = "./pipelines/temp_data/temp_snaq_"*string(abs(rand(Int64)))
q, t = countquartetsintrees(trees)
df = readTableCF(writeTableCF(q, t))

println("\n\nRunning SNaQ\n\n")
timespent = @elapsed snaqnet = snaq!(trees[1], df, filename=tempout, hmax=nhybrids, seed=42)

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

println("\nSNaQ 1.0 estimated network written to "*output_file)