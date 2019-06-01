include("../server/simulation/simulation.jl")

using .Simulation

# Focus on synapse #3 for this test.

const SYNAPSE = 3
const TOTAL_SPIKES = 25

function test_merger_stream()
    println("Testing regular pattern stream")

    pat_stream = Simulation.RegularPatternStream()

    println(@__DIR__)
    # Load pattern stream
    file = "../../src/data/stim_2.data"

    open(file, "r") do f
        patterns = readlines(f)

        duration = length(patterns[1])
        syn_lanes = length(patterns)
        stimulus = zeros(UInt8, syn_lanes, duration)

        row = 1
        for pat_samples in patterns
            col = 1
            # Format:
            # ..|..|.....| etc
            # println(pat_samples)
            for c in pat_samples
                if c == '|'
                    stimulus[row, col] = UInt8(1)
                end
                col += 1
            end
            # println(samples[row, :])
            row += 1
        end

        Simulation.config_stream!(pat_stream, stimulus, 50)
    end

    # Create poisson stream to merge with.
    poi_stream = Simulation.PoissonStream(UInt64(13163), 0.2)

    merger = Simulation.StreamMerger()
    
    Simulation.add_stream!(merger, pat_stream)
    Simulation.add_stream!(merger, poi_stream)

    # 0000010010000001000000000000010000010000000000000000011100000000100000110000000000010010100010100010 = poisson
    # 0000100000000000000000001000000000000000000010000000000000000000100000000000000000001000000000000000 = pattern
    # 0000110010000001000000001000010000010000000010000000011100000000100000110000000000011010100010100010 = merge

    expected = [0,0,0,0,1,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0];

    for t in 1:100
        @assert Simulation.output(merger) == expected[t] "Expected output did not match at t = ($t)"
        print(Simulation.output(merger))
        Simulation.step!(merger)
    end
    println("")

    println("Passed")
end

test_merger_stream()
