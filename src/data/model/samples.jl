# -----------------------------------------------------------
# This file is included from model.jl
# -----------------------------------------------------------

# Samples handles both server and client side IO
# The server stores data (aka samples) and the client reads them.

using Printf

# Type alias for Spans.
#  A span is structured as:
#  1 |   ||     |   | |       ||     |
#  2   |   |   | |     ||     |    |
#  3  |    |    |         | |   |     |
#  where "|" = spikes

function config_sample_data!(data::SampleData{T}, length::Int64) where {T <: Number}
    data.samples = Array{T}(undef, length)
    reset_sample_data!(data)
end

function reset_sample_data!(data::SampleData{T}) where {T <: Number}
    fill!(data.samples, 0)
    data.t = 1
    data.min = typemax(Float64)
    data.max = typemin(Float64)
end

function reset_sample_data!(syn_samples::SynapticSamples)
    syn_samples.t = 1
    for syn_id in 1:syn_samples.synapses
        syn_data = syn_samples.data[syn_id]
        fill!(syn_data.samples, 0)
        syn_data.min = typemax(Float64)
        syn_data.max = typemin(Float64)
    end
end

# `length` is the length of a span.
# `synapses` is the number of synapses
function config_samples!(samples::Samples, synapses::Int64, length::Int64)
    samples.synapses = synapses

    samples.poi_samples = zeros(UInt8, synapses, length)
    samples.poi_t = 1

    samples.stimulus_samples = zeros(UInt8, synapses, length)
    samples.stim_t = 1

    config_sample_data!(samples.cell_samples, length)
    config_sample_data!(samples.soma_apFast_samples, length)
    config_sample_data!(samples.soma_apSlow_samples, length)
    config_sample_data!(samples.soma_psp_samples, length)

    samples.syn_weight_samples = SynapticSamples(length)
    reset_samples!(samples.syn_weight_samples, synapses, length)

    samples.syn_surge_samples = SynapticSamples(length)
    reset_samples!(samples.syn_surge_samples, synapses, length)

    samples.syn_psp_samples = SynapticSamples(length)
    reset_samples!(samples.syn_psp_samples, synapses, length)

    samples.syn_input_samples = SynapticSamples(length)
    reset_samples!(samples.syn_input_samples, synapses, length)
end

function reset_samples!(syn_samples::SynapticSamples, synapses::Int64, length::Int64)
    syn_samples.synapses = synapses
    syn_samples.t = 1
    for syn_id in 1:synapses
        sams = SynapticData(length)
        sams.id = syn_id
        syn_samples.data[syn_id] = sams
    end
end

function reset_samples!(samples::Samples)
    fill!(samples.poi_samples, 0)
    samples.poi_t = 1

    fill!(samples.stimulus_samples, 0)
    samples.stim_t = 1

    reset_sample_data!(samples.cell_samples)

    reset_sample_data!(samples.soma_apFast_samples)
    reset_sample_data!(samples.soma_apSlow_samples)
    reset_sample_data!(samples.soma_psp_samples)

    reset_sample_data!(samples.syn_weight_samples)
    reset_sample_data!(samples.syn_surge_samples)
    reset_sample_data!(samples.syn_psp_samples)
    reset_sample_data!(samples.syn_input_samples)
end

# Write out samples (aka the current span) to storage.
function write_samples!(samples::Samples, model::ModelData, span::Int64)
    path = Model.data_output_path(model)
    
    file = path * Model.poisson_files(model) * string(span) * ".data"
    write_samples_out(samples.poi_samples, file, model, samples_writer)

    file = path * Model.output_stimulus_files(model) * string(span) * ".data"
    write_samples_out(samples.stimulus_samples, file, model, samples_writer)

    file = path * Model.output_cell_spikes(model) * string(span) * ".data"
    write_samples_out(samples.cell_samples, file, model, cell_samples_writer)

    file = path * Model.output_soma_apFast(model) * string(span) * ".data"
    write_samples_out(samples.soma_apFast_samples, file, model, float_samples_writer)

    file = path * Model.output_soma_apSlow(model) * string(span) * ".data"
    write_samples_out(samples.soma_apSlow_samples, file, model, float_samples_writer)

    file = path * Model.output_soma_psp(model) * string(span) * ".data"
    write_samples_out(samples.soma_psp_samples, file, model, float_samples_writer)

    file = path * Model.output_synapse_weights(model) * string(span) * ".data"
    write_samples_out(samples.syn_weight_samples, file, model, synapse_writer)

    file = path * Model.output_synapse_surge(model) * string(span) * ".data"
    write_samples_out(samples.syn_surge_samples, file, model, synapse_writer)

    file = path * Model.output_synapse_psp(model) * string(span) * ".data"
    write_samples_out(samples.syn_psp_samples, file, model, synapse_writer)

    file = path * Model.output_synapse_input_spike(model) * string(span) * ".data"
    write_samples_out(samples.syn_input_samples, file, model, synapse_writer)
end

