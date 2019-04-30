include("../server/simulation/simulation.jl")

using Printf

using .Simulation

const SAMPLE_DEST_PATH = "/media/RAMDisk/"

function test_write_poisson_samples()
    println("Test: generate poisson samples")

    # Generate 2000 milliseconds of samples for 10 synapses
    # Format:
    # id 1010001011010...
    
    synapses = 10
    time_delta = 100 # microseconds/(step|pass)
    duration = 2000 * time_delta # = 2000ms * 100us/step

    samples = zeros(UInt8, synapses, duration)
    axons = Array{Simulation.AbstractAxon,1}()

    for id in 1:synapses
        seed = Int64(round(rand(1)[1] * 10000.0))
        # println("seed: ", seed)
        stream = Simulation.PoissonStream(UInt64(seed), 0.002)

        axon = Simulation.DirectAxon()
        axon.base.id = id
        push!(axons, axon)

        Simulation.add_stream!(axon, stream)
    end

    for t in 1:duration
        for id in 1:synapses
            axon = axons[id]
            Simulation.pre!(axon)
            # println(id, " ", t)
            # println(Simulation.output(axon))
            samples[id, t] = Simulation.output(axon)
            Simulation.post!(axon)
        end
    end

    # Write to file
    file = SAMPLE_DEST_PATH * "poi_samples.data"

    open(file, "w") do f
        for id in 1:synapses
            print(f, @sprintf("%03d ", id))
            for t in 1:duration
                print(f, samples[id, t])
            end
            println(f, "")
        end
    end

    println("Passed")
end

test_write_poisson_samples()