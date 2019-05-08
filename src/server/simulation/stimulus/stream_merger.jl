mutable struct StreamMerger <: AbstractBitStream
    base::BaseData{UInt8}
    # Inputs
    inputs::Array{AbstractBitStream,1}

    function StreamMerger()
        o = new()

        o.inputs = Array{AbstractBitStream,1}()

        o
    end
end

function add_stream!(merge::StreamMerger, stream::AbstractBitStream)
    push!(merge.inputs, stream)
end

function output(merge::StreamMerger)
    merge.base.output
end

function step!(merge::StreamMerger)
    # Combine each stream's output into a single value and
    # send directly to output.
    merge.base.output = 0

    for stream in merge.streams
        # Make sure stream output is ready
        step!(stream)
        merge.base.output |= output(stream)
    end
end
