using HTTP

function send(command::String)
    url = "127.0.0.1"
    port = "8081"
    # println("Connecting to: ", url, ":", port)

    response = ""

    HTTP.WebSockets.open("ws://" * url * ":" * port * "") do ws
        write(ws, command)
        
        msg = String(readavailable(ws))
        parts = split(msg, "::")
        if parts[1] ≠ "Recognized command"
            println("Server problem ocurred: ", msg)
        else
            response = String(parts[2])
        end
    end

    response
end

