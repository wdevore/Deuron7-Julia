function build_neuron(model::Model.ModelData)
    # A Soma has an Axon for output.
    axon = DirectAxon()

    # A neuron has a Soma
    soma = Soma(axon, model)

    dendrite = Dendrite(soma, model)

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
    synID = 0

    # ------------------------------------------------------
    # Create pattern stream. Note, pattern stream has N sub-streams, one
    # for each synapse.
    pat_stream = Simulation.RegularPatternStream()
    # Load pattern from the src/data folder using an absolute path.
    root_path = Model.app_root_path(model)
    pattern_file_prefix = Model.source_stimulus(model)

    data_file = root_path * "data/" * pattern_file_prefix * ".data"

    # This particular build is using the regular pattern which is presented
    # at fixed intervals as defined by frequency.
    frequency = Model.hertz(model)

    Simulation.load!(pat_stream, data_file, frequency)

    # Start with excititory type synapses first.
    # Each synapse has a StreamMerger feeding into it.
    # The StreamMerger has two streams feeding into it: Poisson and Pattern.
    for syn_id in 1:excite
        synapse = Synapse(soma, dendrite, compartment, model)
        # Note: this ID is used to reference the correct synapstic prorperties
        # from the model during the synapse's initialization.
        synapse.id = synID

        # Create StreamMerger to hold Poisson and Pattern streams.
        merger = Simulation.StreamMerger()
        
        # Attach the stream input to the synapse.
        set_stream!(synapse, merger)

        # REGION ------------------------------------------------------
        # Create poisson stream and add to merger stream.
        # Each poi stream gets a different starter seed.
        seed = Int64(round(rand(1)[1] * 10000.0))
        poi_stream = Simulation.PoissonStream(UInt64(seed), firing_rate)
        Simulation.add_stream!(merger, poi_stream)
        # END-REGION ------------------------------------------------------

        # REGION ------------------------------------------------------
        # Add pattern stream. The synapse's id will select the sub-stream
        Simulation.add_stream!(merger, pat_stream)
        # END-REGION ------------------------------------------------------

        synID += 1
    end
    println("Excititory synapses built.")

    for syn_id in 1:inhibit
        synapse = Synapse(soma, dendrite, compartment, model)
        synapse.id = synID
        set_as_inhibit!(synapse)

        # Create StreamMerger to hold Poisson and Pattern streams.
        merger = Simulation.StreamMerger()

        # Attach the stream input to the synapse.
        set_stream!(synapse, merger)

        # REGION ------------------------------------------------------
        # Create poisson stream and add to merger stream.
        # Each poi stream gets a different starter seed.
        seed = Int64(round(rand(1)[1] * 10000.0))
        poi_stream = Simulation.PoissonStream(UInt64(seed), firing_rate)
        Simulation.add_stream!(merger, poi_stream)
        # END-REGION ------------------------------------------------------

        # REGION ------------------------------------------------------
        # Add pattern stream. The synapse's id will select the sub-stream
        Simulation.add_stream!(merger, pat_stream)
        # END-REGION ------------------------------------------------------

        synID += 1
    end
    println("Inhibitory synapses built.")

    # A neuron is a cell.
    cell = Cell(soma, model)

    cell
end