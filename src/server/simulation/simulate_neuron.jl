export simulate

# Runs @async
function run(chan::Channel{String})
    x = 0
    y = 0
    println("Simulating...")
    # running = true

    @async begin
        # running = false
        simulate(chan)

        data = JSON.parsefile("../data/com_protocol_basic.json")

        # Populate
        data["From"] = "Simulation"
        data["To"] = "Client"
        data["Type"] = "Response"
        data["Data"] = "Simulation Complete"

        put!(chan, JSON.json(data))
    end

    # Wait for sim to complete
    # while running
    #     sleep(0.001)
    # end

    # try
    # catch ex
    #     println("Exception: ", ex)
    # end
end

function simulate(chan::Channel{String})
    for i in 1:100
        sleep(0.001)
    end
    println("Simulaton Complete.")
end