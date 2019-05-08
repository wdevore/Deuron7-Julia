mutable struct BaseDelay{T <: Integer}
    shift_reg::T
    time_delay::Int64

    # Input
    stream::AbstractBitStream

    function BaseDelay{T}(stream::AbstractBitStream) where {T <: Unsigned}
        o = new()
        o.shift_reg = 0
        o.time_delay = 0
        o.stream = stream
        o
    end
end

function next!(base::BaseDelay{T}) where {T <: Integer}
    step!(base.stream)
    # Take stream's output shift into the delay position base of T
    base.shift_reg = base.shift_reg | (T(output(base.stream)) << base.time_delay)
end

function shift!(base::BaseDelay{T}) where {T <: Integer}
    # Shift register right
    base.shift_reg = base.shift_reg >> 1
end

# ----------------------------------------------------------------
# Abstract
# ----------------------------------------------------------------
function pre!(delay::AbstractDelay)
    next!(delay.base)
end

function post!(delay::AbstractDelay)
    shift!(delay.base)
end

# ----------------------------------------------------------------
# Tiny
# ----------------------------------------------------------------
# MSB = input bit
# LSB = output bit
#
#  /--- input from stream
# v
# 00000000
#        ^
#         \--- output
mutable struct TinyDelay <: AbstractDelay
    base::BaseDelay{UInt8}

    function TinyDelay(stream::AbstractBitStream, time_delay::Int64 = 0)
        @assert time_delay < 8 "TinyDelay time_delay must be < 8"
        o = new()
        o.base = BaseDelay{UInt8}(stream)
        o.base.time_delay = time_delay
        o
    end
end

function output(delay::TinyDelay)
    # Output is LSB
    delay.base.shift_reg & UInt8(1)
end

# ----------------------------------------------------------------
# Small
# ----------------------------------------------------------------
# Note: if the global time step is 100us then the maximum time_delay
# will be: 100us * 64 = 6400us = 6.4ms
mutable struct SmallDelay <: AbstractDelay
    base::BaseDelay{UInt64}

    function SmallDelay(stream::AbstractBitStream, time_delay::Int64 = 0)
        @assert time_delay < 64 "SmallDelay time_delay must be < 64"
        o = new()
        o.base = BaseDelay{UInt64}(stream)
        o.base.time_delay = time_delay
        o
    end
end

function output(delay::SmallDelay)
    # Output is LSB
    delay.base.shift_reg & UInt64(1)
end


# ----------------------------------------------------------------
# Medium
# ----------------------------------------------------------------
# Note: if the global time step is 100us then the maximum time_delay
# will be: 100us * 128 = 12800us = 12.8ms
mutable struct MediumDelay <: AbstractDelay
    base::BaseDelay{UInt128}

    function MediumDelay(stream::AbstractBitStream, time_delay::Int64 = 0)
        @assert time_delay < 128 "MediumDelay time_delay must be < 128"
        o = new()
        o.base = BaseDelay{UInt128}(stream)
        o.base.time_delay = time_delay
        o
    end
end

function output(delay::MediumDelay)
    # Output is LSB
    delay.base.shift_reg & UInt128(1)
end
