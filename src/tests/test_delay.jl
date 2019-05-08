include("../server/simulation/simulation.jl")

using .Simulation

function test_tiny_delay()
    println("Testing tiny delay")

    stream = Simulation.PoissonStream(UInt64(13163), 0.2)

    delay = Simulation.TinyDelay(stream)

    @assert Simulation.output(delay) == 0 "Delay output not zero at start"

    expected_output = [0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0]
    for i in 1:20
        Simulation.pre!(delay)
        print(Simulation.output(delay), ",")
        # @assert Simulation.output(delay) == expected_output[i] "Expected output did not match: $i"
        Simulation.post!(delay)
    end
    println("")

    println("Passed")
end

function test_tiny_delay3()
    println("Testing tiny delay of 3")

    stream = Simulation.PoissonStream(UInt64(13163), 0.2)

    delay = Simulation.TinyDelay(stream, 3)

    @assert Simulation.output(delay) == 0 "Delay output not zero at start"

    # Not shifted     [0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0]
    expected_output = [0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0] # delayed
    for i in 1:20
        Simulation.pre!(delay)
        # print(Simulation.output(delay), ",")
        @assert Simulation.output(delay) == expected_output[i] "Expected output did not match: $i"
        Simulation.post!(delay)
    end
    # println("")

    println("Passed")
end

function test_small_delay()
    println("Testing small delay")

    stream = Simulation.PoissonStream(UInt64(13163), 0.2)

    delay = Simulation.SmallDelay(stream, 10)

    @assert Simulation.output(delay) == 0 "Delay output not zero at start"

    expected_output = [0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0]
    for i in 1:100
        Simulation.pre!(delay)
        print(Simulation.output(delay), ",")
        # @assert Simulation.output(delay) == expected_output[i] "Expected output did not match: $i"
        Simulation.post!(delay)
    end
    println("")
    println("Passed")
end

function test_medium_delay()
    println("Testing medium delay")

    stream = Simulation.PoissonStream(UInt64(13163), 0.2)

    delay = Simulation.MediumDelay(stream, 20)

    @assert Simulation.output(delay) == 0 "Delay output not zero at start"

    expected_output = [0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0]
    for i in 1:100
        Simulation.pre!(delay)
        print(Simulation.output(delay), ",")
        # @assert Simulation.output(delay) == expected_output[i] "Expected output did not match: $i"
        Simulation.post!(delay)
    end
    println("")
    println("Passed")
end


test_medium_delay()