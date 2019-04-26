module Comm

using Sockets

export send

const PORT = 2001

mutable struct SocClient
    socket::TCPSocket
    chan::Channel{String}

    function SocClient()
        o = new()

        o.socket = connect(PORT)
        o.chan = Channel{String}(10)

        o
    end

end

# The task dealing with the socket to server com.
function listen(soc::SocClient)
    println("Starting to listen to socket...")

    # **Socket Task**
    @async while true
        if isopen(soc.socket)
            # println("Socket is open. Reading line...")
            data = readline(soc.socket)
            msg = String(data)
            # println("Msg from server socket: ", msg)
            # println("Routing to channel")
            put!(soc.chan, msg)
            # println("Routing done")
        else
            println("Socket closed!")
            break;
        end
    end

    println("Listening...")
end

include("handlers.jl")

# Called from Gui loop
function read_channel(soc::SocClient)
    if isready(soc.chan)
        # println("Taking...")
        msg = take!(soc.chan)
        # println("Msg from Channel: ", msg)

        # Is the message comming from the server or this client?
        # Msg format:
        #   from          type     data
        # Channel|Server::Cmd|Msg::data
        fields = split(msg, "::")

        handled = handle_server(soc, fields)

        if !handled
            handle_channel(soc, fields)
        end
    else
        # The **Socket Task** above needs time to run so we yield.
        yield()
        # No need to sleep because this function is called in the Gui loop
    end
end

function send(soc::SocClient, msg::String)
    # Put on channel for task to take!
    put!(soc.chan, msg)
    # println("Put on channel: ", msg)
end

end # Module ------------------------

using .Comm

println("Connecting to server...")
soc_client = Comm.SocClient()

println("Connected to server.")

Comm.listen(soc_client)
