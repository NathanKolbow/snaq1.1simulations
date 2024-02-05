# Populate the snaq1.tab file with variables only for the runs that have not been completed yet.
using CSV, DataFrames

outputdir = "/mnt/ws/home/nkolbow/repos/snaq2/data/output/"

function already_has_entry(df, ngt, ils, replicate, numprocs, probQR, propQuartets, whichSNaQ)
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

lineswritten = 0
open("snaq1.tab", "w") do file
    global lineswritten
    for netabbr in ["n10r1", "n10r3", "n20r1", "n20r3"]
        output_df = CSV.read(joinpath(outputdir, netabbr*".csv"), DataFrame)
        for ngt in [300, 1000, 3000]
            for rep in 1:100
                for numprocs in [4, 8, 16]
                    if !already_has_entry(output_df, ngt, "med", rep, numprocs, 0, 1, 1)
                        write(file, "$netabbr,$ngt,$numprocs,med,$rep\n")
                        lineswritten += 1
                    end
                end
            end
        end
    end
end
println("Wrote $lineswritten lines to snaq1.tab")