# Note:
# Another Possible poisson generator:
# https://github.com/JuliaStats/Distributions.jl/blob/master/src/univariate/discrete/poisson.jl

# Note on randjump():
# https://www.juliabloggers.com/basics-of-generating-random-numbers-in-julia/

using Random
using Future

# The output of the stream can connect 1 or more Connections.
mutable struct PoissonStream <: AbstractBitStream
    base::BaseData{UInt8}
    seed::Int64

    # The Interspike interval (ISI) counter is populated by a value.
    # When the counter reaches 0 a spike is placed on the output
    # for single pass.
    isi::UInt64

    # This equal to lamba rates.
    firing_rate::Float64
    
    rng::MersenneTwister

    function PoissonStream(seed::UInt64, firing_rate::Float64 = 0.002)
        o = new()
        o.base = BaseData{UInt8}()
        o.firing_rate = firing_rate
        o.seed = seed
        o.isi = 0
        reset!(o)
        step!(o)
        o
    end
end

# Create an event per interval of time, for example, spikes in a 1 sec span.
# A firing rate given in rate/ms, for example, 0.2 in 1ms (0.2/1)
# or 200 in 1sec (200/1000ms)
function next!(stream::PoissonStream) 
    p = -log(1.0 - rand(stream.rng, 1)[1]) / stream.firing_rate
    UInt64(round(p))
end

function reset!(stream::PoissonStream)
    stream.rng = Future.randjump(MersenneTwister(stream.seed), big(10)^20)
    stream.isi = next!(stream)
end

function step!(stream::PoissonStream)
    # Check ISI counter
   	if stream.isi == 0
	    # Time to generate a spike
        stream.base.output = 1
        stream.isi = next!(stream)
    else
        stream.base.output = 0
        stream.isi -= 1
    end
end

function output(stream::PoissonStream)
    stream.base.output & 0x01
end

function output(stream::PoissonStream, id::Int64)
    stream.base.output & 0x01
end