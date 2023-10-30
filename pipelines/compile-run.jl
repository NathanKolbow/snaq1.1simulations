# Run from `run-one.sh`

# Args in order:
# - output dataframe file
# - network directory
# - number gts
# - number procs
# - est gtee file
# - snaq1 results file
# - snaq2 results files

println("Loading Julia packages...")
using PhyloNetworks, CSV, DataFrames, StatsBase

output_df = abspath(ARGS[1])
netabbr = ARGS[2]
ngt = parse(Int64, ARGS[3])
nprocs = parse(Int64, ARGS[4])
gtee_file = abspath(ARGS[5])
snaq1_file = abspath(ARGS[6])
snaq2_files = [abspath(f) for f in ARGS[7:length(ARGS)]]

netfile = joinpath("../data/", netabbr, netabbr*".net")
truenet = readTopology(netfile)
net_newick = writeTopology(truenet)

getaccuracy(truth::HybridNetwork, est::HybridNetwork) = hardwiredClusterDistance(truth, est, false)

# Mean gene tree estimation error
vals = readlines(gtee_file)
mean_gtee = mean([
    parse(Float64, val) for val in vals
])

# Read in SNaQ 1.0 results
snaq1net, snaq1runtime = readlines(snaq1_file)
snaq1net = readTopology(snaq1net)
snaq1runtime = parse(Float64, snaq1runtime)

# Set up DF
df = DataFrame(
    truenet=[net_newick],
    estnet=[writeTopology(snaq1net)],
    num_gt=[ngt],
    num_procs=[1],
    probQR=[0.],
    whichSNaQ=[1.],
    runtime=[snaq1runtime],
    accuracy=[getaccuracy(truenet, snaq1net)],
    mean_gtee=[mean_gtee]
)

# Read in SNaQ 2.0 results
for snaq2_file in snaq2_files
    probQR = split(snaq2_file, "_")
    probQR = probQR[length(probQR)]
    probQR = parse(Float64, probQR)
    lines = readlines(snaq2_file)

    estnet = readTopology(lines[1])
    runtime = parse(Float64, lines[2])
    acc = getaccuracy(truenet, estnet)

    push!(df, [
        net_newick,
        lines[1],
        ngt,
        nprocs,
        probQR,
        2.,
        runtime,
        acc,
        mean_gtee
    ])
end

CSV.write(output_df, df, append=true)