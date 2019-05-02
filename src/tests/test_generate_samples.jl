include("../server/simulation/simulation.jl")

using Printf

using .Simulation

const SAMPLE_DEST_PATH = "/media/RAMDisk/"

synapses = 10
time_delta = 10 # microseconds/(step|pass)
duration = 20 * time_delta # = 2000ms * 100us/step
firing_rate = 0.02
chunk_count = 3

function test_write_poisson_samples()
    println("Test: generate poisson samples")

    # Generate 2000 milliseconds of samples for 10 synapses
    # Format:
    # id 1010001011010...
    for chunk in 1:chunk_count
        file = SAMPLE_DEST_PATH * "poi_samples_c" * string(chunk) * ".data"

        samples = zeros(UInt8, synapses, duration)
        axons = Array{Simulation.AbstractAxon,1}()

        for id in 1:synapses
            seed = Int64(round(rand(1)[1] * 10000.0))
        
            stream = Simulation.PoissonStream(UInt64(seed), firing_rate)

            axon = Simulation.DirectAxon()
            axon.base.id = id
            push!(axons, axon)

            Simulation.add_stream!(axon, stream)
        end

        for t in 1:duration
            for id in 1:synapses
                axon = axons[id]
                Simulation.pre!(axon)
                samples[id, t] = Simulation.output(axon)
                Simulation.post!(axon)
            end
        end

        open(file, "w") do f
            for id in 1:synapses
                print(f, @sprintf("%03d ", id))
                for t in 1:duration
                    print(f, samples[id, t])
                end
                println(f, "::")
            end
        end
    end

    println("Passed")
end

function test_read_poisson_samples()
    samples = zeros(UInt8, synapses, duration)
    file = SAMPLE_DEST_PATH * "poi_samples_c1.data"

    idx = 1
    open(file, "r") do f
        syn_samples = readlines(f)
        for syn_sample in syn_samples

            idx_range = findfirst(" ", syn_sample)
            id = parse(Int64, SubString(syn_sample, 1, idx_range[1]))
            # println(id)
        
            bits_end = findfirst("::", syn_sample)

            bits = SubString(syn_sample, idx_range[1] + 1, bits_end[1] - 1)

            t = 1
            for bit in bits
                samples[idx, t] = parse(UInt8, bit)
                t += 1
            end

            idx += 1
        end

        # println("samples")
        # println(samples[8, 1:100])
    end
end

test_write_poisson_samples()
# test_read_poisson_samples()
