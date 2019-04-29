mutable struct BaseStream
    id::Int64
    output::UInt64

    function BaseStream()
        new(0, UInt64(0))
    end
end