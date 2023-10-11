# Usage: julia -t<nthreads> ./snaq2.0-estimation.jl <nhybrids> <treefile> <network output file> <probqr>

if length(ARGS) != 4
    error("Usage: julia ./snaq1.0-estimation.jl <nhybrids> <treefile> <network output file> <probqr>")
end
nhybrids = parse(Int64, ARGS[1])
treefile = abspath(ARGS[2])
output_file = abspath(ARGS[3])
probqr = parse(Float64, ARGS[4])
isfile(treefile) || error("treefile "*string(treefile)*" not found.")

@warn "Using "*string(Threads.nthreads())*" threads."

# Load packages
using Pkg
cd(joinpath(Base.source_dir(), "../PhyloNetworks.jl-master/"))
Pkg.activate(".")
Pkg.instantiate()
using PhyloNetworks
# Should probably put something here to make sure that the correct
# version of PhyloNetworks was loaded

# Put ourselves in the right dir
cd(joinpath(Base.source_dir(), ".."))

println("Reading treefile...")
trees = readMultiTopology(treefile)

# Run SNaQ 2.0
println("\n\nReading quartet info...\n\n")
tempout = "./pipelines/temp_data/temp_snaq_"*string(abs(rand(Int64)))
q, t = countquartetsintrees(trees)
df = readTableCF(writeTableCF(q, t))

println("\n\nRunning SNaQ\n\n")
snaqnet = snaq!(trees[1], df, filename=tempout, hmax=nhybrids, probQR=probqr)

# Write output
writeTopology(snaqnet, output_file)

# Clean up
rm(tempout*".err")
rm(tempout*".log")
rm(tempout*".out")
rm(tempout*".networks")

println("\nSNaQ 2.0 estimated network written to "*output_file)