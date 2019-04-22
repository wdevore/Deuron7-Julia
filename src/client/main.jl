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

include("socket.jl")
include("app.jl")
