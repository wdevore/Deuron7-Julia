using HTTP

function sendCom(command::String)
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

using Sockets

mutable struct SocClient
    socket::TCPSocket
    running::Bool

    function SocClient()
        o = new()

        o.socket = connect(2001)
        o.running = true

        o
    end

end

function listen(soc::SocClient, handler)
    @async while isopen(soc.socket)
        data = readline(soc.socket, keep = true)
        msg = String(data)
        handler(msg)
    end

    println("Listening...")
end

function send(soc::SocClient, msg::String)
    println(soc.socket, msg)
end

function handleMsg(msg::String)
    println("Got: ", msg)
    # write(stdout, msg)
end

client = SocClient()
listen(client, handleMsg)
running = true

function App()
    while running
        sleep(3.0)
        println("running...")
    end
end

@async App()