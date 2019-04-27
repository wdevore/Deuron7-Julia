module Comm

using Sockets
using JSON

export send

const PORT = 2001

mutable struct SocClient
    socket::TCPSocket
    chan::Channel{String}

    function SocClient()
        o = new()

        try
            o.socket = connect(PORT)
            o.chan = Channel{String}(10)
        catch ex
            return nothing
        end

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
        json = take!(soc.chan)
        # println("Msg from Channel: ", json)

        if json ≠ ""
            data = JSON.parse(json)

            handle_msg(soc, data)
        end
    else
        # The **Socket Task** above needs time to run so we yield.
        yield()
        # No need to sleep because this function is called in the Gui loop
    end
end

function send(soc::SocClient, data::Dict{String,Any})
    # Put on channel for task to take!
    chan_msg = JSON.json(data)
    put!(soc.chan, chan_msg)
    # println("Put on channel: ", chan_msg)
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

if soc_client ≠ nothing
    println("Connected to server.")

    Comm.listen(soc_client)
else
    println("#######################################################")
    println("WARNING! Failed to connect to server.")
    println("Start server from server folder before running client.")
    println("#######################################################")
end

