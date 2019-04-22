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