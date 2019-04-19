# Main application entry point.
# Launch server before launching client.
#
# To run:
# > julia main.jl 127.0.0.1 2001

include("simulation/simulation.jl")

include("socket.jl")

using .Server

soc_server = Server.SockServer()

Server.start(soc_server)

