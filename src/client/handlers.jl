# ----------------------------------------------------
# Message for the client.
# ----------------------------------------------------
function handle_msg(soc::SocClient, data::Dict{String,Any})
    if data["From"] == "Client" && data["To"] == "Server"
        handle_client_to_server(soc, data)
        return
    end

    if data["From"] == "Server" && data["To"] == "Client"
        handle_server_to_client(soc, data)
        return
    end

    if data["From"] == "Simulation" && data["To"] == "Client"
        handle_simulation_to_client(soc, data)
        return
    end
end

function handle_client_to_server(soc::SocClient, data::Dict{String,Any})
    println(soc.socket, JSON.json(data))
end

function handle_server_to_client(soc::SocClient, data::Dict{String,Any})
    if data["Type"] == "Cmd"
    elseif data["Type"] == "Response"
        if data["Data"] == "Shutdown in progress"
            println("***Server is shutting down***")

            data = JSON.parsefile("../data/com_protocol_basic.json")

            # Populate
            data["From"] = "Client"
            data["To"] = "Server"
            data["Type"] = "Response"
            data["Data"] = "Shutdown Accepted"
        
            # respond back to server
            println(soc.socket, JSON.json(data))
        elseif data["Data"] == "Simulation Complete"
            println("Server finished simulation")
        end
    end
end

function handle_simulation_to_client(soc::SocClient, data::Dict{String,Any})
    if data["Type"] == "Response"
        if data["Data"] == "Simulation Complete"
            println("Server finished simulation")
        end
    end
end

