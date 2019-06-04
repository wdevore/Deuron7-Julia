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
        if isopen(soc.socket)
            println(soc.socket, JSON.json(data))
        else
            println("Server-to-Client must have shutdown. Can't send.")
        end
        return
    end

    if data["From"] == "Simulation" && data["To"] == "Client"
        if isopen(soc.socket)
            println(soc.socket, JSON.json(data))
        else
            println("Simulation-to-Client must have shutdown. Can't send.")
        end
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
            if isopen(soc.socket)
                println(soc.socket, JSON.json(data))
            else
                println("Client-to-Server must have shutdown. Can't send.")
            end
        elseif data["Data"] == "Simulate"
            # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # --------------- Main entry into simulation -------------
            # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            # Simulation.run(soc.chan, data["Data1"])

            # This version is used during development.
            Simulation.run_debug(soc.chan, data["Data1"])
        elseif data["Data"] == "Re-Simulate"
            # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # --------------- Secondary entry into simulation -------------
            # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            # Simulation.re_run(soc.chan, data["Data1"])

            # This version is used during development.
            Simulation.re_run_debug(soc.chan, data["Data1"])
        else
            println("Unknown Cmd: ", data)
        end
    elseif data["Type"] == "Response"
        # Client has acknowledged the shutdown
        soc.running = false
    end
end
