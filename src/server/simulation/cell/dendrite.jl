mutable struct Dendrite <: AbstractDendrite
    model::Model.ModelData
    soma::AbstractSoma

    # These fields are not used yet.
    taoEff::Float64
    length::Float64

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

    for compartment in dendrite.compartments
        initialize!(compartment)
    end
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
