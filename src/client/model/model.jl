module Model

# Note: be sure to add the JSON package:
# julia> ] add JSON

using JSON

mutable struct ModelData
    data::Dict{AbstractString,Any}
    sim::Dict{AbstractString,Any}

    neuron::Dict{String,Any}
    synapses::Array{Any,1}
    synapse::Dict{String,Any}
    active_synapse::Int64

    # -----------------------------
    # Buffers
    # -----------------------------

    # Neuron parameters
    threshold::String

    function ModelData()
        o = new()

        o.threshold = "\0"^16

        o
    end
end

function load!(model::ModelData, file::String)
    println("Loading: ", file)

    # json = ""
    # lines = readlines(file)
    # for line in lines
    #     # strip any comments out
    #     range = findfirst("//", line)
    #     if range ≠ nothing
    #         line = String(SubString(line, 1:range[1] - 1))
    #     end
    #     json = json * line
    # end

    # json = open(file) do fd
    #     read(fd, String)
    # end

    # data = JSON.parse(json)

    data = JSON.parsefile(file)

    model.data = data;
end

function save(model::ModelData, file::String)
    open(file, "w") do f
        JSON.print(f, model.data, 2)
    end
end

function load_sim!(model::ModelData)
    sim = simulation(model)
    path = data_path(model)
    file = path * sim
    println("Loading: ", file)


    # json = open(file) do fd
    #     read(fd, String)
    # end

    # json = ""
    # lines = readlines(file)
    # for line in lines
    #     # strip any comments out
    #     range = findfirst("//", line)
    #     if range ≠ nothing
    #         line = String(SubString(line, 1:range[1] - 1))
    #     end
    #     json = json * line
    # end

    # data = JSON.parse(json)

    data = JSON.parsefile(file)

    # println(data)

    model.sim = data;

    model.neuron = model.sim["Neuron"]
    model.active_synapse = model.sim["ActiveSynapse"]

    dendrites = model.neuron["Dendrites"]
    compartments = dendrites["Compartments"]
    compartment = compartments[1]
    model.synapses = compartment["Synapses"]
    model.synapse = model.synapses[model.active_synapse]

end

function save_sim(model::ModelData)
    sim = simulation(model)
    path = data_path(model)
    file = path * sim

    open(file, "w") do f
        JSON.print(f, model.sim, 2)
    end
end

# --------------------------------------------------------------
# Application Setter/Getters
# --------------------------------------------------------------
function data_path(model::ModelData)
    string(model.data["DataPath"])
end

function simulation(model::ModelData)
    model.data["Simulation"]
end
function set_simulation!(model::ModelData, v::String)
    model.data["Simulation"] = v
end

# Samples length = Duration (seconds) * 1000000 / Timestep (microseconds)
# Example:
# 2 second duration at 10us steps = 2*1000000/10 = 200000 samples.
# Example:
# 2 second duration at 1ms(1000us) steps = 2*1000000/1000 = 2000 samples.
# Duration length also equal to sample length.
function duration(model::ModelData)
    string(model.data["Duration"])
end
function set_duration!(model::ModelData, v::String)
    model.data["Duration"] = parse(UInt64, v)
end

function range_start(model::ModelData)
    string(model.data["RangeStart"])
end
function set_range_start!(model::ModelData, v::String)
    model.data["RangeStart"] = parse(UInt64, v)
end

function range_end(model::ModelData)
    string(model.data["RangeEnd"])
end
function set_range_end!(model::ModelData, v::String)
    model.data["RangeEnd"] = parse(UInt64, v)
end

# 1 second = 1000ms = 1000000us
#          = 0.001s  = 0.000001s
# 10us = 0.00001s = 10/1000000
# Time step units. Could be 1ms or 100us = 0.1ms or 10us = 0.01ms
# Convert microseconds to seconds: microseconds/1000000
function time_step(model::ModelData)
    string(model.data["TimeStep"])
end
function set_time_step!(model::ModelData, v::String)
    model.data["TimeStep"] = parse(UInt64, v)
end

# --------------------------------------------------------------
# Simulation Setter/Getters
# --------------------------------------------------------------
# Streams
# Firing rate = spikes over an interval of time.
function firing_rate(model::ModelData)
    string(model.sim["Firing_Rate"])
end
function set_firing_rate!(model::ModelData, v::String)
    model.sim["Firing_Rate"] = parse(Float64, v)
end

# If Hertz = 0 then stimulus is distributed as poisson.
# Hertz is = cycles per second (or 1000ms per second)
# 10Hz = 10 applied in 1000ms or every 100ms = 1000/10Hz
# This means a stimulus is generated every 100ms which also means the
# Inter-spike-interval (ISI) is fixed at 100ms
function hertz(model::ModelData)
    string(model.sim["Hertz"])
end
function set_hertz!(model::ModelData, v::String)
    model.sim["Hertz"] = parse(UInt64, v)
end

# Shrinks or expands ISI for stimulus
function stimulus_scaler(model::ModelData)
    string(model.sim["StimulusScaler"])
end
function set_stimulus_scaler!(model::ModelData, v::String)
    model.sim["StimulusScaler"] = parse(UInt64, v)
end

function poisson_pattern_min(model::ModelData)
    string(model.sim["Poisson_Pattern_min"])
end
function set_poisson_pattern_min!(model::ModelData, v::String)
    model.sim["Poisson_Pattern_min"] = parse(UInt64, v)
end

function poisson_pattern_max(model::ModelData)
    string(model.sim["Poisson_Pattern_max"])
end
function set_poisson_pattern_max!(model::ModelData, v::String)
    model.sim["Poisson_Pattern_max"] = parse(UInt64, v)
