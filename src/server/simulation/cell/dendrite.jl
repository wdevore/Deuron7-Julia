mutable struct Dendrite <: AbstractDendrite
    model::Model.ModelData
    soma::AbstractSoma

    # These fields are not used yet.
    taoEff::Float64
    length::Float64

    # Minimum value. Typically 0.0
    min_psp::Float64

    # Contains Compartments
    compartments::Array{AbstractCompartment,1}

    function Dendrite(soma::AbstractSoma, model::Model.ModelData)
        o = new()
        o.model = model
        soma.dendrite = o
        o.compartments = Array{AbstractCompartment,1}()
        o.soma = soma
        o
    end
end

function initialize!(dendrite::AbstractDendrite)
    # Set properties based on model. These drive the other properties.
    dendrite.taoEff = Model.tao_eff(dendrite.model)
    dendrite.length = Model.dendrite_length(dendrite.model)
    dendrite.min_psp = Model.dendrite_min_psp(dendrite.model)

    println("___ Dendrite properties ___")
    println("| taoEff: ", dendrite.taoEff)
    println("| length: ", dendrite.length)
    println("| min_psp: ", dendrite.min_psp)
    println("---------------------------")

    for compartment in dendrite.compartments
        initialize!(compartment)
    end
end

function add_compartment!(dendrite::AbstractDendrite, compartment::Compartment)
    push!(dendrite.compartments, compartment)
end

function reset!(dendrite::AbstractDendrite)
    for compartment in dendrite.compartments
        reset!(compartment)
    end
end


function AP_efficacy(dendrite::AbstractDendrite, distance::Float64)
    if distance < dendrite.length 
        return 1.0
    end

    exp(-(dendrite.length - distance) / dendrite.taoEff)
end

function integrate!(dendrite::AbstractDendrite, span_t::Int64, t::Int64)
    psp = 0.0
    
    for compartment in dendrite.compartments
        psp += integrate!(compartment, span_t, t)
    end

    psp = max(psp, dendrite.min_psp)

    psp
end