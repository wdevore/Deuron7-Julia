# Main application entry point.
# Launch server before launching client.
#
# To run:
# > julia main.jl 127.0.0.1 2001

include("simulation/simulation.jl")

include("app/socket.jl")

using .Server

soc_server = Server.SockServer()

@async while true
    input = readavailable(stdin)
    if input[1] == 0x71 # "q" == quit
        exit(1)
    end
end


Server.start(soc_server)