# ---------------------------------------------------------------------------
# Stores
# ---------------------------------------------------------------------------
# Stores are called from streams.jl
function store_stimulus_sample!(samples::Samples, synapseId::Int64, t::Int64, value::UInt8)
    samples.stimulus_samples[synapseId, t] = value
end

function store_poi_sample!(samples::Samples, synapseId::Int64, t::Int64, value::UInt8)
    samples.poi_samples[synapseId, t] = value
end

# The cell's spike output (aka post spike)
function store_cell_sample!(samples::Samples, value::UInt8, t::Int64)
    samples.cell_samples.samples[t] = value
end

function store_apFast_sample!(samples::Samples, value::Float64, t::Int64)
    samples.soma_apFast_samples.samples[t] = value
end

function store_apSlow_sample!(samples::Samples, value::Float64, t::Int64)
    samples.soma_apSlow_samples.samples[t] = value
end

function store_soma_psp_sample!(samples::Samples, value::Float64, t::Int64)
    samples.soma_psp_samples.samples[t] = value
end

function store_syn_weight_sample!(samples::Samples, syn_id::Int64, value::Float64, t::Int64)
    sams = samples.syn_weight_samples.data[syn_id]
    sams.samples[t] = value;
end

function store_syn_surge_sample!(samples::Samples, syn_id::Int64, value::Float64, t::Int64)
    sams = samples.syn_surge_samples.data[syn_id]
    sams.samples[t] = value;
end

function store_syn_psp_sample!(samples::Samples, syn_id::Int64, value::Float64, t::Int64)
    sams = samples.syn_psp_samples.data[syn_id]
    sams.samples[t] = value;
end

function store_syn_input_sample!(samples::Samples, syn_id::Int64, value::Float64, t::Int64)
    sams = samples.syn_input_samples.data[syn_id]
    sams.samples[t] = value;
end

# ---------------------------------------------------------------------------
# Loads and Reads
# ---------------------------------------------------------------------------
function config_samples!(samples::Samples, model::ModelData)
    synapses = Model.synapses(model)
    duration = Model.duration(model)

    config_samples!(samples, synapses, duration)
end

function load_samples(samples::Samples, model::ModelData)
    spans = Model.spans(model)

    config_samples!(samples, model)
    path = Model.data_output_path(model)

    for span in 1:spans
        read_poi_samples(samples, model, span)
        read_stimulus_samples(samples, model, span)

        file = path * Model.output_soma_apFast(model) * string(span) * ".data"
        read_float_samples(samples.soma_apFast_samples, model, file, span)

        file = path * Model.output_soma_apSlow(model) * string(span) * ".data"
        read_float_samples(samples.soma_apSlow_samples, model, file, span)

        file = path * Model.output_cell_spikes(model) * string(span) * ".data"
        read_spike_samples(samples.cell_samples, model, file, span)

        file = path * Model.output_soma_psp(model) * string(span) * ".data"
        read_float_samples(samples.soma_psp_samples, model, file, span)

        file = path * Model.output_synapse_weights(model) * string(span) * ".data"
        read_synaptic_float_samples(samples.syn_weight_samples, model, file, span)

        file = path * Model.output_synapse_surge(model) * string(span) * ".data"
        read_synaptic_float_samples(samples.syn_surge_samples, model, file, span)

        file = path * Model.output_synapse_psp(model) * string(span) * ".data"
        read_synaptic_float_samples(samples.syn_psp_samples, model, file, span)

        file = path * Model.output_synapse_input_spike(model) * string(span) * ".data"
        read_synaptic_float_samples(samples.syn_input_samples, model, file, span)
    end
end

# Called from client/handlers.jl
function read_samples(samples::Samples, model::ModelData, span::Int64)
    # Where to access fresh samples
    path = Model.data_output_path(model)

    read_poi_samples(samples, model, span)
    read_stimulus_samples(samples, model, span)

    file = path * Model.output_soma_apFast(model) * string(span) * ".data"
    read_float_samples(samples.soma_apFast_samples, model, file, span)

    file = path * Model.output_soma_apSlow(model) * string(span) * ".data"
    read_float_samples(samples.soma_apSlow_samples, model, file, span)

    file = path * Model.output_cell_spikes(model) * string(span) * ".data"
    read_spike_samples(samples.cell_samples, model, file, span)

    file = path * Model.output_soma_psp(model) * string(span) * ".data"
    read_float_samples(samples.soma_psp_samples, model, file, span)

    file = path * Model.output_synapse_weights(model) * string(span) * ".data"
    read_synaptic_float_samples(samples.syn_weight_samples, model, file, span)

    file = path * Model.output_synapse_surge(model) * string(span) * ".data"
    read_synaptic_float_samples(samples.syn_surge_samples, model, file, span)

    file = path * Model.output_synapse_psp(model) * string(span) * ".data"
    read_synaptic_float_samples(samples.syn_psp_samples, model, file, span)

    file = path * Model.output_synapse_input_spike(model) * string(span) * ".data"
    read_synaptic_float_samples(samples.syn_input_samples, model, file, span)
end

