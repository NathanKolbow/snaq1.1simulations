# Executed using 4 threads.
using PhyloNetworks, PhyloCoalSimulations, SNaQ, Random, CSV, DataFrames, StatsBase
Random.seed!(0)

function generate_random_network(ntaxa::Int, nhybrids::Int)::HybridNetwork
    nhybrids >= 0 || error("nhybrids >= 0")
    ntaxa >= 4 || error("ntaxa >= 4")

    # First, construct a star-tree
    tree = "("
    for j = 1:ntaxa tree *= "t$(j)," end
    tree = tree[1:(length(tree)-1)] * ");"
    tree = readnewick(tree)
    for E in tree.edge E.length = 0.0 end
    net = simulatecoalescent(tree, 1, 1)[1];
    net = readnewicklevel1(writenewick(net));
    nhybrids == 0 && return net

    for attempt = 1:100_000
        newnet = readnewick(writenewick(net))   # faster than deepcopy
        edge_samples = sample(newnet.edge, 2*nhybrids, replace=false)
        edge_pairs = [(edge_samples[i], edge_samples[i+1]) for i = 1:2:length(edge_samples)]
        try
            for (e1, e2) in edge_pairs
                if PhyloNetworks.directionalconflict(getparent(e1), e2, true)
                    PhyloNetworks.addhybridedge!(newnet, e2, e1, true)
                else
                    PhyloNetworks.addhybridedge!(newnet, e1, e2, true)
                end
            end
            if shrink2cycles!(newnet) || shrink3cycles!(newnet) continue end
            if getlevel(newnet) <= 1
                for H in newnet.hybrid
                    r = rand()
                    r = max(r, 1.0-r)
                    getparentedge(H).gamma = r
                    getparentedgeminor(H).gamma = 1.0 - r
                end
                for E in newnet.edge
                    E.length = E.length == -1 ? rand() : E.length
                end
                return newnet
            end
        catch e
            rethrow(e)
        end
    end
    error("Failed to find valid network after 100,000 attempts.")
end

function randomize_parameters!(net::HybridNetwork)
    for E in net.edge
        E.length = 2 * rand()
    end
    for H in net.hybrid
        r = rand()
        r = max(r, 1.0 - r)
        getparentedge(H).gamma = r
        getparentedgeminor(H).gamma = 1.0-r
    end
end

function generate_CF_data(snaqnet::HybridNetwork, ngt::Int)::DataCF
    gts = simulatecoalescent(readnewick(writenewick(snaqnet)), ngt, 1);
    q, t = countquartetsintrees(gts);
    return readtableCF(DataFrame(tablequartetCF(q, t)))
end

local df::DataFrame
if isfile("rt.csv")
    df = CSV.read("rt.csv", DataFrame)
else
    df = DataFrame(snaqV=String[], ntaxa=Int[], nhybrids=Int[], runtime=Float64[], threads=Int[])
end

for _ = 1:100
    for ntaxa = 5:30
        for nhyb in 0:min(3, Int(floor(ntaxa / 3)))
            try
                @info "ntaxa=$(ntaxa), nhyb=$(nhyb)"
                snaqnet = generate_random_network(ntaxa, nhyb)
                dcf = generate_CF_data(snaqnet, 200)
                
                randomize_parameters!(snaqnet)
                rt = @elapsed SNaQ.topologymaxQpseudolik!(snaqnet, dcf)
                @info "Final rt = $(round(rt, digits=2))"
                push!(df, ["v1.0", ntaxa, nhyb, rt, Threads.nthreads()])
                CSV.write("rt.csv", df)
            catch e
                @error "Failed; skipping."
            end
        end
    end
end

