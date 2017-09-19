@testset "Datasets validity" begin
    goodname(sym) = ismatch(r"^([_xA-Z]|pH|pK)", string(sym))

    sets = RDatasets.datasets()
    for r in eachrow(sets)
        pkg = convert(String, r[:Package])
        ds = convert(String, r[:Dataset])
        @testset "$pkg::$ds dataset" begin
            recorded_size = (r[:Rows], r[:Columns])
            df = dataset(pkg, ds)

            @test size(df) == recorded_size
            # test there are no bad column names:
            #  - words are 'UpperCamelCase' (acronyms uppercase)
            #  - '_' used only where two acronyms or two numbers would be concatenated
            @test names(df)[.!goodname.(names(df))] == String[]
        end
    end
end
