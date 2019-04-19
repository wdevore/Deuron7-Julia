export simulate

# Runs @async
function simulate(chan::Channel{String})
    x = 0
    y = 0
    println("Simulating...")
    @async begin
        for i in 1:1000
            sleep(0.001)
        end
        println("Simulaton complete.")
        put!(chan, "Channel::Msg::Simulation complete")
    end
end

