function build(model::Model.ModelData, samples::Model.Samples, streams::Streams)
    # A Soma has an Axon for output.
    axon = DirectAxon()

    # A neuron has a Soma
    soma = Soma(axon, model, samples)

    # The soma can have 1 or more dendrites of various types
    dendrite = Dendrite(soma, model)

    # The dendrite can have many types of compartments
    compartment = Compartment(soma, dendrite, model)

    # Now create synapses of two types.
    # 80% Excite and 20% Inhibit synapses.
    synapses = Model.synapses(model)

    # What percentage of the synapses are excite types
    percentage_of_excititory = Model.percent_excititory_synapses(model) / 100.0
    percentage_of_inhibitory = 1.0 - percentage_of_excititory

    excite = Int64(round((Float64(synapses) * percentage_of_excititory)))
    inhibit = Int64(round((Float64(synapses) * percentage_of_inhibitory)))
       
    println("Number of excititory synapses: ", excite)
    println("Number of inhibitory synapses: ", inhibit)

    firing_rate = Model.firing_rate(model)

    # Generated ids
    synID = 1

    pat_stream = get_stimulus_stream(streams, 1)

    # ------------------------------------------------------
    # Start with excititory type synapses first.
    # Each synapse has a StreamMerger feeding into it.
    # The StreamMerger has two streams feeding into it: Poisson and Pattern.
    for syn in 1:excite
        synapse = Synapse(soma, dendrite, compartment, model)
        # Note: this ID is used to reference the correct synapstic prorperties
        # from the model during the synapse's initialization.
        synapse.id = synID

        # Create StreamMerger to hold Poisson and Pattern streams.
        merger = Simulation.StreamMerger() # A input to a synapse
        Simulation.add_merger_stream!(streams, merger)
        
        # Attach the stream to the synapse.
        set_stream!(synapse, merger)

        # REGION ------------------------------------------------------
        # Find matching poi stream and add to merger
        poi_stream = get_poisson_stream(streams, synID)

        Simulation.add_stream!(merger, poi_stream)
        # END-REGION ------------------------------------------------------

        # REGION ------------------------------------------------------
        # Add pattern stream again. The synapse's id will select the sub-stream
        Simulation.add_stream!(merger, pat_stream)
        # END-REGION ------------------------------------------------------

        synID += 1
    end
    println("Excititory synapses built.")

    # ------------------------------------------------------
    for syn in 1:inhibit
        synapse = Synapse(soma, dendrite, compartment, model)
        synapse.id = synID
        set_as_inhibit!(synapse)

        # Create StreamMerger to hold Poisson and Pattern streams.
        merger = Simulation.StreamMerger()
        Simulation.add_merger_stream!(streams, merger)

        # Attach the stream to the synapse.
        set_stream!(synapse, merger)

        # REGION ------------------------------------------------------
        # Find matching poi stream and add to merger
        poi_stream = get_poisson_stream(streams, synID)

        Simulation.add_stream!(merger, poi_stream)
        # END-REGION ------------------------------------------------------

        # REGION ------------------------------------------------------
        # Add pattern stream again. The synapse's id will select the sub-stream
        Simulation.add_stream!(merger, pat_stream)
        # END-REGION ------------------------------------------------------

        synID += 1
    end
    println("Inhibitory synapses built.")

    # A neuron is a cell.
    cell = Cell(soma, model, samples)

    cell
end