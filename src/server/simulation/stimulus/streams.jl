# Contains all streams in simulation which includes StreamMerger and Cells.
# The first phase of the simulation only has one cell so it isn't included.

mutable struct Streams
    bit_streams::Array{AbstractBitStream,1}

    function Streams()
        o = new()
        o
    end
end

function id(stream::AbstractBitStream)
    stream.base.id
end


function add_stream!(streams::Streams, stream::AbstractBitStream)
    push!(streams.bit_streams, stream)
end

const SEED_SCALER = 10000.0

function config_streams!(streams::Streams, synapses::Int64, firing_rate::Float64)
    streams.bit_streams =  Array{AbstractBitStream,1}()

    # Create and collect a stream for each synapse
    for id in 1:synapses
        seed = Int64(round(rand(1)[1] * SEED_SCALER))

        stream = Simulation.PoissonStream(UInt64(seed), firing_rate)

        # id is used to align to synapses. "id" can be thought of as
        # synapse-id.
        stream.base.id = id

        add_stream!(streams, stream)
    end
end

function exercise!(streams::Streams)
    # Prior to integration all streams need to be exercised.
    # This causes any internal state to move through their
    # respective delays.
    for stream in streams.bit_streams
        # Remember "stream" could be a Poisson or StreamMerger stream.
        # Almost always is a StreamMerger.
        step!(stream)
    end
end

function collect!(streams::Streams, samples::Samples, t::Int64)
    # Iterate all streams and collect data from stream outputs.
    for stream in streams.bit_streams
        store_poi_sample!(samples, id(stream), t, output(stream))
    end

end

