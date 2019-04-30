# An axon has 1 or 2 inputs:
# a) Just poisson input
# b) Poisson and Stimulus

# ----------------------------------------------------------------
# Direct
# ----------------------------------------------------------------
mutable struct DirectAxon <: AbstractAxon
    base::BaseData{UInt8}
    len::Integer

    # Inputs
    streams::Array{AbstractBitStream,1}

    function DirectAxon()
        o = new()
        o.base = BaseData{UInt8}()
        o.streams = Array{AbstractBitStream,1}()
        o
    end
end

function add_stream!(axon::AbstractAxon, stream::AbstractBitStream)
    push!(axon.streams, stream)
end

function output(axon::DirectAxon)
    axon.base.output
end

function pre!(axon::DirectAxon)
    # Combine each stream's output into a single value and
    # send directly to output.
    axon.base.output = 0

    for stream in axon.streams
        # Make sure stream output is ready
        step!(stream)
        axon.base.output |= output(stream)
    end
end

function post!(axon::DirectAxon)
    # direct Axons have no post step. The input is already at the output.
end

# Delay types:
# Single UInt64
# Array of Integers of different sizes

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
mutable struct TinyDelayAxon <: AbstractAxon
    shift_reg::UInt8
    delay::Int64

    # Inputs
    streams::Array{AbstractBitStream,1}

    function TinyDelayAxon(delay::Int64 = 0)
        @assert delay < 8 "TinyDelayAxon delay must be < 8"
        o = new()
        o.shift_reg = UInt8(0)
        o.delay = delay
        o.streams = Array{AbstractBitStream,1}()
        o
    end
end

function output(axon::TinyDelayAxon)
    # Output is LSB
    axon.shift_reg & UInt8(1)
end

function pre!(axon::TinyDelayAxon)
    # Combine each stream's output into a single value and
    # send directly to output.
    bit = UInt8(0)

    for stream in axon.streams
        step!(stream)
        bit |= UInt8(output(stream))
    end

    # Take stream's output and place on input of shift register's delay bit
    axon.shift_reg = axon.shift_reg | (bit << axon.delay)
end

function post!(axon::TinyDelayAxon)
    # Shift register right
    axon.shift_reg = axon.shift_reg >> 1
end


# ----------------------------------------------------------------
# Small
# ----------------------------------------------------------------
# Note: if the global time step is 100us then the maximum delay
# will be: 100us * 64 = 6400us = 6.4ms
mutable struct SmallDelayAxon <: AbstractAxon
    shift_reg::UInt64
    delay::Int64

    # Inputs
    streams::Array{AbstractBitStream,1}

    function SmallDelayAxon(delay::Int64 = 0)
        @assert delay < 64 "SmallDelayAxon delay must be < 64"
        o = new()
        o.shift_reg = UInt64(0)
        o.delay = delay
        o.streams = Array{AbstractBitStream,1}()
        o
    end
end

function output(axon::SmallDelayAxon)
    # Output is LSB
    axon.shift_reg & UInt64(1)
end

function pre!(axon::SmallDelayAxon)
    # Combine each stream's output into a single value and
    # send directly to output.
    bit = UInt64(0)

    for stream in axon.streams
        step!(stream)
        bit |= UInt64(output(stream))
    end

    # Take stream's output and place on input of shift register's delay bit
    axon.shift_reg = axon.shift_reg | (bit << axon.delay)
end

function post!(axon::SmallDelayAxon)
    # Shift register right
    axon.shift_reg = axon.shift_reg >> 1
end

# ----------------------------------------------------------------
# Medium
# ----------------------------------------------------------------
# Note: if the global time step is 100us then the maximum delay
# will be: 100us * 128 = 12800us = 12.8ms
mutable struct MediumDelayAxon <: AbstractAxon
    shift_reg::UInt128
    delay::Int64

    # Inputs
    streams::Array{AbstractBitStream,1}

    function MediumDelayAxon(delay::Int64 = 0)
        @assert delay < 128 "MediumDelayAxon delay must be < 128"
        o = new()
        o.shift_reg = UInt128(0)
        o.delay = delay
        o.streams = Array{AbstractBitStream,1}()
        o
    end
end

function output(axon::MediumDelayAxon)
    # Output is LSB
    axon.shift_reg & UInt128(1)
end

function pre!(axon::MediumDelayAxon)
    # Combine each stream's output into a single value and
    # send directly to output.
    bit = UInt128(0)

    for stream in axon.streams
        step!(stream)
        bit |= UInt128(output(stream))
    end

    # Take stream's output and place on input of shift register's delay bit
    axon.shift_reg = axon.shift_reg | (bit << axon.delay)
end

function post!(axon::MediumDelayAxon)
    # Shift register right
    axon.shift_reg = axon.shift_reg >> 1
end

# ----------------------------------------------------------------
# Large
# ----------------------------------------------------------------
