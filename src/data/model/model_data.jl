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

    loaded::Bool
    app_data_loaded::Bool
    sim_data_loaded::Bool

    # Neuron parameters
    threshold::String

    bug::Bool

    sim_changed::Bool
    app_changed::Bool

    function ModelData()
        o = new()

        o.threshold = "\0"^16
        o.loaded = false
        o.bug = true
        o.sim_changed = true
        o.app_changed = true
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

    model.data = data
    model.app_data_loaded = true;
end

function save(model::ModelData, file::String)
    open(file, "w") do f
        JSON.print(f, model.data, 2)
    end
end

function is_loaded(model::ModelData)
    model.loaded = model.app_data_loaded && model.sim_data_loaded
    model.loaded
end

function is_app_changed(model::ModelData)
    model.sim_changed
end

function is_sim_changed(model::ModelData)
    model.app_changed
end

function is_changed(model::ModelData)
    is_app_changed(model) || is_sim_changed(model)
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

    model.sim_data_loaded = true;
end

function save_sim(model::ModelData)
    sim = simulation(model)
    path = data_path(model)
    file = path * sim
    println("Saving: ", file)
    open(file, "w") do f
        JSON.print(f, model.sim, 2)
    end
end

# --------------------------------------------------------------
# Field utils
# --------------------------------------------------------------
function prep_field(v, pad::Int64 = 16)
    string(v) * " "^pad
end

function strip_null(v::String)
    range = findfirst("\0", v)
    if range ≠ nothing
        v = String(SubString(v, 1:(range[1] - 1)))
    end
    v
end

# --------------------------------------------------------------
# Calculated Values
# --------------------------------------------------------------
function total_simulation_time(model::ModelData)
    duration = Model.duration(model)
    # span = Model.span_time(model)
    duration #* span
end

# Span is = Duration
function span_time(model::ModelData)
    duration = Model.duration(model)
    spans = Model.spans(model)
    Int64(duration / spans)
end

# --------------------------------------------------------------
# Application Setter/Getters
# --------------------------------------------------------------
function data_path(model::ModelData)
    model.data["DataPath"]
end

function simulation(model::ModelData)
    model.data["Simulation"]
end
function set_simulation!(model::ModelData, v::String)
    model.data["Simulation"] = v
    model.app_changed = true
end

# Duration is how long a Span is in units of time.
# Thus the total simulation time = Duration * Spans
function duration(model::ModelData)
    model.data["Duration"]
end
function set_duration!(model::ModelData, v::String)
    v = strip_null(v)
    model.data["Duration"] = parse(Int64, v)
    model.app_changed = true
end

function range_start(model::ModelData)
    model.data["RangeStart"]
end
function set_range_start!(model::ModelData, v::String)
    v = strip_null(v)
    model.data["RangeStart"] = parse(Int64, v)
    model.app_changed = true
end
function set_range_start!(model::ModelData, v::Int64)
    model.data["RangeStart"] = v
    model.app_changed = true
end

function range_end(model::ModelData)
    model.data["RangeEnd"]
end
function set_range_end!(model::ModelData, v::String)
    v = strip_null(v)
    model.data["RangeEnd"] = parse(Int64, v)
    model.app_changed = true
end
function set_range_end!(model::ModelData, v::Int64)
    model.data["RangeEnd"] = v
    model.app_changed = true
end

function scroll(model::ModelData)
    model.data["Scroll"]
end
function set_scroll!(model::ModelData, v::Float64)
    model.data["Scroll"] = v
    model.app_changed = true
end

function spans(model::ModelData)
    model.data["Spans"]
end
function set_spans!(model::ModelData, v::String)
    v = strip_null(v)
    model.data["Spans"] = parse(Int64, v)
    model.app_changed = true
end

function time_scale(model::ModelData)
    model.data["TimeScale"]
end
function set_time_scale!(model::ModelData, v::String)
    v = strip_null(v)
    set_time_scale!(model, parse(Int64, v))
    model.app_changed = true
end
function set_time_scale!(model::ModelData, v::Int64)
    model.data["TimeScale"] = v
    model.app_changed = true
end

function data_output_path(model::ModelData)
    model.data["DataOutputPath"]
end
function set_data_output_path!(model::ModelData, v::String)
    v = strip_null(v)
    model.data["DataOutputPath"] = v
    model.app_changed = true
end

