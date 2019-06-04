using .Model

basic_protocol = JSON.parsefile("../data/com_protocol_basic.json")

const APP_JSON_FILE = "../data/app.json"

# -_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_
# NOTE: These run functions are called from handlers.jl
# -_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_

# Launched from handle_client_to_server() when a message arrives
# from client app.
function run(chan::Channel{String}, simulation::String)
    model = Model.ModelData()    

    Model.load!(model, "../data/app.json")
    Model.load_sim!(model)

    # Async version to used when truly simulating.
    @async begin
        trace = try
            cell = build_simulation!(model)

            simulate(chan, model, cell)
        
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

cell = nothing

# WARNING! Use only for development. The simulation will not run async
# hence the client won't be notified of span completions during simulation.
function run_debug(chan::Channel{String}, simulation::String)
    println("#####################################")
    println("#### RUNNING DEBUG VARIANT")
    println("#####################################")
    model = Model.ModelData()

    Model.load!(model, APP_JSON_FILE)
    Model.load_sim!(model)

    global cell = build_simulation!(model)

    simulate(chan, model, cell)

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

# This is for re running a simulation without creating every
# component from scratch.
# Most notably it performs a reset() instead of a build().
function re_run_debug(chan::Channel{String}, simulation::String)
    println("#####################################")
    println("#### RE - RUNNING DEBUG VARIANT")
    println("#####################################")

    model = Model.ModelData()

    Model.load!(model, APP_JSON_FILE)
    Model.load_sim!(model)

    simulate(chan, model, cell)

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