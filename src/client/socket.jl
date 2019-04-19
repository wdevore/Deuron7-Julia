module Comm

using Sockets

export send

mutable struct SocClient
    socket::TCPSocket
    chan::Channel{String}

    function SocClient()
        o = new()

        o.socket = connect(2001)
        o.chan = Channel{String}(10)

        o
    end

end

# The task dealing with the socket to server
function listen(soc::SocClient)
    println("Starting to listen to socket...")

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

# Called from Gui loop
function read_channel(soc::SocClient)
    # @async begin
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
    end
    # end
end

function send(soc::SocClient, msg::String)
    # Put on channel for task to take!
    put!(soc.chan, msg)
    # println("Put on channel: ", msg)
end

# ----------------------------------------------------
# Server messages
# These are messages that have arrived from the client
# via the socket.
# ----------------------------------------------------
function handle_server(soc::SocClient, fields)
    if fields[1] == "Server"
        handled = handle_server_cmd(soc, fields)

        if !handled
            handle_server_msg(soc, fields)
        end

        return true
    end

    false
end

function handle_server_cmd(soc::SocClient, fields)
    if fields[2] == "Cmd"
        println("Unknown Field[2]: ", fields)
        return true
    end
    
    false
end

function handle_server_msg(soc::SocClient, fields)
    if fields[2] == "Msg"
        if fields[3] == "Shutdown inprogress"
            println("***Server is shutting down***")
            smsg = "Client::Msg::Shutdown accepted"
            # println("Sending to server: ", smsg)
            println(soc.socket, smsg)
        elseif fields[3] == "Simulation complete"
            println("Server finished simulation")
        else
            println("Unknown fields: ", fields)
        end

        return true
    end

    false
end
# ----------------------------------------------------
# Channel messages
# These are message that originate from the server itself
# need to be routed to the socket.
# ----------------------------------------------------
function handle_channel(soc::SocClient, fields)
    if fields[1] == "Channel"  # From ourselves
        if fields[2] == "Cmd"
           # Forward to server
            smsg = "Client::Cmd::" * fields[3]
            # println("Sending to server: ", smsg)
            println(soc.socket, smsg)
            # println("Sent to server")
        end

        return true
    end 
    
    false
end

end # Module ------------------------

using .Comm

println("Connecting to server...")
soc_client = Comm.SocClient()

println("Connected to server.")

Comm.listen(soc_client)
