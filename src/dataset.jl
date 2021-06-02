# special cases for datasets that need more rows for proper column type detection
const Dataset_typedetect_rows = Dict{Tuple{String, String}, Union{Vector,Dict}}(
    ("gap", "PD") => [x in [1:15...,17] ? String : Int for x in 1:22],
    ("vcd", "Bundesliga") => [Union{Missing, String}, Union{Missing, String}, Int64, Int64, Int64, Int64, String]
)

function dataset(package_name::AbstractString, dataset_name::AbstractString)
    basename = joinpath(@__DIR__, "..", "data", package_name)

    rdaname = joinpath(basename, string(dataset_name, ".rda"))
    if isfile(rdaname)
        if isdefined(FileIO, :action)
            # FileIO >= 1.6
            return load(File{format"RData"}(rdaname))[dataset_name]
        else
            # FileIO < 1.6
            return load(File(format"RData", rdaname))[dataset_name]
        end
    end

    csvname = joinpath(basename, string(dataset_name, ".csv.gz"))
    if isfile(csvname)
        return open(csvname,"r") do io
            uncompressed = IOBuffer(read(GzipDecompressorStream(io)))
            DataFrame(CSV.File(uncompressed, delim=',', quotechar='\"', missingstring="NA",
                      types=get(Dataset_typedetect_rows, (package_name, dataset_name), nothing)) )
        end
    end
    error("Unable to locate dataset file $rdaname or $csvname")
end