function poisson_files(model::ModelData)
    model.data["OutputPoissonFiles"]
end
function set_poisson_files!(model::ModelData, v::String)
    v = strip_null(v)
    model.data["OutputPoissonFiles"] = v
    model.app_changed = true
end

function output_stimulus_files(model::ModelData)
    model.data["OutputStimulusFiles"]
end
function set_output_stimulus_files!(model::ModelData, v::String)
    v = strip_null(v)
    model.data["OutputStimulusFiles"] = v
    model.app_changed = true
end

function source_stimulus(model::ModelData)
    model.data["SourceStimulus"]
end
function set_source_stimulus!(model::ModelData, v::String)
    v = strip_null(v)
    model.data["SourceStimulus"] = v
    model.app_changed = true
end

function frequency(model::ModelData)
    model.data["Frequency"]
end
function set_frequency!(model::ModelData, v::Int64)
    model.data["Frequency"] = v
    model.app_changed = true
end


# --------------------------------------------------------------
# Simulation Setter/Getters
# --------------------------------------------------------------
# Streams
# Firing rate = spikes over an interval of time or
# Poisson events per interval of time.
# For example, spikes in a 1 sec span.
# A firing rate in unit/ms, for example, 0.2 in 1ms (0.2/1)
# or 200 in 1sec (200/1000ms)
function firing_rate(model::ModelData)
    model.sim["Firing_Rate"]
end
function set_firing_rate!(model::ModelData, v::String)
    v = strip_null(v)
    set_firing_rate!(model, parse(Float64, v))
    model.sim_changed = true
end
function set_firing_rate!(model::ModelData, v::Float64)
    model.sim["Firing_Rate"] = v
    model.sim_changed = true
end

function synapses(model::ModelData)
    model.sim["Synapses"]
end
function synapses!(model::ModelData, v::String)
    v = strip_null(v)
    model.sim["Synapses"] = parse(Int64, v)
    model.sim_changed = true
end

# If Hertz = 0 then stimulus is distributed as poisson.
# Hertz is = cycles per second (or 1000ms per second)
# 10Hz = 10 applied in 1000ms or every 100ms = 1000/10Hz
# This means a stimulus is generated every 100ms which also means the
# Inter-spike-interval (ISI) is fixed at 100ms
function hertz(model::ModelData)
    model.sim["Hertz"]
end
function set_hertz!(model::ModelData, v::String)
    v = strip_null(v)
    model.sim["Hertz"] = parse(Int64, v)
    model.sim_changed = true
end

# Shrinks or expands ISI for stimulus
function stimulus_scaler(model::ModelData)
    model.sim["StimulusScaler"]
end
function set_stimulus_scaler!(model::ModelData, v::String)
    v = strip_null(v)
    model.sim["StimulusScaler"] = parse(Int64, v)
    model.sim_changed = true
end

function poisson_pattern_min(model::ModelData)
    model.sim["Poisson_Pattern_min"]
end
function set_poisson_pattern_min!(model::ModelData, v::String)
    v = strip_null(v)
    model.sim["Poisson_Pattern_min"] = parse(Int64, v)
    model.sim_changed = true
end

function poisson_pattern_max(model::ModelData)
    model.sim["Poisson_Pattern_max"]
end
function set_poisson_pattern_max!(model::ModelData, v::String)
    v = strip_null(v)
    model.sim["Poisson_Pattern_max"] = parse(Int64, v)
    model.sim_changed = true
end

function poisson_pattern_spread(model::ModelData)
    model.sim["Poisson_Pattern_spread"]
end
function set_poisson_pattern_spread!(model::ModelData, v::String)
    v = strip_null(v)
    model.sim["Poisson_Pattern_spread"] = parse(Int64, v)
    model.sim_changed = true
end

# --------------------------------------------------------------
# Neuron Setter/Getters
# --------------------------------------------------------------
function active_synapse(model::ModelData)
    model.sim["ActiveSynapse"]
end
function set_active_synapse!(model::ModelData, v::String)
    v = strip_null(v)
    model.sim["ActiveSynapse"] = parse(Int64, v)
    model.active_synapse = model.sim["ActiveSynapse"]
    model.synapse = model.synapses[model.active_synapse]
    model.sim_changed = true
end

function refractory_period(model::ModelData)
    neuron = model.sim["Neuron"]
    neuron["RefractoryPeriod"]
