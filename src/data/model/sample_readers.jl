# Read span and put spikes into poi_samples collection.

function read_spike_samples(samples::SampleData{T}, model::ModelData, file::String, span::Int64) where {T <: Number}
    synapses = Model.synapses(model)
    span_time = Model.span_time(model)

    # println("Loading new samples: ", file)

    # Load samples
    idx = 1
    open(file, "r") do f
        syn_samples = readlines(f)
        for syn_sample in syn_samples
            # Format:
            # id 1010001011010...::

            # Parse out "id" field
            idx_range = findfirst(" ", syn_sample)
            id = parse(Int64, SubString(syn_sample, 1, idx_range[1]))
            # print(id, " ")
        
            # EOL marker
            bits_end = findfirst("::", syn_sample)

            # Extract just spike data
            bits = SubString(syn_sample, idx_range[1] + 1, bits_end[1] - 1)

            # load row of spikes into samples
            t = samples.t
            for bit in bits
                samples.samples[t] = parse(T, bit)
                t += 1
            end
            idx += 1
        end
    end
    
    # Prepare for next span my moving "t" to the start of the next span
    # position within the full duration of samples.
    samples.t += span_time
end

function read_poi_samples(samples::Samples, model::ModelData, span::Int64)
    # Where to access fresh samples
    path = Model.data_output_path(model)

    # source file.
    file = path * Model.poisson_files(model) * string(span) * ".data"

    synapses = Model.synapses(model)
    span_time = Model.span_time(model)

    # println("Loading new samples: ", file)

    # Load samples
    idx = 1
    open(file, "r") do f
        syn_samples = readlines(f)
        for syn_sample in syn_samples
            # Format:
            # id 1010001011010...::

            # Parse out "id" field
            idx_range = findfirst(" ", syn_sample)
            id = parse(Int64, SubString(syn_sample, 1, idx_range[1]))
            # print(id, " ")
        
            # EOL marker
            bits_end = findfirst("::", syn_sample)

            # Extract just spike data
            bits = SubString(syn_sample, idx_range[1] + 1, bits_end[1] - 1)

            # load row of spikes into samples
            t = samples.poi_t
            for bit in bits
                samples.poi_samples[idx, t] = parse(UInt8, bit)
                t += 1
            end
            idx += 1
        end
    end
    
    # Prepare for next span my moving "t" to the start of the next span
    # position within the full duration of samples.
    samples.poi_t += span_time
end

function read_stimulus_samples(samples::Samples, model::ModelData, span::Int64)
    # Where to access fresh samples
    path = Model.data_output_path(model)

    # source file.
    file = path * Model.output_stimulus_files(model) * string(span) * ".data"

    span_time = Model.span_time(model)

    # println("Loading new samples: ", file)

    # Load samples
    idx = 1
    open(file, "r") do f
        syn_samples = readlines(f)
        for syn_sample in syn_samples
            # Format:
            # id 1010001011010...::

            # Parse out "id" field
            idx_range = findfirst(" ", syn_sample)
            id = parse(Int64, SubString(syn_sample, 1, idx_range[1]))
            # print(id, " ")
        
            # EOL marker
            bits_end = findfirst("::", syn_sample)

            # Extract just spike data
            bits = SubString(syn_sample, idx_range[1] + 1, bits_end[1] - 1)
            # println(bits)
            # load row of spikes into samples
            t = samples.stim_t
            for bit in bits
                samples.stimulus_samples[idx, t] = parse(UInt8, bit)
                t += 1
            end
            idx += 1
        end
    end
    
    # Prepare for next span my moving "t" to the start of the next span
    # position within the full duration of samples.
    samples.stim_t += span_time
end

function read_float_samples(data_sams::SampleData, model::ModelData, file::String, span::Int64)
    span_time = Model.span_time(model)

    # println("Loading apFast samples: ", file)

    # Load samples
    open(file, "r") do f
        data = readlines(f)
        t = data_sams.t
        for sample in data
            # Format:
            # float
            # float
            # ...
            v = parse(Float64, sample)
            data_sams.min = min(data_sams.min, v)
            data_sams.max = max(data_sams.max, v)

            data_sams.samples[t] = v
            t += 1
        end
    end
    
    # println("min: ", data_sams.min, ", max: ", data_sams.max)
    # Prepare for next span my moving "t" to the start of the next span
    # position within the full duration of samples.
    data_sams.t += span_time
end

function read_synaptic_float_samples(syn_samples::SynapticSamples, model::ModelData, file::String, span::Int64)
    span_time = Model.span_time(model)

    # Format:
    # id float,float,float...
    # id float,float,float...
    # Nth float,float,float...
    open(file, "r") do f
        synapses = Model.synapses(model)

        for syn_id in 1:synapses
            t = syn_samples.t # reset time index for next synapse

            line_data = readline(f)

            # Fetch samples bucket
            syn_data = syn_samples.data[syn_id]

            # Parse out "id" field
            idx_range = findfirst(" ", line_data)
            id = parse(Int64, SubString(line_data, 1, idx_range[1]))

            # Extract just weight data
            sub_line = SubString(line_data, idx_range[1] + 1, length(line_data))
            weights = split(sub_line, ' ')

            for weight in weights
                w = parse(Float64, weight)
                syn_data.min = min(syn_data.min, w)
                syn_data.max = max(syn_data.max, w)

                syn_data.samples[t] = w
                t += 1
            end
        end
    end

    syn_samples.t += span_time
end