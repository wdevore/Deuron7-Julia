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

function add_stream!(merger::StreamMerger, stream::AbstractBitStream)
    push!(merger.streams, stream)
end

function output(merger::StreamMerger)
    merger.base.output
end

function step!(merger::StreamMerger)
    # Combine each stream's output into a single value and
    # send directly to output.
    merger.base.output = 0

    for stream in merger.streams
        # Make sure stream output is ready
        step!(stream)

        # Merge streams.
        merger.base.output = merger.base.output | output(stream)
    end
end