end
function set_refractory_period!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["RefractoryPeriod"] = parse(Float64, v)
    model.sim_changed = true
end

function ap_max(model::ModelData)
    model.neuron["APMax"]
end
function set_ap_max!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["APMax"] = parse(Float64, v)
    model.sim_changed = true
end

function threshold(model::ModelData)
    model.neuron["Threshold"]
end
function set_threshold!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["Threshold"] = parse(Float64, v)
    model.sim_changed = true
end

function fast_surge(model::ModelData)
    model.neuron["nFastSurge"]
end
function set_fast_surge!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["nFastSurge"] = parse(Float64, v)
    model.sim_changed = true
end

function slow_surge(model::ModelData)
    model.neuron["nSlowSurge"]
end
function set_slow_surge!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["nSlowSurge"] = parse(Float64, v)
    model.sim_changed = true
end

function slow_surge(model::ModelData)
    model.neuron["nSlowSurge"]
end
function set_slow_surge!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["nSlowSurge"] = parse(Float64, v)
    model.sim_changed = true
end

function tao(model::ModelData)
    model.neuron["ntao"]
end
function set_tao!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["ntao"] = parse(Float64, v)
    model.sim_changed = true
end

function tao_j(model::ModelData)
    model.neuron["ntaoJ"]
end
function set_tao_j!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["ntaoJ"] = parse(Float64, v)
    model.sim_changed = true
end

function tao_s(model::ModelData)
    model.neuron["ntaoS"]
end
function set_tao_s!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["ntaoS"] = parse(Float64, v)
    model.sim_changed = true
end

function weight_max(model::ModelData)
    model.neuron["wMax"]
end
function set_weight_max!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["wMax"] = parse(Float64, v)
    model.sim_changed = true
end

function weight_min(model::ModelData)
    model.neuron["wMin"]
end
function set_weight_min!(model::ModelData, v::String)
    v = strip_null(v)
    model.neuron["wMin"] = parse(Float64, v)
    model.sim_changed = true
end

# --------------------------------------------------------------
# Synapse Setter/Getters
# --------------------------------------------------------------
function id(model::ModelData)
    model.synapse["id"]
end
function set_id!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["id"] = parse(Float64, v)
    model.sim_changed = true
end

function alpha(model::ModelData)
    model.synapse["alpha"]
end
function set_alpha!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["alpha"] = parse(Float64, v)
    model.sim_changed = true
end

function ama(model::ModelData)
    model.synapse["ama"]
end
function set_ama!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["ama"] = parse(Float64, v)
    model.sim_changed = true
end

function amb(model::ModelData)
    model.synapse["amb"]
end
function set_amb!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["amb"] = parse(Float64, v)
    model.sim_changed = true
end

function lambda(model::ModelData)
    model.synapse["lambda"]
end
function set_lambda!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["lambda"] = parse(Float64, v)
    model.sim_changed = true
end

function learning_rate_fast(model::ModelData)
    model.synapse["learningRateFast"]
end
function set_learning_rate_fast!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["learningRateFast"] = parse(Float64, v)
    model.sim_changed = true
end

function learning_rate_slow(model::ModelData)
    model.synapse["learningRateSlow"]
end
function set_learning_rate_slow!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["learningRateSlow"] = parse(Float64, v)
    model.sim_changed = true
end

function mu(model::ModelData)
    model.synapse["mu"]
end
function set_mu!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["mu"] = parse(Float64, v)
    model.sim_changed = true
end

function taoI(model::ModelData)
    model.synapse["taoI"]
end
function set_taoI!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["taoI"] = parse(Float64, v)
    model.sim_changed = true
end

function taoN(model::ModelData)
    model.synapse["taoN"]
end
function set_taoN!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["taoN"] = parse(Float64, v)
    model.sim_changed = true
end

function taoP(model::ModelData)
    model.synapse["taoP"]
end
function set_taoP!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["taoP"] = parse(Float64, v)
    model.sim_changed = true
end

# Distance from soma
function distance(model::ModelData)
    model.synapse["distance"]
end
function set_distance!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["distance"] = parse(Float64, v)
    model.sim_changed = true
end

function weight(model::ModelData)
    model.synapse["w"]
end
function set_weight!(model::ModelData, v::String)
    v = strip_null(v)
    model.synapse["w"] = parse(Float64, v)
    model.sim_changed = true
end