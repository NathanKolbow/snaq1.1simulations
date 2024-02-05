# Populate the snaq2-$(netabbr).tab files with variables only for the runs that have not been completed yet.
using CSV, DataFrames

outputdir = "/mnt/ws/home/nkolbow/repos/snaq2/data/output/"

function already_has_entry(df, ngt, ils, replicate, numprocs, probQR, propQuartets, whichSNaQ; printOutput=false)
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

    if printOutput
        println("size(df, 1): $(size(df, 1))")
        println("df[1,:]:\n$(df[1,:])")
    end

    return true
end


for netabbr in ["n10r1", "n10r3", "n20r1", "n20r3"]
    open("snaq2-$(netabbr).tab", "w") do file
        lineswritten = 0
        output_df = CSV.read(joinpath(outputdir, netabbr*".csv"), DataFrame)

        for ngt in [300, 1000, 3000]
            for rep in 1:100
                for numprocs in [4, 8, 16]
                    for probQR in [0, 0.5, 1]
                        for propQuartets in [1, 0.9, 0.7]
                            if !already_has_entry(output_df, ngt, "med", rep, numprocs, probQR, propQuartets, 2)
                                write(file, "$netabbr,$ngt,$numprocs,med,$rep,$probQR,$propQuartets\n")
                                lineswritten += 1
                            end
                        end
                    end
                end
            end
        end

        println("Wrote $(lineswritten) lines to snaq2-$(netabbr).tab")
    end
end