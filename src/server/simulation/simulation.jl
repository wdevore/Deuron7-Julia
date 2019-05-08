module Simulation

using Sockets
using JSON

# include("../app/data.jl")
include("stimulus/stimulus.jl")
include("delay.jl")
include("simulate_neuron.jl")
include("run.jl")

end