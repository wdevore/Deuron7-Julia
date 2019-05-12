include("../client/gui/graphs/graphs.jl")

using .Graphs

function test_positive_linear()
    println("Testing positive range")

    data = [3, 10, 15, 20, 22, 26, 30]

    max = findmax(data)
    min = findmin(data)
    
    l = linear(Float64(min[1]), Float64(max[1]), 3.0)
    @assert l == 0.0 "Expected 0.0"

    l = linear(Float64(min[1]), Float64(max[1]), 30.0)
    @assert l == 1.0 "Expected 1.0"

    println("Passed")
end

function test_negative_linear()
    println("Testing negative range")

    data = [-10, -3, 0, 5, 20, 22, 26, 30]

    max = findmax(data)
    min = findmin(data)
    # println(min, ", ", max)

    l = linear(Float64(min[1]), Float64(max[1]), -10.0)
    @assert l == 0.0 "Expected 0.0"

    l = linear(Float64(min[1]), Float64(max[1]), 30.0)
    @assert l == 1.0 "Expected 1.0"

    println("Passed")
end

function test_lerp()
    println("Testing lerp")

    l = lerp(0.0, 200.0, 0.5)
    @assert l == 100.0 "Expected 100.0, Got: $l"

    l = lerp(50.0, 200.0, 0.5)
    @assert l == 125.0 "Expected 125.0, Got: $l"

    println("Passed")
end

test_positive_linear()
test_negative_linear()
test_lerp()