include("../server/simulation/stimulus/stimulus.jl")

const SYNAPSE = 3

function test_regular_stream()
    println("Testing regular pattern stream")

    stream = RegularPatternStream()

    # Load pattern
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

        config_stream!(stream, stimulus, 50)

        set_synapse!(stream, SYNAPSE)
        for t in 1:50
            print(output(stream))
            step!(stream)
        end
        println("")
    end

    println("Passed")
end

test_regular_stream()
