mutable struct BaseData{T <: Unsigned}
    id::Int64
    output::T

    function BaseData{T}() where {T <: Unsigned}
        new(0, 0)
    end
end