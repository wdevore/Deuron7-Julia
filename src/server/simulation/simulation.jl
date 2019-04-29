module Simulation

using Sockets
using JSON

include("stimulus/stimulus.jl")
include("simulate_neuron.jl")
include("axon.jl")

end