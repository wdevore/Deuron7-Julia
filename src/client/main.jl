# This is the GUI client.

# First start the server
# > julia src/server/main.jl
# and then the client
# > julia src/client/main.jl

# The server contains the simulation.


# -------------------------------------------------------------------------
# Dependencies
# -------------------------------------------------------------------------
# add JSON
# add CSyntax
# add CImGui
include("../server/simulation/simulation.jl")

include("../data/model/model.jl")

include("../client/app/handlers.jl")

include("app/socket.jl")

include("app/app.jl")
