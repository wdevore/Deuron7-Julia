include("../server/simulation/simulation.jl")

using .Simulation

function test_axon_basic()
    println("Testing Basic Axon")

    axon = Simulation.DirectAxon()

    println("Passed")
end

function test_axon_single_stream()
    println("Testing Axon single stream")
    stream = Simulation.PoissonStream(UInt64(13163), 0.2)

    axon = Simulation.DirectAxon()
    Simulation.add_stream!(axon, stream)

    @assert Simulation.output(axon) == 0 "Axon output not zero at start"

    expected_output = [0,0,0,0,0,1,0,0,1,0]
    for i in 1:10
        Simulation.pre!(axon)
        @assert Simulation.output(axon) == expected_output[i] "Expected output did not match: $i"
    end
    
    println("Passed")
end

function test_axon_two_streams()
    println("Testing Axon two streams")
    stream = Simulation.PoissonStream(UInt64(13163), 0.2)
    stream2 = Simulation.PoissonStream(UInt64(11862), 0.2)

    axon = Simulation.DirectAxon()
    Simulation.add_stream!(axon, stream)
    Simulation.add_stream!(axon, stream2)
    # for i in 1:10
    #     Simulation.step!(stream)
    #     println(Simulation.output(stream))
    # end
    # println("--------------")
    # for i in 1:10
    #     Simulation.step!(stream2)
    #     println(Simulation.output(stream2))
    # end
    # 0000010010  = stream
    # 0001001000  = stream2
    # 0001011010  = output

    expected_output = [0,0,0,1,0,1,1,0,1,0]
    for i in 1:10
        # println("i: ", i)
        Simulation.pre!(axon)
        # println(Simulation.output(axon))
        @assert Simulation.output(axon) == expected_output[i] "Expected output did not match: $i"
    end
    
    println("Passed")
end

function test_axon_delay_tiny()
    println("Testing Axon tiny delay")
    stream = Simulation.PoissonStream(UInt64(11862), 0.2)

    axon = Simulation.TinyDelayAxon(7)
    Simulation.add_stream!(axon, stream)

    # 0001001000  = stream

    # expected_output = [0,0,0,0,0,1,0,0,1,0]
    for i in 1:80
        Simulation.pre!(axon)
        print(bitstring(axon.shift_reg), " : $i pre -- ")
        Simulation.post!(axon)
        println(bitstring(axon.shift_reg), " : $i post")
        # @assert Simulation.output(axon) == expected_output[i] "Expected output did not match: $i"
    end

    println("Passed")
end

function test_axon_delay_small()
    println("Testing Axon small delay")
    stream = Simulation.PoissonStream(UInt64(11862), 0.2)

    axon = Simulation.SmallDelayAxon(63)
    Simulation.add_stream!(axon, stream)

    # 0001001000  = stream

    # expected_output = [0,0,0,0,0,1,0,0,1,0]
    for i in 1:80
        Simulation.pre!(axon)
        print(bitstring(axon.shift_reg), " : $i pre -- ")
        Simulation.post!(axon)
        println(bitstring(axon.shift_reg), " : $i post")
        # @assert Simulation.output(axon) == expected_output[i] "Expected output did not match: $i"
    end

    println("Passed")
end

function test_axon_delay_small2()
    println("Testing Axon small delay")
    stream = Simulation.PoissonStream(UInt64(13163), 0.2)
    stream2 = Simulation.PoissonStream(UInt64(11862), 0.2)

    axon = Simulation.MediumDelayAxon(32)
    Simulation.add_stream!(axon, stream)
    Simulation.add_stream!(axon, stream2)

    # 0001001000  = stream

    # expected_output = [0,0,0,0,0,1,0,0,1,0]
    for i in 1:80
        Simulation.pre!(axon)
        print(bitstring(axon.shift_reg), " : $i pre -- ")
        Simulation.post!(axon)
        println(bitstring(axon.shift_reg), " : $i post")
        # @assert Simulation.output(axon) == expected_output[i] "Expected output did not match: $i"
    end

    println("Passed")
end


test_axon_delay_small()