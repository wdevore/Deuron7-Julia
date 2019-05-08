include("../server/simulation/stimulus/stimulus.jl")

function test_generating()
    stream = PoissonStream(UInt64(13163))
    println(next(stream))
    println(next(stream))
    println(next(stream))
    println(next(stream))
end

const TOTAL_SPIKES = 25

function test_stream_reset()
    println("Testing PoissonStream with reset")

    # Create a stream that generates spikes
    stream = PoissonStream(UInt64(13163), 0.2)
    # Capture isi value for testing after a reset
    isi = stream.isi
    # println("isi: ", stream.isi)

    # Create array to capture spike stream for testing after reset
    spikes = []

    # Fill array with output of stream
    for i in 1:TOTAL_SPIKES
        step!(stream)
        push!(spikes, output(stream))
        # println(output(stream))
    end

    # Now reset stream. This should reset the stream back to its begining.
    reset!(stream)

    # They should be the same
    @assert isi == stream.isi "ISI should be equal"

    # println("isi: ", stream.isi)
    # And the spikes should be too.
    for i in 1:TOTAL_SPIKES
        step!(stream)
        @assert output(stream) == spikes[i] "Invalid spike at index: $i"
        # println(output(stream))
    end

    println("Passed")
end

function test_stream()
    println("Testing PoissonStream with no reset")
    stream = PoissonStream(UInt64(13163), 0.2)
    isi = stream.isi
    # println("isi: ", stream.isi)
    spikes = []
    for i in 1:TOTAL_SPIKES
        step!(stream)
        push!(spikes, output(stream))
        # println(output(stream))
    end

    nisi = stream.isi
    @assert isi != nisi "ISI should NOT be equal"
    # println("isi: ", stream.isi)
    atleast_one_ne = false
    for i in 1:TOTAL_SPIKES
        step!(stream)

        if output(stream) != spikes[i] 
            atleast_one_ne = true
            break;
        end
    end
    @assert atleast_one_ne "Atleast one spike should be different"
    println("Passed")
end

function test_stream_two()
    println("Testing two different poisson streams")

    stream = PoissonStream(UInt64(13163), 0.2)
    isi = stream.isi

    spikes = []
    for i in 1:TOTAL_SPIKES
        step!(stream)
        # println(output(stream))
        push!(spikes, output(stream))
    end

    stream2 = PoissonStream(UInt64(11862), 0.2)
    atleast_one_ne = false
    # println("----------")

    for i in 1:TOTAL_SPIKES
        step!(stream2)
        # println(output(stream))
        if output(stream2) != spikes[i] 
            atleast_one_ne = true
            break;
        end
    end
    @assert atleast_one_ne "Atleast one spike should be different between streams"

    println("Passed")
end


test_stream_two()
test_stream()
test_stream_reset()
