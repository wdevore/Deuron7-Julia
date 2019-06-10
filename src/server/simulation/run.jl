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

    # The samples collected during the simulation.
    samples = Model.Samples()

    # config streams so build can bind to them.
    streams = Streams()

    # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
    # Setup and configure the collections that hold sampling data
    # captured during simulation.
    # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
    config_streams!(streams)

    println("~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-")
    duration = Model.total_simulation_time(model)
    println("Simulation duration: ", duration)

    # How many synapses afferent on the dendrite.
    synapses = Model.synapses(model)
    println("Synapses: ", synapses)

    # Span time is how many samples to capture before saving to disk.
    span_time = Model.span_time(model)
    println("Span time: ", span_time)
    
    # Poi streams have a firing rate property
    firing_rate = Model.firing_rate(model)
    println("firing_rate: ", firing_rate)
    println("~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-")
    
    # We "set" the samples for the first span.
    Model.config_samples!(samples, synapses, span_time)

    config_poi_streams!(streams, synapses, firing_rate)

    config_stimulus_streams!(streams, model)
    
    # "cell" is also used during re-run
    global cell = build_simulation!(model, samples, streams)

    simulate(chan, model, samples, streams, cell)

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

# This is for RE running a simulation without creating every
# component from scratch.
function re_run_debug(chan::Channel{String}, simulation::String)
    println("#####################################")
    println("#### RE - RUNNING DEBUG VARIANT")
    println("#####################################")

    model = Model.ModelData()

    Model.load!(model, APP_JSON_FILE)
    Model.load_sim!(model)

    # The samples collected during the simulation.
    samples = Model.Samples()

    simulate(chan, model, samples, cell)

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