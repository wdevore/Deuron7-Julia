module Model

# Note: be sure to add the JSON package:
# julia> ] add JSON

using JSON

mutable struct ModelData
    json::String
    data::Dict{AbstractString,Any}

    function ModelData()
        o = new()
        o
    end
end

function load(data::ModelData, file::String)
    println("Loading: ", file)
    data.json = open(file) do fd
        read(fd, String)
    end

    data.data = JSON.parse(data.json)

    println(data.data)
end

end # Module --------------------------------------------