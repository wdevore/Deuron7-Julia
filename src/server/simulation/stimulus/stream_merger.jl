# This merger stream is always routed to a single synapse.
mutable struct StreamMerger <: AbstractBitStream
    base::BaseData{UInt8}

    # Inputs
    streams::Array{AbstractBitStream,1}

    function StreamMerger()
        o = new()

        o.streams = Array{AbstractBitStream,1}()
        o.base = BaseData{UInt8}()
        o
    end
end

# Inputs
function add_stream!(merger::StreamMerger, stream::AbstractBitStream)
    push!(merger.streams, stream)
end

function output(merger::StreamMerger)
    merger.base.output
end

function step!(merger::StreamMerger)
    # Combine each stream's output into a single value and send directly to output.
    # Generally the merger holds two or more streams: Poisson and PatternChannel
    merger.base.output = 0
    for stream in merger.streams
        # Merge streams.
        merger.base.output = merger.base.output | output(stream)
    end
end
