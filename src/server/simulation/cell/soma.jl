mutable struct Soma
   # Contains Dendrites and Axon
    axon::AbstractAxon

    function Soma(axon::AbstractAxon)
        o = new()
        o.axon = axon
        o
    end
end
