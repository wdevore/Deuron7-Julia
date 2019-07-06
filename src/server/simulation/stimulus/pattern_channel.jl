# Patterns consists of 2 or more channels. This represents just one of the channels.
mutable struct PatternChannel <: AbstractBitStream
    base::BaseData
    pattern::AbstractBitStream # Could be a RegularPatternStream

    function PatternChannel(pattern::AbstractBitStream, id::Int64)
        o = new()
        o.base = BaseData{UInt8}()
        o.base.id = id
        o.pattern = pattern
        o
    end
end

function output(stream::PatternChannel)
    output(stream.pattern, stream.base.id)
end