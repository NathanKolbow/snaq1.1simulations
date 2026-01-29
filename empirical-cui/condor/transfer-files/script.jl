@info "Entering Julia script"
using Distributed

# Verify number of processors
if nprocs() == 1
    error("Should be run w/ multiple processors.")
end

# Verify arguments
if length(ARGS) != 2
    error("Usage: julia script.jl <NumHybs> <PropQuartets>")
end
try
    @show parse(Int64, ARGS[1])
    @show parse(Float64, ARGS[2])
catch
    error("(Parse Error) Usage: julia script.jl <NumHybs> <PropQuartets>")
end


# Load PhyloNetworks
@info "Loading PhyloNetworks"
@everywhere using PhyloNetworks
pqr = 1.
pqt = parse(Float64, ARGS[2])
nhybrids = parse(Int64, ARGS[1])

# Load data
@info "Reading starting tree"
t = readTopology("best$(nhybrids).tre")   # real data

@info "Reading CF table"
d = readTableCF("cui-neza.csv")    # real data

# Run SNaQ
@info "Running SNaQ"
filename = pqt == 1.0 ? "/mnt/ws/home/nkolbow/repos/snaq2/empirical-cui/condor/snaq_outputs/cui_net_$(nhybrids)hyb"
    : "/mnt/ws/home/nkolbow/repos/snaq2/empirical-cui/condor/snaq_outputs_pq$(pqt)/cui_net_$(nhybrids)hyb"
if !isfile("$(filename).runtime")
    time_taken = @elapsed net = snaq!(t, d, hmax=nhybrids, probQR=pqr, propQuartets=pqt, seed=42, filename=filename)
    
    # Save results
    @info "Saving runtime"
    open("$(filename).runtime", "w+") do f
        write(f, "$(time_taken)\n")
    end
else
    println("--- Results already exist, skipping analyses.")
end

