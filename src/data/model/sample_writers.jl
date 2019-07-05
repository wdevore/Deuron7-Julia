# ---------------------------------------------------------------------------
# Writers
# ---------------------------------------------------------------------------
using Printf

# Note: the client will read this data for display.
function samples_writer(samples::SpanArray, model::ModelData, f::IOStream)
    synapses = Model.synapses(model)
    span_time = Model.span_time(model)

    # Now write each stream/synpase-input
    # Format:
    # id 1010001011010...::
    for id in 1:synapses
        # Write stream id
        print(f, @sprintf("%03d ", id))

        # write all spikes (1) and non-spikes (0)
        # print("($id) ")
        for t in 1:span_time
            # print(samples.poi_samples[id, t])
            print(f, samples[id, t])
        end

        # Terminate synapse stream with "::" marker
        # println("::")
        println(f, "::")
    end
end

function cell_samples_writer(samples::Array{UInt8,1}, model::ModelData, f::IOStream)
    span_time = Model.span_time(model)

    # Now write each stream/synpase-input
    # Format:
    # id 1010001011010...::

    print(f, @sprintf("%03d ", 1))

    # write all spikes (1) and non-spikes (0)
    for t in 1:span_time
        print(f, samples[t])
    end

    # Terminate synapse stream with "::" marker
    println(f, "::")
end

function float_samples_writer(samples::Array{Float64,1}, model::ModelData, f::IOStream)
    span_time = Model.span_time(model)

    # Format:
    # float
    # float
    # ...

    for t in 1:span_time
        println(f, samples[t])
    end
end

function synapse_writer(syn_samples::SynapticSamples, model::ModelData, f::IOStream)
    span_time = Model.span_time(model)

    # Format:
    # id float,float,float...
    # id float,float,float...
    # Nth float,float,float...

    synapses = Model.synapses(model)

    for syn_id in 1:synapses
        syn_data = syn_samples.data[syn_id]

        print(f, @sprintf("%03d ", syn_id))

        for t in 1:span_time - 1
            print(f, syn_data.samples[t], " ")
        end

        println(f, syn_data.samples[span_time])
    end

end

# Write the current samples to disk, then reset.
function write_samples_out(samples::Array, file::String, model::ModelData, writer)
    open(file, "w") do f
        writer(samples, model, f)
    end
end

function write_samples_out(data::SampleData, file::String, model::ModelData, writer)
    open(file, "w") do f
        writer(data.samples, model, f)
    end
end

function write_samples_out(samples::SynapticSamples, file::String, model::ModelData, writer)
    open(file, "w") do f
        writer(samples, model, f)
    end
end
