using .Model

basic_protocol = JSON.parsefile("../data/com_protocol_basic.json")

# Launched from handle_client_to_server() when a message arrives
# from client app.
function run(chan::Channel{String}, simulation::String)
    model = Model.ModelData()    

    Model.load!(model, "../data/app.json")
    Model.load_sim!(model)

    # Async version to used when truly simulating.
    @async begin
        trace = try
            simulate(chan, model)

            data = basic_protocol

            # Populate
            data["From"] = "Simulation"
            data["To"] = "Client"
            data["Type"] = "Response"
            data["Data"] = "Simulation Complete"
    
            put!(chan, JSON.json(data))

            nothing
        catch ex
            println("### Exception ###: ", ex)
            stacktrace(catch_backtrace())
        end

        if trace ≠ nothing
            println(trace)
            println("############################################")
        end
    end
end

# WARNING! Use only for development. The simulation will not run async
# hence the client won't be notified during simulation.
function run_debug(chan::Channel{String}, simulation::String)
    model = Model.ModelData()    

    Model.load!(model, "../data/app.json")
    Model.load_sim!(model)

    println("#####################################")
    println("#### RUNNING DEBUG VARIANT")
    println("#####################################")

    simulate(chan, model)

    @async begin
        data = basic_protocol

            # Populate
        data["From"] = "Simulation"
        data["To"] = "Client"
        data["Type"] = "Response"
        data["Data"] = "Simulation Complete"
    
        put!(chan, JSON.json(data))
    end

end

