module Server

using Sockets
using JSON

using ..Simulation

mutable struct SockServer
    socket::Sockets.TCPSocket
    server::Sockets.TCPServer

    # The channel is a bridge between the socket and the Simulation.
    # For example, a message from the client to the Simulation would flow as:
    #
    # |----- client app --------|    |---- server app----------|
    # client -> channel -> socket -> socket -> channel -> server
    chan::Channel{String}

    running::Bool

    function SockServer()
        o = new()
        o.chan = Channel{String}(10)
        o.running = false
        o
    end
end

include("handlers.jl")

const PORT = 2001

function start(soc::SockServer)
    soc.server = listen(PORT)

    # Start task that scans the socket for incomming JSON messages
    # **Socket Task**
    @async while true
        soc.socket = accept(soc.server)
        open = true

        while open
            open = isopen(soc.socket)
            if open
                data = readline(soc.socket)
                msg = String(data)
                # Immediately send it to the channel
                # println("Server putting msg on chan: ", msg)
                put!(soc.chan, msg)
            else
                println("Socket closed!")
            end
        end
    end

    soc.running = true
    println("Listening on Channel...")

    # This is the server's main task that listens to the channel
    while soc.running
        # println("Taking...")
        if isready(soc.chan)
            json = take!(soc.chan)
            # println("Msg from channel: ", json)

            if json ≠ ""
                data = JSON.parse(json)
    
                handle_msg(soc, data)
            end
        else
            # The **Socket Task** above needs time to run so we yield.
            yield()
            sleep(0.1)
        end
    end

    println("Closing socket")
    Sockets.close(soc.server)

    println("Server is shutdown")
end

end # Module -------------------------------------------

