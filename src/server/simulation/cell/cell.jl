
include("axon.jl")
include("dendrite.jl")
include("soma.jl")

# The Cell is the implementation of a Neuron.
# The cell generates streams of spikes and thus is a bit stream too.
mutable struct Cell <: AbstractBitStream
   # Contains a Soma.
    soma::Soma
   # Interfaces with InterNeurons (IN)
   # Dendrites Compartments also interact with INs

    function Cell(soma::Soma)
        o = new()
        o.soma = soma
        o
    end
end