end

function poisson_pattern_spread(model::ModelData)
    string(model.sim["Poisson_Pattern_spread"])
end
function set_poisson_pattern_spread!(model::ModelData, v::String)
    model.sim["Poisson_Pattern_spread"] = parse(UInt64, v)
end

# --------------------------------------------------------------
# Neuron Setter/Getters
# --------------------------------------------------------------
function active_synapse(model::ModelData)
    string(model.sim["ActiveSynapse"])
end
function set_active_synapse!(model::ModelData, v::String)
    model.sim["ActiveSynapse"] = parse(UInt64, v)
    model.active_synapse = model.sim["ActiveSynapse"]
    model.synapse = model.synapses[model.active_synapse]
end

function refractory_period(model::ModelData)
    neuron = model.sim["Neuron"]
    string(neuron["RefractoryPeriod"])
end
function set_refractory_period!(model::ModelData, v::String)
    model.neuron["RefractoryPeriod"] = parse(Float64, v)
end

function ap_max(model::ModelData)
    string(model.neuron["APMax"])
end
function set_ap_max!(model::ModelData, v::String)
    model.neuron["APMax"] = parse(Float64, v)
end

function threshold(model::ModelData)
    string(model.neuron["Threshold"])
end
function set_threshold!(model::ModelData, v::String)
    model.neuron["Threshold"] = parse(Float64, v)
end

function fast_surge(model::ModelData)
    string(model.neuron["nFastSurge"])
end
function set_fast_surge!(model::ModelData, v::String)
    model.neuron["nFastSurge"] = parse(Float64, v)
end

function slow_surge(model::ModelData)
    string(model.neuron["nSlowSurge"])
end
function set_slow_surge!(model::ModelData, v::String)
    model.neuron["nSlowSurge"] = parse(Float64, v)
end

function slow_surge(model::ModelData)
    string(model.neuron["nSlowSurge"])
end
function set_slow_surge!(model::ModelData, v::String)
    model.neuron["nSlowSurge"] = parse(Float64, v)
end

function tao(model::ModelData)
    string(model.neuron["ntao"])
end
function set_tao!(model::ModelData, v::String)
    model.neuron["ntao"] = parse(Float64, v)
end

function tao_j(model::ModelData)
    string(model.neuron["ntaoJ"])
end
function set_tao_j!(model::ModelData, v::String)
    model.neuron["ntaoJ"] = parse(Float64, v)
end

function tao_s(model::ModelData)
    string(model.neuron["ntaoS"])
end
function set_tao_s!(model::ModelData, v::String)
    model.neuron["ntaoS"] = parse(Float64, v)
end

function weight_max(model::ModelData)
    string(model.neuron["wMax"])
end
function set_weight_max!(model::ModelData, v::String)
    model.neuron["wMax"] = parse(Float64, v)
end

function weight_min(model::ModelData)
    string(model.neuron["wMin"])
end
function set_weight_min!(model::ModelData, v::String)
    model.neuron["wMin"] = parse(Float64, v)
end

# --------------------------------------------------------------
# Synapse Setter/Getters
# --------------------------------------------------------------
function id(model::ModelData)
    string(model.synapse["id"])
end
function set_id!(model::ModelData, v::String)
    model.synapse["id"] = parse(Float64, v)
end

function alpha(model::ModelData)
    string(model.synapse["alpha"])
end
function set_alpha!(model::ModelData, v::String)
    model.synapse["alpha"] = parse(Float64, v)
end

function ama(model::ModelData)
    string(model.synapse["ama"])
end
function set_ama!(model::ModelData, v::String)
    model.synapse["ama"] = parse(Float64, v)
end

function amb(model::ModelData)
    string(model.synapse["amb"])
end
function set_amb!(model::ModelData, v::String)
    model.synapse["amb"] = parse(Float64, v)
end

function lambda(model::ModelData)
    string(model.synapse["lambda"])
end
function set_lambda!(model::ModelData, v::String)
    model.synapse["lambda"] = parse(Float64, v)
end

function learning_rate_fast(model::ModelData)
    string(model.synapse["learningRateFast"])
end
function set_learning_rate_fast!(model::ModelData, v::String)
    model.synapse["learningRateFast"] = parse(Float64, v)
end

function learning_rate_slow(model::ModelData)
    string(model.synapse["learningRateSlow"])
end
function set_learning_rate_slow!(model::ModelData, v::String)
    model.synapse["learningRateSlow"] = parse(Float64, v)
end

function mu(model::ModelData)
    string(model.synapse["mu"])
end
function set_mu!(model::ModelData, v::String)
    model.synapse["mu"] = parse(Float64, v)
end

function taoI(model::ModelData)
    string(model.synapse["taoI"])
end
function set_taoI!(model::ModelData, v::String)
    model.synapse["taoI"] = parse(Float64, v)
end

function taoN(model::ModelData)
    string(model.synapse["taoN"])
end
function set_taoN!(model::ModelData, v::String)
    model.synapse["taoN"] = parse(Float64, v)
end

function taoP(model::ModelData)
    string(model.synapse["taoP"])
end
function set_taoP!(model::ModelData, v::String)
    model.synapse["taoP"] = parse(Float64, v)
end

# Distance from soma
function distance(model::ModelData)
    string(model.synapse["distance"])
end
function set_distance!(model::ModelData, v::String)
    model.synapse["distance"] = parse(Float64, v)
end

function weight(model::ModelData)
    string(model.synapse["w"])
end
function set_weight!(model::ModelData, v::String)
    model.synapse["w"] = parse(Float64, v)
end

end # Module --------------------------------------------