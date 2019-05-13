include("cell/cell.jl")

using .Model

basic_protocol = JSON.parsefile("../data/com_protocol_basic.json")

include("build_neuron.jl")

# A simulation is broken up into Spans.
# Each Span (aka span_time) equals: Duration where
# a span contains samples from all synapses.
# Duration is specified in microseconds.
#
# |----------------------------- Duration ----------------------------|
# |----- Span -----|----- Span -----|----- Span -----|----- Span -----|

# Total simulation time = Sum of all spans or Spans * Duration

function simulate(chan::Channel{String}, model::Model.ModelData)
    println("Configuring simulation...")
    # The samples collected during the simulation.
    samples = Samples()
    streams = Streams()

    # Build neuron for simulation.
    println("Building neuron model.")
    cell = build_neuron(model)

    println("~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-")
    duration = Model.total_simulation_time(model)
    println("Simulation duration: ", duration)

    # Span time is how many samples to capture before saving to disk.
    span_time = Model.span_time(model)
    println("Span time: ", span_time)

    # How many synapses afferent on the dendrite.
    synapses = Model.synapses(model)
    println("Synapses: ", synapses)
    println("~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-")

    firing_rate = Model.firing_rate(model)

    # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
    # Now the simulation starts.
    # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
    spans = Model.spans(model)

    config_streams!(streams, synapses, firing_rate)

    println("### --------- Starting Simulation -------- ###")

    # Run each span
    for span in 1:spans
        # We "reset" the samples for the next span.
        config_samples!(samples, synapses, span_time)
    
        # "t" is a single time step representing a single TimeScale.
        # If the TimeScale = 100us then if t = 1 then 100us passed
        # and when t = 2 then 200us passed etc.
        for t in 1:span_time  # a single tick of the simulation.
            # First we exercise all stimulus.
            # This causes each stream to update and move its internal value to its output.
            exercise!(streams)

            # This is the main algorithm of the simulation.
            # integrate!(cell)

            # Collect all data for analysis by client.
            collect!(streams, samples, t)
        end

        # We have finished a span, write it out to disk
        write_samples!(samples, model, span)

        # Notify client that a span completed.
        notify_client_span_completed(chan, span)

        # sleep(0.1)

        # Yield for channel tasks
        yield()     
    end

    println("### --------- Simulaton Complete -------- ###")
end


function notify_client_span_completed(chan::Channel{String}, span::Int64)
    data = basic_protocol
    
    # Populate
    data["From"] = "Simulation"
    data["To"] = "Client"
    data["Type"] = "Status"
    data["Data"] = "Span Completed"
    data["Data1"] = "Poisson Samples"
    data["Data2"] = "poi_sample_c$span.data"
    data["Data3"] = span

    put!(chan, JSON.json(data))
end