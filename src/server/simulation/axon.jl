# An axon has 1 or 2 inputs:
# a) Just poisson input
# b) Poisson and Stimulus

# ----------------------------------------------------------------
# Direct
# ----------------------------------------------------------------
mutable struct DirectAxon <: AbstractAxon
    output::UInt8 # i.e. input
    len::Integer

    # Inputs
    streams::Array{AbstractBitStream,1}

    function DirectAxon()
        o = new()
        o.output = UInt8(0)
        o.streams = Array{AbstractBitStream,1}[]
        o
    end
end

function add_stream!(axon::AbstractAxon, stream::AbstractBitStream)
    push!(axon.streams, stream)
end

function output(axon::DirectAxon)
    axon.output
end

function pre!(axon::DirectAxon)
    # Combine each stream's output into a single value and
    # send directly to output.
    axon.output = 0

    for stream in axon.streams
        # Make sure stream output is ready
        step!(stream)
        axon.output |= output(stream)
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
mutable struct TinyDelayAxon <: AbstractAxon
    shift_reg::UInt8
    stream::AbstractBitStream

    function MediumDelayAxon(in_stream::AbstractBitStream)
        o = new()
        o.shift_reg = UInt8(0)
        o.stream = in_stream
        o
    end
end

function output(conn::TinyDelayAxon)
    conn.shift_reg & 0x01
end

function pre!(conn::TinyDelayAxon)
    # Take stream's output and place on input of shift register's MSB
    conn.shift_reg = conn.shift_reg | UInt8((output(conn.stream) << 7))
end

function post!(conn::TinyDelayAxon)
    # Shift register right
    conn.shift_reg = conn.shift_reg >> 1
end


# ----------------------------------------------------------------
# Small
# ----------------------------------------------------------------
mutable struct SmallDelayAxon <: AbstractAxon
    shift_reg::UInt64
    stream::AbstractBitStream

    function MediumDelayAxon(in_stream::AbstractBitStream)
        o = new()
        o.shift_reg = UInt64(0)
        o.stream = in_stream
        o
    end
end

function output(conn::SmallDelayAxon)
    conn.shift_reg & 0x00000001
end

function pre!(conn::SmallDelayAxon)
    # Take stream's output and place on input of shift register's MSB
    conn.shift_reg = conn.shift_reg | (output(conn.stream) << 63)
end

function post!(conn::SmallDelayAxon)
    # Shift register right
    conn.shift_reg = conn.shift_reg >> 1
end

# ----------------------------------------------------------------
# Medium
# ----------------------------------------------------------------
mutable struct MediumDelayAxon <: AbstractAxon
    shift_reg::Array{UInt64}
    len::Int64

    stream::AbstractBitStream

    function MediumDelayAxon(in_stream::AbstractBitStream, delay_size::Int64 = 4)
        o = new()
        o.shift_reg = zeros(UInt64, delay_size)
        o.len = delay_size
        o.stream = in_stream
        o
    end
end

function output(conn::MediumDelayAxon)
    conn.shift_reg[conn.len] & 0x00000001
end

function pre!(conn::MediumDelayAxon)
    # Take stream's output and place on input of shift register's MSB
    #
    # MSB                          LSB (output)
    #      Shift direction -->
    #
    # MSB
    # -------- 1
    # -------- 2
    # -------- 3
    # -------- 4   LSB
    #
    conn.shift_reg[1] = output(conn.stream) << 63
end

function post!(conn::MediumDelayAxon)
    # Shift everything from MSB to LSB
    # TODO NOT COMPLETE
    for r in conn.len:2
        conn.shift_reg[r] = conn.shift_reg[r] >> 1
        conn.shift_reg[r] = conn.shift_reg[r] | (conn.shift_reg[r - 1] & 0x00000001)
    end
end

# ----------------------------------------------------------------
# Large
# ----------------------------------------------------------------
