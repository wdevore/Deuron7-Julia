module Model

# add the "using ..Simulation" if any of the includes below need access
# to any outside objects for example Simulation.AbstractBitStream etc.
using ..Simulation

include("model_data.jl")
include("samples.jl")
include("app_data.jl")

end # Module --------------------------------------------