
include("synapse.jl")
include("compartment.jl")
include("dendrite.jl")
include("axon.jl")
include("soma.jl")

# The Cell is the implementation of a Neuron.
# The cell generates streams of spikes and thus is a bit stream too.
# The stream is written to disc in spans.

mutable struct Cell <: AbstractBitStream
    # Contains a Soma.
    soma::AbstractSoma 
    model::Model.ModelData

    # Interfaces with InterNeurons (IN)
    # Dendrites Compartments also interact with INs

    function Cell(soma::AbstractSoma, model::Model.ModelData)
        o = new()
        o.soma = soma
        o.model = model
        o
    end
end

function initialize!(cell::Cell)
    initialize!(cell.soma)
end

function reset!(cell::Cell)
    reset!(cell.soma)
end