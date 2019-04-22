module Server

using Sockets

using ..Simulation

mutable struct SockServer
    socket::Sockets.TCPSocket
    server::Sockets.TCPServer
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

    while soc.running
        # println("Taking...")
        msg = take!(soc.chan)
        # println("Msg from channel: ", msg)
        
        # Is the message comming from the client or this server (aka self)?
        # Msg format: 
        #   from          type     data
        # Channel|Client::Cmd|Msg::data
        fields = split(msg, "::")

        handled = handle_client(soc, fields)

        if !handled
            handle_channel(soc, fields)
        end

        # Yield so the socket task can get some time to read socket
        yield()
    end

    println("Closing socket")
    Sockets.close(soc.server)

    println("Server is shutdown")
end



end # Module -------------------------------------------

