# ----------------------------------------------------
# Handlers
# Messages can come from either the "Simulation" or the Client.
# If it comes from the sim then we route to the socket for transmission
# to the client.
# If it comes from the client then we route to either the server
# or the sim.
# ----------------------------------------------------
function handle_msg(soc::SockServer, data::Dict{String,Any})
    if data["From"] == "Client" && data["To"] == "Server"
        handle_client_to_server(soc, data)
        return
    end

    if data["From"] == "Server" && data["To"] == "Client"
        println(soc.socket, JSON.json(data))
        return
    end

    if data["From"] == "Simulation" && data["To"] == "Client"
        println(soc.socket, JSON.json(data))
        return
    end
end

function handle_client_to_server(soc::SockServer, data::Dict{String,Any})
    if data["Type"] == "Cmd"
        if data["Data"] == "Shutdown Server"
            # Get protocol
            data = JSON.parsefile("../data/com_protocol_basic.json")

            # Populate
            data["From"] = "Server"
            data["To"] = "Client"
            data["Type"] = "Response"
            data["Data"] = "Shutdown in progress"
            
            # respond back to client
            println(soc.socket, JSON.json(data))
        elseif data["Data"] == "Simulate"
            Simulation.run(soc.chan)
        else
            println("Unknown Cmd: ", data)
        end
    elseif data["Type"] == "Response"
        # Client has acknowledged the shutdown
        soc.running = false
    end
end
