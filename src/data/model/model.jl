module Model

# add the "using ..Simulation" if any of the includes below need access
# to any outside objects for example Simulation.AbstractBitStream etc.
using ..Simulation

function print_trace(trace, stop_at::String)
    println("------- trace ---------")
    for tr in trace
        if string(tr.func) == stop_at
            break
        end
        println(tr)
    end
    println("-----------------------")
end

include("model_data.jl")
include("samples.jl")
include("app_data.jl")

end # Module --------------------------------------------