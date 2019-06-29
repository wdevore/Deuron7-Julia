# Samples handles both server and client side IO
# The server stores data (aka samples) and the client reads them.

using Printf

# Type alias for Spans.
#  A span is structured as:
#  1 |   ||     |   | |       ||     |
#  2   |   |   | |     ||     |    |
#  3  |    |    |         | |   |     |
#  where "|" = spikes

const SpanArray = Array{UInt8,2}

# For 1D float array streams.
mutable struct SampleData{T <: Number}
    samples::Array{T,1}
    min::Float64
    max::Float64
    t::Int64

    function SampleData{T}() where {T <: Number}
        o = new()
        o.t = 1
        o
    end
end

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

mutable struct Samples
    # -_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_--
    # Input data
    # -_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_--
    # Holds a single span during simulation. It is written to disk
    # at the end of span simulation then reset for the next span.
    # It is also used by the client to collect all spans
    poi_samples::SpanArray

    stimulus_samples::SpanArray

    cell_samples::SampleData
    soma_apFast_samples::SampleData
    soma_apSlow_samples::SampleData

    # State managment during simulation run and between spans.
    # Start index of each span
    poi_t::Int64
    stim_t::Int64

    function Samples()
        o = new()
        o.cell_samples = SampleData{UInt8}()
        o.soma_apFast_samples = SampleData{Float64}()
        o.soma_apSlow_samples = SampleData{Float64}()
        o
    end
end

# `length` is the length of a span.
function config_samples!(samples::Samples, synapses::Int64, length::Int64)
    samples.poi_samples = zeros(UInt8, synapses, length)
    samples.poi_t = 1

    samples.stimulus_samples = zeros(UInt8, synapses, length)
    samples.stim_t = 1

    config_sample_data!(samples.cell_samples, length)
    config_sample_data!(samples.soma_apFast_samples, length)
    config_sample_data!(samples.soma_apSlow_samples, length)
end

function reset_samples!(samples::Samples)
    fill!(samples.poi_samples, 0)
    samples.poi_t = 1

    fill!(samples.stimulus_samples, 0)
    samples.stim_t = 1

    reset_sample_data!(samples.cell_samples)
    reset_sample_data!(samples.soma_apFast_samples)
    reset_sample_data!(samples.soma_apSlow_samples)
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
end

# ---------------------------------------------------------------------------
# Writers
# ---------------------------------------------------------------------------

# Note: the client will read this data for display.
function samples_writer(samples::SpanArray, model::ModelData, f::IOStream)
    synapses = Model.synapses(model)
    span_time = Model.span_time(model)

    # Now write each stream/synpase-input
    # Format:
    # id 1010001011010...::
    for id in 1:synapses
        # Write stream id
        print(f, @sprintf("%03d ", id))

        # write all spikes (1) and non-spikes (0)
        # print("($id) ")
        for t in 1:span_time
            # print(samples.poi_samples[id, t])
            print(f, samples[id, t])
        end

        # Terminate synapse stream with "::" marker
        # println("::")
        println(f, "::")
    end
end

function cell_samples_writer(samples::Array{UInt8,1}, model::ModelData, f::IOStream)
    span_time = Model.span_time(model)

    # Now write each stream/synpase-input
    # Format:
    # 1010001011010...::

    # write all spikes (1) and non-spikes (0)
    for t in 1:span_time
        print(f, samples[t])
    end

    # Terminate synapse stream with "::" marker
    println(f, "::")
end

function float_samples_writer(samples::Array{Float64,1}, model::ModelData, f::IOStream)
    span_time = Model.span_time(model)

    # Format:
    # float
    # float
    # ...

    for t in 1:span_time
        println(f, samples[t])
    end
end

# Write the current samples to disk, then reset.
function write_samples_out(samples::Array, file::String, model::ModelData, writer)
    open(file, "w") do f
        writer(samples, model, f)
    end
end

function write_samples_out(data::SampleData, file::String, model::ModelData, writer)
    open(file, "w") do f
        writer(data.samples, model, f)
    end
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
    end
end

# Called from client/handlers.jl
function read_samples(samples::Samples, model::ModelData, span::Int64)
    read_poi_samples(samples, model, span)
    read_stimulus_samples(samples, model, span)

    # Where to access fresh samples
    path = Model.data_output_path(model)

    file = path * Model.output_soma_apFast(model) * string(span) * ".data"
    read_float_samples(samples.soma_apFast_samples, model, file, span)

    file = path * Model.output_soma_apSlow(model) * string(span) * ".data"
    read_float_samples(samples.soma_apSlow_samples, model, file, span)
