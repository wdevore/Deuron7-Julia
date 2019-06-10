# Main application entry point.
# Launch server before launching client.
#
# To run:
# > julia main.jl 127.0.0.1 2001

include("simulation/simulation.jl")

include("app/socket.jl")

using JSON
using .Server

soc_server = Server.SockServer()

@async while true
    input = readavailable(stdin)

    msg = String(input[1:length(input) - 1])
    # println("input: ", msg)
    if msg == "q"  #0x71 # "q" == quit
        println("Quiting...")

        trace = try
            if soc_server.running
                # println("Server is running. Toggling running flag...")
                soc_server.running = false
            end

            nothing
        catch ex
            println("### Exception ###:\n", ex)
            stacktrace(catch_backtrace())
        end

        if trace ≠ nothing
            println(trace)
            println("############################################")
            println("Goodbye.")
            exit(1)
        end

    elseif msg == "help"
        println("--------------------------------------------")
        println("Commands:")
        println("  run")
        println("  run debug")
        println("--------------------------------------------")
    end
end

Server.start(soc_server)

