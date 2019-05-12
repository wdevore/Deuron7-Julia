mutable struct AppData

    model::ModelData

    basic_protocol::Dict{String,Any}

    samples::Samples

    function AppData()
        o = new()

        o.model = ModelData()

        o.basic_protocol = JSON.parsefile("../data/com_protocol_basic.json")
        o.samples = Samples()
        config_spans!(o.samples)

        o
    end
end

function samples(data::AppData)
    data.samples
end

function load_data!(data::AppData)
    load!(data.model, "../data/app.json")
end

function save_data(data::AppData)
    save(data.model, "../data/app.json")
end