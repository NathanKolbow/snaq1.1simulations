using Pkg; Pkg.activate(joinpath(@__DIR__, ".."));
using PhyloNetworks, StatsBase, Plots, CSV, DataFrames, SNaQ



######### First, some functions for the model selection
function ols_regression(X::Matrix, y::Vector)
    X = hcat(ones(size(X, 1)), X)
    β = inv(X' * X) * X' * y
    ŷ = X * β
    residuals = y - ŷ
    return β, ŷ, residuals
end

function get_slope(nretics::Vector{Int}, neg_plls::Vector{Float64})
    X = zeros(length(nretics), 1)
    X .= nretics
    ols_coefs, _, _ = ols_regression(X, neg_plls)
    return ols_coefs
end

function select_model(nretics::Vector{Int}, nplls::Vector{Float64})
    all(nplls .<= 0) || error("All negative log-liks should be <= 0")
    length(nretics) == length(nplls) || error("Supplied $(length(nretics)) retic numbers but $(length(nplls)) -logliks.")

    ols_int, ols_slope = get_slope(nretics, nplls)
    penalized_scores = [.-nplls[i] + ols_slope*(nretics[i]+1) for i = 1:length(nretics)]
    _, _h_star = findmin(penalized_scores)
    return nretics[_h_star], penalized_scores, ols_int, ols_slope
end

function plot_model_selection(h::AbstractVector{Int}, nlls::Vector{Float64})
    for j = 2:length(nlls)
        nlls[j] = max(nlls[j-1], nlls[j])
    end

    best_h, h_scores, _ = select_model(h, nlls)
    p = plot(h, .-nlls, label="Negative Loglik")
    plot!(p, h, h_scores, label="Penalized Scores")
    vline!(p, [best_h], label="Best h", lc=:red, alpha=0.25, linestyle=:dash)
    xlabel!(p, "Number of Hybrids")
    ylabel!(p, "Negative Loglik or Penalized Score")
    return p
end

# Now, for the specific data
df = CSV.read(joinpath(@__DIR__, "..", "empirical-cui", "output-data.csv"), DataFrame);
old_df = filter(r -> r.whichSNaQ == 1, df);
old_nets = readnewick.(r.best_network for r in eachrow(old_df));
for i in eachindex(old_nets)
    loglik!(old_nets[i], filter(r -> r.nhybrids == old_nets[i].numhybrids, old_df).negloglik[1])
end

new_df = filter(r -> r.whichSNaQ == 2, df);
new_nets = readnewick.(r.best_network for r in eachrow(new_df));
for i in eachindex(new_nets)
    loglik!(new_nets[i], filter(r -> r.nhybrids == new_nets[i].numhybrids, new_df).negloglik[1])
end


plot_model_selection(collect(0:5), .-loglik.(old_nets))
plot_model_selection(collect(0:5), .-loglik.(new_nets))