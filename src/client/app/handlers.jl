using JSON
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
            # The simulation on the server completed a span

            # First check that the sim model has been loaded. We need properties
            # settings from the model to properly perform loading.
            if !Model.is_loaded(app_data.model)
                Model.load_sim!(app_data.model)
                Model.config_samples!(app_data.samples, app_data.model)
            end

            # Read span into Samples for both poisson and stimulus
            span = data["Data2"]
            Model.read_samples(app_data.samples, app_data.model, span) 
        end
    end

    nothing
end

