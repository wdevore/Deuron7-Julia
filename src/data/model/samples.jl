# Samples handles both server and client side IO
# The server stores data (aka samples) and the client reads them.

using Printf

# Type alias for Spans.
#  A span is structured as:
#  1 |   ||     |   | |       ||     |
#  2   |   |   | |     ||     |    |
#  3  |    |    |         | |   |     |
#  where "|" = 1s

const SpanArray = Array{UInt8,2}

mutable struct Samples
    # -_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_--
    # Input data
    # -_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_--
    # Holds a single span during simulation. It is written to disk
    # at the end of span simulation then reset for the next span.
    # It is also used by the client to collect all spans
    poi_samples::SpanArray

    stimulus_samples::SpanArray

    cell_samples::Array{UInt8,1}
    soma_apFast_samples::Array{Float64,1}

    # State managment during simulation run and between spans.
    # Start index of each span
    poi_t::Int64
    stim_t::Int64
    cell_t::Int64
    soma_apFast_t::Int64

    function Samples()
        o = new()
        o
    end
end

# `length` is the length of a span.
function config_samples!(samples::Samples, synapses::Int64, length::Int64)
    samples.poi_samples = zeros(UInt8, synapses, length)
    samples.poi_t = 1

    samples.stimulus_samples = zeros(UInt8, synapses, length)
    samples.stim_t = 1
    
    samples.cell_samples = Array{UInt8}(undef, length)
    fill!(samples.cell_samples, 0)
    samples.cell_t = 1

    samples.soma_apFast_samples = Array{Float64}(undef, length)
    fill!(samples.soma_apFast_samples, 0.0)
    samples.soma_apFast_t = 1
end

function reset_samples!(samples::Samples)
    fill!(samples.poi_samples, 0)
    samples.poi_t = 1

    fill!(samples.stimulus_samples, 0)
    samples.stim_t = 1

    fill!(samples.cell_samples, 0)
    samples.cell_t = 1

    fill!(samples.soma_apFast_samples, 0.0)
    samples.soma_apFast_t = 1
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
    write_samples_out(samples.soma_apFast_samples, file, model, soma_apFast_samples_writer)
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

function soma_apFast_samples_writer(samples::Array{Float64,1}, model::ModelData, f::IOStream)
    span_time = Model.span_time(model)

    # Now write each stream/synpase-input
    # Format:
    # float
    # float
    # ...

    # write all spikes (1) and non-spikes (0)
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
    samples.cell_samples[t] = value
end

function store_apFast_sample!(samples::Samples, value::Float64, t::Int64)
    samples.soma_apFast_samples[t] = value
end

# ---------------------------------------------------------------------------
# Loads and Reads
# ---------------------------------------------------------------------------

function load_samples(samples::Samples, model::ModelData)
    spans = Model.spans(model)

    synapses = Model.synapses(model)
    duration = Model.duration(model)

    config_samples!(samples, synapses, duration)

    for span in 1:spans
        read_poi_samples(samples, model, span)
        read_stimulus_samples(samples, model, span)
    end
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

