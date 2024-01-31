# ARGS: ${ngt} ${nprocs} ${net_abbr} ${ils} ${replicate} ${output_df} ${probQR} ${propQuartets} ${whichSNaQ}
using CSV, DataFrames

ngt = parse(Int64, ARGS[1])
numprocs = parse(Int64, ARGS[2])
netabbr = ARGS[3]
ils = ARGS[4]
replicate = parse(Int64, ARGS[5])
output_df = ARGS[6]
probQR = parse(Float64, ARGS[7])
propQuartets = parse(Float64, ARGS[8])
whichSNaQ = parse(Int64, ARGS[9])

function already_has_entry(df, ngt, ils, replicate, numprocs, probQR, propQuartets, whichSNaQ)
    if size(df, 1) == 0 return false end
    df = filter(:numgt => ==(ngt), df)
    if size(df, 1) == 0 return false end
    df = filter(:ils => ==(ils), df)
    if size(df, 1) == 0 return false end
    df = filter(:replicateid => ==(replicate), df)
    if size(df, 1) == 0 return false end
    df = filter(:numprocs => ==(numprocs), df)
    if size(df, 1) == 0 return false end
    df = filter(:probQR => ==(probQR), df)
    if size(df, 1) == 0 return false end
    df = filter(:propQuartets => ==(propQuartets), df)
    if size(df, 1) == 0 return false end
    df = filter(:whichSNaQ => ==(whichSNaQ), df)
    if size(df, 1) == 0 return false end
    return true
end

output_df = CSV.read(output_df, DataFrame)
if !already_has_entry(output_df, ngt, ils, replicate, numprocs, probQR, propQuartets, whichSNaQ) exit(0) end
exit(1)