# An axon takes an input from the soma and routes it to a destination.
# a) Just poisson input
# b) Poisson and Stimulus

# ----------------------------------------------------------------
# Direct
# ----------------------------------------------------------------
mutable struct DirectAxon <: AbstractAxon
    base::BaseData{UInt8}
    len::Integer

    function DirectAxon()
        o = new()
        o.base = BaseData{UInt8}()
        o
    end
end

function input(axon::DirectAxon)
    axon.base.input
end

function output(axon::DirectAxon)
    axon.base.output
end

function step!(axon::DirectAxon)
    # Instantanious traversal down axon.
    axon.base.output = axon.base.input
end

