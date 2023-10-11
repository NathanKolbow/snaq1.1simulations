# Usage: julia ./snaq1.0-estimation.jl <nhybrids> <treefile> <network output file>
println("Loading packages...")
using PhyloNetworks

if length(ARGS) != 3
    error("Usage: julia ./snaq1.0-estimation.jl <nhybrids> <treefile> <output file>")
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
snaqnet = snaq!(trees[1], df, filename=tempout, hmax=nhybrids)

# Write output
writeTopology(snaqnet, output_file)

# Clean up
rm(tempout*".err")
rm(tempout*".log")
rm(tempout*".out")
rm(tempout*".networks")

println("\nSNaQ 1.0 estimated network written to "*output_file)