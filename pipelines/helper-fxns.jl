basedir = joinpath(Base.source_dir(), "..")
using PhyloNetworks

function getsimidxs(ngt::Real)
    if ngt == 30
        return 1:30
    elseif ngt == 100
        return 31:130
    elseif ngt == 300
        return 131:430
    elseif ngt == 1000
        return 430:1430
    elseif ngt == 3000
        return 1431:4430
    else
        error("ngt must be in [30, 100, 300, 1000, 3000], got $ngt instead.")
    end
end
gatherestimatedtrees(treefile, ngt) = readMultiTopology(treefile)[getsimidxs(ngt)]
rmsuppress(file::AbstractString) = try rm(file) catch e end
rmsuppress(files::AbstractArray) = [rmsuppress(file) for file in files]

function setupSNaQ(treefile, ngt)
    trees = gatherestimatedtrees(treefile, ngt)

    println("\nReading quartet info...\n")
    tempout = "./pipelines/temp_data/temp_snaq_"*string(abs(rand(Int64)))
    q, t = countquartetsintrees(trees)
    df = readTableCF(writeTableCF(q, t))

    return trees, tempout, df
end

function cleanSNaQ(tempout)
    rmsuppress(tempout*".err")
    rmsuppress(tempout*".log")
    rmsuppress(tempout*".out")
    rmsuppress(tempout*".networks")
end

######################
# Specific to SNaQ 1 #
######################
function parseSNaQ1estargs(ARGS)
    nhybrids = parse(Int64, ARGS[1])
    ngt = parse(Int64, ARGS[2])
    treefile = abspath(ARGS[3])
    output_file = abspath(ARGS[4])
    isfile(treefile) || error("treefile "*string(treefile)*" not found.")

    return nhybrids, ngt, treefile, output_file
end

function verifyargsSNaQ1(ARGS)
    if length(ARGS) != 4
        error("Usage: julia -p<nprocs> -t<nprocs> ./snaq1.0-estimation.jl <nhybrids> <ngt> <treefile> <network output file>")
    end
end

######################
# Specific to SNaQ 2 #
######################
function parseSNaQ2estargs(ARGS)
    nhybrids = parse(Int64, ARGS[1])
    ngt = parse(Int64, ARGS[2])
    treefile = abspath(ARGS[3])
    output_file = abspath(ARGS[4])
    probqr = parse(Float64, ARGS[5])
    propq = parse(Float64, ARGS[6])
    isfile(treefile) || error("treefile "*string(treefile)*" not found.")

    return nhybrids, ngt, treefile, output_file, probqr, probq
end

function verifyargsSNaQ2(ARGS)
    if length(ARGS) != 6
        error("Usage: julia -p<nprocs> -t<nprocs> ./snaq2.0-estimation.jl <nhybrids> <ngt> <treefile> <network output file> <probqr> <propq>")
    end
end

###############################
# Specific to find_seqgen_s 2 #
###############################
function parseargsseqgen(ARGS)
    desired_gtee = parse(Float64, ARGS[1])
    netabbr = ARGS[2]
    ils = ARGS[3]

    return desired_gtee, netabbr, ils
end

#################
# Miscellaneous #
#################
function readnetwithILS(netabbr::AbstractString, ils::AbstractString)
    net = readTopology(joinpath(basedir, "data", netabbr, netabbr*".net"))
    mod = ifelse(ils == "med", 1, ifelse(ils == "high", 2, ifelse(ils == "low", 0.5, -1)))
    mod != -1 || error("ils value $ils not recognized.")
    for edge in net.edge edge.length *= mod end
end

function verifyargs_nettogts(ARGS)
    if length(ARGS) != 2
        println(ARGS)
        error("Usage: julia ./network-to-est-gene-trees.jl <network directory> <ils (low/med/high)>")
    end
end

warnsinglethread() = if Threads.nthreads() == 1 @warn "Only using 1 thread. Run with 'julia -tN network-to-est-gene-trees.jl ...' to use N threads." end

function runseqgen(seqgen_s::AbstractFloat, temp_gtfile::AbstractString, temp_seqfile::AbstractString)
    if Sys.isapple()
        run(pipeline(`software/seq-gen-macos -s$seqgen_s -n1 -f0.3,0.2,0.2,0.3 -mHKY -op -l1000 $temp_gtfile`, stdout=temp_seqfile, stderr=devnull))
    elseif Sys.islinux()
        run(pipeline(`software/seq-gen-linux -s$seqgen_s -n1 -f0.3,0.2,0.2,0.3 -mHKY -op -l1000 $temp_gtfile`, stdout=temp_seqfile, stderr=devnull))
    else
        run(pipeline(`software/seq-gen-windows.exe -s$seqgen_s -n1 -f0.3,0.2,0.2,0.3 -t3.0 -mHKY -op -l1000 $temp_gtfile`, stdout=temp_seqfile, stderr=devnull))
    end
end

function runiqtree(temp_seqfile::AbstractString)
    if Sys.isapple()
        run(pipeline(`software/iqtree-1.6.12-macos -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    elseif Sys.islinux()
        run(pipeline(`software/iqtree-1.6.12-linux -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    else
        run(pipeline(`software/iqtree-1.6.12-windows.exe -quiet -s $temp_seqfile`, stdout=devnull, stderr=devnull))
    end
end

function appendtolockedfile(filename::AbstractString, filelock::ReentrantLock, data::AbstractString)
    lock(filelock)
    open(filename, "a") do f
        write(f, data)
    end
    unlock(filelock)
end

function calc_gtee(true_newick::AbstractString, est_newick::AbstractString)
    gtee_nrf = Pipe()
    run(pipeline(`python3 scripts/compare_two_trees.py -t1 $true_newick -t2 $est_newick`, stdout=gtee_nrf))
    close(gtee_nrf.in)
    return String(read(gtee_nrf))
end

function cleanestgtfiles(temp_gtfile::AbstractString, temp_seqfile::AbstractString)
    rmsuppress(temp_gtfile)
    rmsuppress(temp_seqfile)
    rmsuppress(temp_seqfile*".bionj")
    rmsuppress(temp_seqfile*".ckp.gz")
    rmsuppress(temp_seqfile*".iqtree")
    rmsuppress(temp_seqfile*".log")
    rmsuppress(temp_seqfile*".mldist")
    rmsuppress(temp_seqfile*".model.gz")
    rmsuppress(temp_seqfile*".treefile")
end