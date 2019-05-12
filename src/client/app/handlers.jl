# ----------------------------------------------------
# Handlers for the client.
# ----------------------------------------------------
function handle_msg(data::Dict{String,Any})
    if data["From"] == "Client" && data["To"] == "Server"
        return handle_client_to_server(data)
    end

    if data["From"] == "Server" && data["To"] == "Client"
        return handle_server_to_client(data)
    end

    if data["From"] == "Simulation" && data["To"] == "Client"
        return handle_simulation_to_client(data)
    end

    nothing
end

function handle_client_to_server(data::Dict{String,Any})
    return data
end

function handle_server_to_client(data::Dict{String,Any})
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
            return data
        elseif data["Data"] == "Simulation Complete"
            println("Server finished simulation")
        end
    end

    nothing
end

# Handles message arriving from the simulation--running on the server.
function handle_simulation_to_client(data::Dict{String,Any})
    if data["Type"] == "Response"
        if data["Data"] == "Simulation Complete"
            println("Server finished simulation")
        end
    elseif data["Type"] == "Status"
        if data["Data"] == "Span Completed"
            if data["Data1"] == "Poisson Samples"
                # Read span into Samples
                span = data["Data3"]
                Model.read_poi_samples(app_data.samples, app_data.model, span) 
            end
        end
    end

    nothing
end

