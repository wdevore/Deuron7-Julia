# Pattern streams are typically stimulus streams sourced from a file
# during developement. In practice though, stimulus comes from either
# actual stimulus sources such as images or from INs or other neurons.

# Because they are streams of spikes they are also an AbstractBitStream.

# When patterns are emitted there is gap (aka interval) between patterns.
# The Inter-Pattern-Interval (IPI) can form several ways:
# 1) Randomly with a minimum interval size.
# 2) Regularly based on a frequency (Hz). IPI is implied via the frequency.
# 3) Poisson distributed IPI.

# ----------------------------------------------------------------------
# A frequency based pattern emitter
# ----------------------------------------------------------------------

mutable struct RegularPatternStream <: AbstractBitStream
    base::BaseData{UInt8}

    # Inter-Pattern-Interval (IPI)
    ipi::Int64

    # How often the pattern in presented (in Hertz)
    frequency::Int64

    pattern::Array{UInt8,2}
    pattern_length::Int64
    pattern_index::Int64
    active_synapse::Int64
    synapses::Int64

    count::Int64

    # True = presenting pattern, False = IPI
    presenting_pattern::Bool

    function RegularPatternStream()
        o = new()
        o.base = BaseData{UInt8}()
        o
    end
end

function config_stream!(stream::RegularPatternStream, pattern::Array{UInt8,2}, frequency::Int64)
    stream.pattern = pattern
    stream.frequency = frequency

    stream.pattern_length = length(pattern[1, :])
    stream.synapses = length(pattern[:, 1])

    # frequency = patterns/second or pattern/1000ms
    milliseconds = 1000 # convert to milliseconds
    period = 1 / frequency
    stream.ipi = Int64(round(period * milliseconds)) - stream.pattern_length

    println("-------------------------------")
    println("RegularPatternStream properties:")
    println("period: ", period)
    println("pattern every: ", period * 1000, " ms")
    println("pattern_length: ", stream.pattern_length)
    println("ipi: ", stream.ipi)
    println("-------------------------------")

    reset!(stream)
end

function next!(stream::RegularPatternStream)
    stream.pattern_index += 1
end

function reset!(stream::RegularPatternStream)
    stream.count = stream.pattern_length
    stream.presenting_pattern = true
    stream.pattern_index = 1
    stream.active_synapse = 1
    output(stream)
end

# frequency is specified in Hz, for example if Hz = 10 then the pattern
# is presented every 1/10 of a second or every 100ms. If the TimeScale
# is 100us then presentation can be thought of as 10000us.

# The time layout is as follows:

# |---------- 1 presentation ---------|---------- 2 presentation ---------|...
# |----- Pattern -----|----- IPI -----|----- Pattern -----|----- IPI -----|...

# If the frequency is 10Hz and the pattern length is 30ms then cycle layout
# is as follows:
# |30ms pattern|70ms IPI|30ms pattern|70ms IPI|30ms pattern|70ms IPI|...

# step should be called only once for the pattern and NOT for each synapse.
function step!(stream::RegularPatternStream)
    stream.count -= 1

    # Update pattern_index base on mode.
    if stream.presenting_pattern
        if stream.count <= 0
            # reset counter to IPI
            stream.count = stream.ipi

            stream.presenting_pattern = false
        else
            next!(stream)
        end
    else
        if stream.count <= 0
            # reset counter to Pattern
            stream.count = stream.pattern_length

            # Reset pattern for next presentation.
            stream.pattern_index = 1

            stream.presenting_pattern = true
        end
    end

    nothing
end

# Select synapse-spike stream
function set_synapse!(stream::RegularPatternStream, synapse::Int64)
    stream.active_synapse = synapse
end

function output(stream::RegularPatternStream)
    if stream.presenting_pattern
        stream.base.output = stream.pattern[stream.active_synapse, stream.pattern_index]
    else
        stream.base.output = 0
    end

    stream.base.output
end

function output(stream::RegularPatternStream, synapse::Int64)
    if stream.presenting_pattern
        stream.base.output = stream.pattern[synapse, stream.pattern_index]
    else
        stream.base.output = 0
    end
    
    stream.base.output & 0x01
end

function load!(stream::RegularPatternStream, pattern_file::String, frequency::Int64, stim_scaler::Int64)
    # Example Format:
    # ....|.
    # ...|..
    # |..|..
    # .|....
    # ....|.
    # ....|.
    # |.....
    # .....|
    # ..|...
    # .|....

    open(pattern_file, "r") do f
        patterns = readlines(f)
        
        # Each line is the same length so selecting the first row
        # (aka [1]) is valid
        duration = length(patterns[1])

        # How many synapses or "lanes/channels"
        channels = length(patterns)

        # stimulus = zeros(UInt8, channels, duration)

        # The array size is duration + (duration * stim_scaler)
        # For example, if duration is 10 and stim_scaler is 3 then
        # size of stimulus is 10 + (10*3) = 40
        # stim_scaler thus becomes an expanding factor. For every bit in
        # the pattern we append stim_scaler 0s.
        size = if stim_scaler == 0
            stim_scaler = 1
            # Special case of 0 then duration is unchanged (i.e. reflected)
            duration
        else
            duration + (duration * stim_scaler)
        end

        stimulus = zeros(UInt8, channels, size)

        row = 1
        for pat_samples in patterns
            col = 1
            for c in pat_samples
                if c == '|'
                    stimulus[row, col] = UInt8(1)
                end
                # Move col "past" the expansion positions.
                col += stim_scaler
            end
            row += 1
        end

        config_stream!(stream, stimulus, frequency)
    end
end

function expand(stream::RegularPatternStream, scaler::Int64)
end