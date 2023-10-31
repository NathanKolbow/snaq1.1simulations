include("helper-fxns.jl")
whichSNaQ = verifyargs_writeresults(ARGS)

using PhyloNetworks, CSV, DataFrames, StatsBase

function processthenwrite(outputfilename::AbstractString, whichSNaQ::Integer, netabbr::AbstractString, ngt::Real, estnetruntimefilename::AbstractString, nprocs::Real, ils::AbstractString, replicateid::Real;
    probQR::AbstractFloat=0., propQuartets::AbstractFloat=1.)
    idxs = getsimidxs(ngt)
    gtee = readlines(joinpath(gettreefiledir(netabbr, ils), "gtee"))[idxs]
    gtee = mean([parse(Float64, line) for line in gtee])

    truenet = gettruenewick(netabbr)
    estnet, runtime = readlines(estnetruntimefilename)[1:2]
    runtime = parse(Float64, runtime)

    writeresults(outputfilename, truenet, estnet, ngt, nprocs, probQR, propQuartets, whichSNaQ, runtime, replicateid, gtee, ils)
end

function writeresults(outputfilename::AbstractString, truenetnewick::AbstractString, estnetnewick::AbstractString, ngt::Real, nprocs::Real, probQR::AbstractFloat, propQuartets::AbstractFloat,
    whichSNaQ::Real, runtime::Real, replicateid::Real, mean_gtee::Real, ils::AbstractString)
    # Verify inputs are valid
    ngt = Int64(ngt)
    nprocs = Int64(nprocs)
    whichSNaQ = Int64(whichSNaQ)

    # Make sure all non-negative inputs are actually non-negative
    minimum([ngt, nprocs, probQR, propQuartets, whichSNaQ, replicateid, mean_gtee]) >= 0 || error("Some value passed was negative. (ngt, nprocs, probQR, propQuartets, whichSNaQ, replicateid): ($ngt, $nprocs, $probQR, $propQuartets, $whichSNaQ, $replicateid)")

    truenet = readTopology(truenetnewick)
    estnet = readTopology(estnetnewick)

    df = DataFrame(
        truenet=[truenetnewick],
        estnet=[estnetnewick],
        numgt=[ngt],
        numprocs=[nprocs],
        probQR=[probQR],
        propQuartets=[propQuartets],
        whichSNaQ=[whichSNaQ],
        runtime=[runtime],
        netRF=[getRFdist(truenet, estnet)],
        majortreeRF=[getRFdist(majorTree(truenet), majorTree(estnet))],
        mean_gtee=[mean_gtee],
        ntaxa=[truenet.numTaxa],
        nhybrids_true=[truenet.numHybrids],
        nhybrids_est=[estnet.numHybrids],
        ils=[ils],
        replicateid=[replicateid]
    )
    
    CSV.write(outputfilename, df, append=true)
end

# Parse command-line arguments
outputfilename = ARGS[2]
netabbr = ARGS[3]
ngt = parse(Int64, ARGS[4])
estnetfilename = ARGS[5]
nprocs = parse(Int64, ARGS[6])
ils = ARGS[7]
replicateid = parse(Int64, ARGS[8])

# Process then write data
if whichSNaQ == 1
    processthenwrite(outputfilename, whichSNaQ, netabbr, ngt, estnetfilename, nprocs, ils, replicateid)
else
    # Args unique to SNaQ 2.0
    probQR = parse(Float64, ARGS[9])
    propQuartets = parse(Float64, ARGS[10])
    processthenwrite(outputfilename, whichSNaQ, netabbr, ngt, estnetfilename, nprocs, ils, replicateid, probQR=probQR, propQuartets=propQuartets)
end
