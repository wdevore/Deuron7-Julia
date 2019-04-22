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