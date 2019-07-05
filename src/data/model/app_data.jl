mutable struct AppData

    model::ModelData

    basic_protocol::Dict{String,Any}

    # Samples holds all the sampled data in the sim or app.
    samples::Samples

    configured::Bool

    function AppData()
        o = new()

        o.model = ModelData()

        o.basic_protocol = JSON.parsefile("../data/com_protocol_basic.json")
        o.samples = Samples()
        o.configured = false
        o
    end
end

function config!(data::AppData)
    synapses = Model.synapses(data.model)
    duration = Model.duration(data.model)

    config_samples!(data.samples, synapses, duration)
    data.configured = true
end

function samples(data::AppData)
    data.samples
end

function load_data!(data::AppData)
    load!(data.model, "../data/app.json")
end

function save_data(data::AppData)
    Model.unload(data.model)
end