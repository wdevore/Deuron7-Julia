# All output from stimulation is kept here.
# Samples writes chunks out to disk and then resets for next chunk.
using Printf

mutable struct Samples
    poi_samples::Array{UInt8,2}

    function Samples()
        o = new()

        o
    end
end

function config_samples!(samples::Samples, synapses::Int64, length::Int64)
    samples.poi_samples = zeros(UInt8, synapses, length)
end

function write_samples!(samples::Samples, model::Model.ModelData, span::Int64)
    write_poi_samples(samples, model, span)
end

# --------------------------------------------------------
# Poisson samples
# --------------------------------------------------------
function store_poi_sample!(samples::Samples, synapseId::Int64, t::Int64, value::UInt8)
    samples.poi_samples[synapseId, t] = value
end

# Write the current samples to disk, then reset.
function write_poi_samples(samples::Samples, model::Model.ModelData, span::Int64)
    # Where to write samples
    path = Model.data_output_path(model)

    synapses = Model.synapses(model)
    span_time = Model.span_time(model)

    # Write span to a corresponding file.
    file = path * Model.poisson_files(model) * string(span) * ".data"
    
    # Now write each stream/synpase-input
    # Format:
    # id 1010001011010...::
    open(file, "w") do f
        for id in 1:synapses
                # Write stream id
            print(f, @sprintf("%03d ", id))

                # write all spikes (1) and non-spikes (0)
            # print("($id) ")
            for t in 1:span_time
                # print(samples.poi_samples[id, t])
                print(f, samples.poi_samples[id, t])
            end

                # Terminate synapse stream with "::" marker
            # println("::")
            println(f, "::")
        end
    end
end