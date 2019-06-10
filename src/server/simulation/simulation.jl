module Simulation

using Sockets
using JSON

include("abstracts.jl")

# Example:
# print_trace(stacktrace(), "run")
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

include("../../data/model/model.jl")
include("stimulus/stimulus.jl")
include("delay.jl")
include("simulate_neuron.jl")
include("run.jl")

end # Simulation --------------------------------------------------