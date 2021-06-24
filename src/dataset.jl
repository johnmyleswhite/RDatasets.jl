# special cases for datasets that need more rows for proper column type detection
const Dataset_typedetect_rows = Dict{Tuple{String, String}, Union{Vector,Dict}}(
    ("gap", "PD") => [x in [1:15...,17] ? String : Int for x in 1:22],
    ("vcd", "Bundesliga") => [Union{Missing, String}, Union{Missing, String}, Int64, Int64, Int64, Int64, String]
)

function dataset(package_name::AbstractString, dataset_name::AbstractString)
    basename = joinpath(@__DIR__, "..", "data", package_name)

    rdaname = joinpath(basename, string(dataset_name, ".rda"))
    if isfile(rdaname)
        return load(rdaname)[dataset_name]
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

struct RDatasetsDescription
    content::String
end
function description(package_name::AbstractString, dataset_name::AbstractString)
    RDatasetsDescription(read(joinpath(@__DIR__, "..", "doc",
                                       package_name, "$dataset_name.html"), String))
end
function Base.show(io::IO, mime::MIME"text/plain", d::RDatasetsDescription)
    nohtml = replace(d.content, Regex("<[^>]*>") => "")
    s = replace(nohtml, Regex("\n\n+") => "\n\n")
    show(io, mime, Docs.Text(s))
end
function Base.show(io::IO, mime::MIME"text/html", d::RDatasetsDescription)
    show(io, mime, HTML(d.content))
end
