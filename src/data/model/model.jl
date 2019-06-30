module Model

# add the "using ..Simulation" if any of the includes below need access
# to any outside objects for example Simulation.AbstractBitStream etc.
using ..Simulation

function print_trace(trace, stop_at::String)
    println("------- trace ---------")
    for tr in trace
        if string(tr.func) == stop_at
            break
        end
        println(tr)
    end
    println("-----------------------")
end

const SpanArray = Array{UInt8,2}

# For 1D Float64/UInt8 array streams.
mutable struct SampleData{T <: Number}
    samples::Array{T,1}
    min::Float64
    max::Float64
    t::Int64

    function SampleData{T}() where {T <: Number}
        o = new()
        o.t = 1
        o
    end
end

mutable struct Samples
    # -_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_--
    # Input data
    # -_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_---_--
    # Holds a single span during simulation. It is written to disk
    # at the end of span simulation then reset for the next span.
    # It is also used by the client to collect all spans
    poi_samples::SpanArray
    stimulus_samples::SpanArray

    # Spikes: ex psp
    cell_samples::SampleData

    soma_apFast_samples::SampleData
    soma_apSlow_samples::SampleData

    # State managment during simulation run and between spans.
    # Start index of each span
    poi_t::Int64
    stim_t::Int64

    function Samples()
        o = new()
        o.cell_samples = SampleData{UInt8}()
        o.soma_apFast_samples = SampleData{Float64}()
        o.soma_apSlow_samples = SampleData{Float64}()
        o
    end
end


include("model_data.jl")
include("sample_writers.jl")
include("sample_readers.jl")
include("samples.jl")
include("app_data.jl")

end # Module --------------------------------------------