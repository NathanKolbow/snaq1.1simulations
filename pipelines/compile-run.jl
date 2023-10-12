# Run from `run-one.sh`
# julia ./compile-run.jl ${output_df} "${net_newick}" ${ngt} ${nthreads} ${temp_snaq1_netfile} ${snaq2_netfiles[@]}

println("Loading Julia packages...")
using PhyloNetworks, CSV, DataFrames

output_df = abspath(ARGS[1])
net_newick = ARGS[2]
ngt = parse(Int64, ARGS[3])
nthreads = parse(Int64, ARGS[4])
snaq1_file = abspath(ARGS[5])
snaq2_files = [abspath(f) for f in ARGS[6:length(ARGS)]]
truenet = readTopology(net_newick)

getaccuracy(truth::HybridNetwork, est::HybridNetwork) = hardwiredClusterDistance(truth, est, rooted=false)

# Read in SNaQ 1.0 results
snaq1net, snaq1runtime = readlines(snaq1_file)
snaq1net = readTopology(snaq1net)
snaq1runtime = parse(Float64, snaq1runtime)

# Set up DF
df = DataFrame(
    truenet=[net_newick],
    estnet=[writeTopology(snaq1net)],
    num_gt=[ngt],
    num_threads=[1],
    probQR=[0.],
    runtime=[snaq1runtime],
    accuracy=[getaccuracy(truenet, snaq1net)]
)

# Read in SNaQ 2.0 results
for snaq2_file in snaq2_files
    probQR = split(snaq2_file, "/")
    probQR = split(probQR[length(probQR)], "_")[1]
    probQR = parse(Float64, probQR)
    lines = readlines(snaq2_file)

    estnet = readTopology(lines[1])
    runtime = parse(Float64, lines[2])
    acc = getaccuracy(truenet, estnet)

    push!(df, [
        net_newick,
        lines[1],
        ngt,
        nthreads,
        probQR,
        runtime,
        acc
    ])
end

CSV.write(output_df, df, append=true)