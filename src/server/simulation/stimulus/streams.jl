# Contains all streams in simulation. This way we can step each stream on each pass
# The first design of the simulation only has one cell so the cell output isn't included.

mutable struct Streams
    bit_streams::Array{AbstractBitStream,1}
    stim_streams::Array{AbstractBitStream,1}

    id::Int64

    function Streams()
        o = new()
        o.id = 1
        o
    end
end

function id(stream::AbstractBitStream)
    stream.base.id
end

function add_stream!(streams::Streams, stream::AbstractBitStream)
    push!(streams.bit_streams, stream)

    # id is used to align to synapses. "id" can be thought of as
    # synapse-id.
    stream.base.id = streams.id

    streams.id += 1
end

function add_stimulus_stream!(streams::Streams, stream::AbstractBitStream)
    push!(streams.stim_streams, stream)

    # id is used to align to synapses. "id" can be thought of as
    # synapse-id.
    stream.base.id = streams.id

    streams.id += 1
end

const SEED_SCALER = 10000.0
# For debugging or learning we usually want a known sequence.
const RESET_SEED = 13163

function config_streams!(streams::Streams)
    streams.bit_streams =  Array{AbstractBitStream,1}()
    streams.stim_streams =  Array{AbstractBitStream,1}()
end

function config_poi_streams!(streams::Streams, synapses::Int64, firing_rate::Float64)
    Random.seed!(RESET_SEED)

    # Create a stream for each synapse
    for syn in 1:synapses
        seed = Int64(round(rand(1)[1] * SEED_SCALER))

        stream = Simulation.PoissonStream(UInt64(seed), firing_rate)

        add_stream!(streams, stream)
    end
end

function config_stimulus_streams!(streams::Streams, model::Model.ModelData)
    # Load stimulus pattern
    path = Model.data_path(model)

    # source file.
    file = path * Model.source_stimulus(model) * ".data"
    println("Loading stimulus: ", file)

    stream = Simulation.RegularPatternStream()
    add_stimulus_stream!(streams, stream)

    frequency = Model.frequency(model)

    open(file, "r") do f
        pattern = readlines(f)
        
        pattern_length = length(pattern[1])
        syn_lanes = length(pattern[:, 1])
        println("pattern_length: ", pattern_length)
        println("syn_lanes: ", syn_lanes)

        stimulus = zeros(UInt8, syn_lanes, pattern_length)

        row = 1
        for syn_pattern in pattern
            col = 1
            # Format:
            # ..|..|.....|      <-- for each row in file.
            for c in syn_pattern
                if c == '|'
                    stimulus[row, col] = UInt8(1)
                end
                col += 1
            end
            row += 1
        end

        Simulation.config_stream!(stream, stimulus, frequency)
    end
end

function exercise!(streams::Streams)
    # Prior to integration all streams need to be exercised.
    # This causes any internal state to move through their
    # respective activites.
    for stream in streams.bit_streams
        # Note "stream" could be a Poisson or StreamMerger stream.
        # Almost always is a StreamMerger.
        step!(stream)
    end

    for stream in streams.stim_streams
        step!(stream)
    end
end

function collect!(streams::Streams, samples::Samples, t::Int64)
    # Iterate all streams and collect data from stream outputs.

    for stream in streams.bit_streams
        store_poi_sample!(samples, id(stream), t, output(stream))
    end

    # Interate through each stimulus stream and store the current output
    # into the samples collection.
    for stream in streams.stim_streams
        # Pattern streams have multiple internal streams, one for each target synapse.
        for syn_id in 1:stream.synapses
            store_stimulus_sample!(samples, syn_id, t, output(stream, syn_id))
        end
    end
end

