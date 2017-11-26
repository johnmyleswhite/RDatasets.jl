module RDatasets
    using Reexport, FileIO, CSV, CodecZlib
    @reexport using DataFrames

    export dataset

    include("dataset.jl")
    include("datasets.jl")
    include("packages.jl")

    Base.@deprecate available_datasets RDatasets.datasets
end
