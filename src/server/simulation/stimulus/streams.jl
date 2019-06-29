# Contains all streams in simulation. This way we can step each stream on each pass
# The first design of the simulation only has one cell so the cell output isn't included.
const SEED_SCALER = 10000.0
# For debugging or learning we usually want a known sequence.
const RESET_SEED = 13163

mutable struct Streams
    bit_streams::Array{AbstractBitStream,1}
    stim_streams::Array{AbstractBitStream,1}
    merger_streams::Array{AbstractBitStream,1}

    id::Int64
    stim_ids::Int64

    function Streams()
        o = new()
        o.id = 1
        o.stim_ids = 1
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
    stream.base.id = streams.stim_ids

    streams.stim_ids += 1
end

function add_merger_stream!(streams::Streams, stream::AbstractBitStream)
    push!(streams.merger_streams, stream)
end

function config_streams!(streams::Streams)
    streams.bit_streams = Array{AbstractBitStream,1}()
    streams.stim_streams = Array{AbstractBitStream,1}()
    streams.merger_streams = Array{AbstractBitStream,1}()
end

function config_poi_streams!(streams::Streams, synapses::Int64, firing_rate::Float64)
    Random.seed!(RESET_SEED)

    # Create a stream for each synapse
    for syn_id in 1:synapses
        seed = Int64(round(rand(1)[1] * SEED_SCALER))

        stream = Simulation.PoissonStream(UInt64(seed), firing_rate)
        stream.base.id = syn_id
        add_stream!(streams, stream)
    end
end

function get_poisson_stream(streams::Streams, id::Int64)
    for stream in streams.bit_streams
        if stream.base.id == id
            return stream
        end
    end

    nothing
end

function get_stimulus_stream(streams::Streams, id::Int64)
    for stream in streams.stim_streams
        if stream.base.id == id
            return stream
        end
    end

    nothing
end

function config_stimulus_streams!(streams::Streams, model::Model.ModelData)
    # Load stimulus pattern
    root_path = Model.app_root_path(model)
    pattern_file_prefix = Model.source_stimulus(model)

    data_file = root_path * "data/" * pattern_file_prefix * ".data"

    println("Loading stimulus: ", data_file)

    stream = Simulation.RegularPatternStream()

    add_stimulus_stream!(streams, stream)

    frequency = Model.hertz(model)

    Simulation.load!(stream, data_file, frequency)
end

function exercise!(streams::Streams)
    # After integration all streams need to be exercised.
    # This causes any internal state to move through their
    # respective activites.
    for stream in streams.bit_streams # Typically Poisson
        step!(stream)
    end

    for stream in streams.stim_streams # Typically Pattern
        step!(stream)
    end

    for stream in streams.merger_streams # Typically Mergers
        step!(stream)
    end
end

function collect!(streams::Streams, samples::Model.Samples, t::Int64)
    # Iterate all streams and collect data from stream outputs.

    # These streams are generally poission types
    for stream in streams.bit_streams
        Model.store_poi_sample!(samples, id(stream), t, output(stream))
    end

    # Interate through each stimulus stream and store the current output
    # into the samples collection.
    for stream in streams.stim_streams
        # Pattern streams have multiple internal streams, one for each target synapse.
        for syn_id in 1:stream.synapses
            Model.store_stimulus_sample!(samples, syn_id, t, output(stream, syn_id))
        end
    end
end

function collect!(samples::Model.Samples, cell::AbstractBitStream, t::Int64)
    # Capture the cell's current output spike
    Model.store_cell_sample!(samples, Simulation.output(cell), t)
end

function collect!(samples::Model.Samples, soma::AbstractSoma, t::Int64)
    # Capture soma data
    Model.store_apFast_sample!(samples, soma.apFast, t)

    Model.store_apSlow_sample!(samples, soma.apSlow, t)

    # samples.Sim.NeuronPspSamples.Put(t, psp, n.id, 0)
	# samples.Sim.NeuronAPSlowSamples.Put(t, soma.apSlow, soma.id, 0)

end