end

# Read span and put spikes into poi_samples collection.
function read_poi_samples(samples::Samples, model::ModelData, span::Int64)
    # Where to access fresh samples
    path = Model.data_output_path(model)

    # source file.
    file = path * Model.poisson_files(model) * string(span) * ".data"

    synapses = Model.synapses(model)
    span_time = Model.span_time(model)

    # println("Loading new samples: ", file)

    # Load samples
    idx = 1
    open(file, "r") do f
        syn_samples = readlines(f)
        for syn_sample in syn_samples
            # Format:
            # id 1010001011010...::

            # Parse out "id" field
            idx_range = findfirst(" ", syn_sample)
            id = parse(Int64, SubString(syn_sample, 1, idx_range[1]))
            # print(id, " ")
        
            # EOL marker
            bits_end = findfirst("::", syn_sample)

            # Extract just spike data
            bits = SubString(syn_sample, idx_range[1] + 1, bits_end[1] - 1)

            # load row of spikes into samples
            t = samples.poi_t
            for bit in bits
                samples.poi_samples[idx, t] = parse(UInt8, bit)
                t += 1
            end
            idx += 1
        end
    end
    
    # Prepare for next span my moving "t" to the start of the next span
    # position within the full duration of samples.
    samples.poi_t += span_time
end

function read_stimulus_samples(samples::Samples, model::ModelData, span::Int64)
    # Where to access fresh samples
    path = Model.data_output_path(model)

    # source file.
    file = path * Model.output_stimulus_files(model) * string(span) * ".data"

    synapses = Model.synapses(model)
    span_time = Model.span_time(model)

    # println("Loading new samples: ", file)

    # Load samples
    idx = 1
    open(file, "r") do f
        syn_samples = readlines(f)
        for syn_sample in syn_samples
            # Format:
            # id 1010001011010...::

            # Parse out "id" field
            idx_range = findfirst(" ", syn_sample)
            id = parse(Int64, SubString(syn_sample, 1, idx_range[1]))
            # print(id, " ")
        
            # EOL marker
            bits_end = findfirst("::", syn_sample)

            # Extract just spike data
            bits = SubString(syn_sample, idx_range[1] + 1, bits_end[1] - 1)
            # println(bits)
            # load row of spikes into samples
            t = samples.stim_t
            for bit in bits
                samples.stimulus_samples[idx, t] = parse(UInt8, bit)
                t += 1
            end
            idx += 1
        end
    end
    
    # Prepare for next span my moving "t" to the start of the next span
    # position within the full duration of samples.
    samples.stim_t += span_time
end

function read_float_samples(data_sams::SampleData, model::ModelData, file::String, span::Int64)
    synapses = Model.synapses(model)
    span_time = Model.span_time(model)

    # println("Loading apFast samples: ", file)

    # Load samples
    open(file, "r") do f
        data = readlines(f)
        t = data_sams.t
        for sample in data
            # Format:
            # float
            # float
            # ...
            v = parse(Float64, sample)
            data_sams.min = min(data_sams.min, v)
            data_sams.max = max(data_sams.max, v)

            data_sams.samples[t] = v
            t += 1
        end
    end
    
    # println("min: ", data_sams.min, ", max: ", data_sams.max)
    # Prepare for next span my moving "t" to the start of the next span
    # position within the full duration of samples.
    data_sams.t += span_time
end

# function read_soma_apFast_samples(samples::Samples, model::ModelData, span::Int64)
#     # Where to access fresh samples
#     path = Model.data_output_path(model)

#     # source file.
#     file = path * Model.output_soma_apFast(model) * string(span) * ".data"

#     synapses = Model.synapses(model)
#     span_time = Model.span_time(model)

#     # println("Loading apFast samples: ", file)

#     data_sams = samples.soma_apFast_samples

#     # Load samples
#     open(file, "r") do f
#         data = readlines(f)
#         t = data_sams.t
#         for sample in data
#             # Format:
#             # float
#             # float
#             # ...
#             v = parse(Float64, sample)
#             data_sams.min = min(data_sams.min, v)
#             data_sams.max = max(data_sams.max, v)

#             data_sams.samples[t] = v
#             t += 1
#         end
#     end
    
#     # println("min: ", data_sams.min, ", max: ", data_sams.max)
#     # Prepare for next span my moving "t" to the start of the next span
#     # position within the full duration of samples.
#     data_sams.t += span_time
# end
