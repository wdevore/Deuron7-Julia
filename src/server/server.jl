# Main application entry point.
# Launch server before launching client.
using HTTP
using HTTP.Sockets

function server()
    url = Sockets.localhost #ARGS[1]   # "127.0.0.1"
    port = parse(UInt16, ARGS[2])  # 8081
    println("Listening on: ", url, ":", port)

    running = true

    # Example code from:
    # https://github.com/JuliaWeb/HTTP.jl/blob/master/test/WebSockets.jl
    
    @async HTTP.listen(url, port) do http
        if HTTP.WebSockets.is_upgrade(http.message)
            HTTP.WebSockets.upgrade(http) do ws

                response = ""

                while !eof(ws)
                    data = readavailable(ws)

                    msg = String(data)

                    if msg == "Shutdown"
                        running = false
                        response = "Recognized command::Shutting down"
                    elseif msg == "Cmd1"
                        response = "Recognized command::Didit1"
                    elseif msg == "Cmd2"
                        response = "Recognized command::Doit2"
                    else
                        response = "Unknown command::" * msg
                    end

                    if msg ≠ ""
                        println("server got: ", msg)
                    end

                    write(ws, response)
                end
            end
        end
    end

    while running
        sleep(0.1)
    end
end

server()