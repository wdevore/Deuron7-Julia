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

        add_compartment!(dendrite, o)

        o
    end
end

function add_synapse!(compartment::Compartment, synapse::AbstractSynapse)
    push!(compartment.synapses, synapse)
end

function initialize!(compartment::Compartment)
	# Set properties based on model. These drive the other properties.
    compartment.weight_max = Model.weight_max(compartment.model)
    compartment.weight_divisor = Model.weight_divisor(compartment.model)

    println("___ Compartment properties ___")
    println("| weight_max: ", compartment.weight_max)
    println("| weight_divisor: ", compartment.weight_divisor)
    println("---------------------------")

    for synapse in compartment.synapses
        initialize!(synapse)
    end
end

function reset!(compartment::Compartment)
    for synapse in compartment.synapses
        reset!(synapse)
    end
end

function integrate!(compartment::Compartment, span_t::Int64, t::Int64)
    psp = 0.0

    for synapse in compartment.synapses
        psp += integrate!(synapse, span_t, t)
    end

    psp
end
