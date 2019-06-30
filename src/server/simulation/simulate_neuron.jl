include("cell/cell.jl")

using .Model

basic_protocol = JSON.parsefile("../data/com_protocol_basic.json")

include("build_neuron.jl")

# A simulation is broken up into Spans. This allows notifications to
# be sent to the client.
# Each Span (aka span_time) equals: Duration where
# a span contains samples from all synapses.
# Duration is specified in microseconds.
#
# |----------------------------- Duration ----------------------------|
# |----- Span -----|----- Span -----|----- Span -----|----- Span -----|

# Total simulation time = Sum of all spans or Spans * Duration

function build_simulation!(model::Model.ModelData, samples::Model.Samples, streams::Streams)
    # Build neuron for simulation.
    
    println("Building neuron model.")
    cell = build(model, samples, streams)

    # Initialize cell just once based on Model data
    initialize!(cell)

    cell
end

# -_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_
# NOTE: simulate() is called from run.jl
# -_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_-_---_
# Once the server is started it builds the components to support the simualtion.
# Simulate does not create anything it simply resets for a simulation run.
function simulate(chan::Channel{String},
    model::Model.ModelData, samples::Model.Samples, streams::Streams,
    cell::Cell)
    println("Configuring simulation...")

    reset!(cell)

    span_time = Model.span_time(model)

    # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
    # Now the simulation starts.
    # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
    spans = Model.spans(model)

    println("### --------- Starting Simulation -------- ###")

    # Run each span
    for span in 1:spans
    
        # "t" is a single time step representing a single TimeScale.
        # If the TimeScale = 100us then if t = 2 then 100us passed
        # and when t = 3 then 200us passed etc.
        for t in 1:span_time  # a single tick of the simulation.
            # This is the core of the simulation.
            integrate!(cell, t)

            # Collecting is centralized in streams.jl for consistency.
            # Collect all data for analysis by client.
            collect!(streams, samples, t)

            # Exercise all stimulus which means all merger streams.
            # This causes each stream to update and move its internal value to its output.
            exercise!(streams)
        end

        # We have finished a span, write it out to disk
        Model.write_samples!(samples, model, span)

        # Notify client that a span completed.
        notify_client_span_completed(chan, span)

        # Yield for channel tasks
        yield()

        # We "reset" the samples for the next span.
        Model.reset_samples!(samples)
    end

    println("### --------- Simulaton Complete -------- ###")
end

function reset!()
end

function notify_client_span_completed(chan::Channel{String}, span::Int64)
    data = basic_protocol
    
    # Populate
    data["From"] = "Simulation"
    data["To"] = "Client"
    data["Type"] = "Status"
    data["Data"] = "Span Completed"
    data["Data1"] = "poi_sample_c$span.data"
    data["Data2"] = span

    put!(chan, JSON.json(data))
end