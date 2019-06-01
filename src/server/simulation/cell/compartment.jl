mutable struct Compartment <: AbstractCompartment
    soma::AbstractSoma
    dendrite::AbstractDendrite
    model::Model.ModelData

    weight_max::Float64
    weight_divisor::Float64

    # Contains Synapses
    synapses::Array{AbstractSynapse,1}

    function Compartment(soma::AbstractSoma, dendrite::AbstractDendrite, model::Model.ModelData)
        o = new()
        o.model = model
        o.soma = soma
        o.dendrite = dendrite
        o.synapses = Array{AbstractSynapse,1}()
        o
    end
end

function add_synapse!(compartment::Compartment, synapse::AbstractSynapse)
    push!(compartment.synapses, synapse)
end

function initialize!(compartment::Compartment)
	# Set properties based on model. These drive the other properties.
   	soma.weight_max = Model.weight_max(soma.model)
   	soma.weight_divisor = Model.weight_divisor(soma.model)

    for synapse in compartment.synapses
        initialize!(synapse)
    end
end

function reset!(compartment::Compartment)
    for synapse in compartment.synapses
        reset!(synapse)
    end
end
