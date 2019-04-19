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

function start(soc::SockServer)
    soc.server = listen(2001)
    @async while true
        soc.socket = accept(soc.server)
        open = true

        @async while open
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

# ----------------------------------------------------
# Client messages
# These are messages that have arrived from the server
# via the socket.
# ----------------------------------------------------
function handle_client(soc::SockServer, fields::Array{SubString{String},1})
    if fields[1] == "Client"
        handled = handle_client_command(soc, fields)

        if !handled
            handle_client_msg(soc, fields)
        end

        return true
    end

    false
end

function handle_client_command(soc::SockServer, fields::Array{SubString{String},1})
    if fields[2] == "Cmd"
        if fields[3] == "Shutdown server"
            # respond back to client
            smsg = "Server::Msg::Shutdown inprogress"
            # println("Send response to socket: ", smsg)
            println(soc.socket, smsg)
        elseif fields[3] == "Simulate"
            Simulation.simulate(soc.chan)
        else
            println("Unknown Cmd: ", fields)
        end

        return true
    end

    false
end

function handle_client_msg(soc::SockServer, fields::Array{SubString{String},1})
    if fields[2] == "Msg"
        if fields[3] == "Shutdown accepted"
            # Client has acknowledged the shutdown
            soc.running = false
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
function handle_channel(soc::SockServer, fields::Array{SubString{String},1})
    if fields[1] == "Channel"
        handled = handle_channel_command(soc, fields)

        if !handled
            handle_channel_msg(soc, fields)
        end

        return true
    end
    
    false
end

function handle_channel_command(soc::SockServer, fields::Array{SubString{String},1})
    if fields[2] == "Cmd"
        println("Unknown Field[2]: ", fields)

        return true
    end

    false
end

function handle_channel_msg(soc::SockServer, fields::Array{SubString{String},1})
    if fields[2] == "Msg"
        # Forward to client
        smsg = "Server::Msg::" * fields[3]
        # println("Sending to socket: ", smsg)
        println(soc.socket, smsg)

        return true
    end

    false
end

end # Module -------------------------------------------

