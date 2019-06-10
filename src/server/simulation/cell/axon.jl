# An axon takes an input from the soma and routes it to a destination without delay.
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
        o.len = 0.0
        o
    end
end

function set!(axon::DirectAxon, v::UInt8)
    axon.base.input = v
    axon.base.output = v
end

function input(axon::DirectAxon)
    axon.base.input
end

function output(axon::DirectAxon)
    axon.base.output
end

function reset!(axon::DirectAxon)
    axon.base.input = 0
    axon.base.output = 0
end

function step!(axon::DirectAxon)
    # Instantanious traversal down axon.
    axon.base.output = axon.base.input
end

