using Distributed

# Verify number of processors
if nprocs() < 16
    error("Should be run w/ 16 processors.")
end

# Verify arguments
if length(ARGS) != 1
    error("First argument should be an integer in [0, 5], found $(ARGS).")
end
try
    parse(Int64, ARGS[1])
catch
    error("First argument should be an integer in [0, 5], found $(ARGS).")
end


# Load PhyloNetworks
@everywhere using PhyloNetworks
pqr = 1     # fully weighted
pqt = 0.7   # use a portion of quartets
nhybrids = parse(Int64, ARGS[1])

# Load data
# t = readTopology("cui_etal_data.msbum.QMC.tre")   # real data
# d = readTableCF("cui_etal_data.msbum.CFs.csv")    # real data
t = readTopology("test_data.tre")
d = readTableCF("test_data.CFs.csv")

filename = "/mnt/ws/home/nkolbow/repos/snaq2/empirical-cui/condor/snaq_outputs/cui_net_$(nhybrids)hyb"
time_taken = @elapsed net = snaq!(t, d, hmax=nhybrids, probQR=pqr, propQuartets=pqt, seed=42, filename=filename)


# WRITE CODE TO SAVE RESULTS, INCLUDING RUNTIME
open("$(filename).runtime", "w+") do f
    write(f, "$(time_taken)\n")
end