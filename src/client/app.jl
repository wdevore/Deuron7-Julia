
include("model/model.jl")
include("gui/gui.jl")

using .Gui

if soc_client ≠ nothing

    app_data = Gui.AppData()

    # Load app json
    Gui.load_data!(app_data)

    Gui.run(app_data, soc_client)

    # cleanup
    using Sockets

    println("Closing socket")

    Sockets.close(soc_client.socket)

    Gui.save_data(app_data)

    Gui.shutdown(app_data)
end

