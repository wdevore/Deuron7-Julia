using .Comm

app_data = Model.AppData()

println("Connecting to server...")
soc_client = Comm.SocClient()

if soc_client ≠ nothing
    println("Connected to server.")

    Comm.listen(soc_client)
else
    println("#######################################################")
    println("WARNING! Failed to connect to server.")
    println("Start server from server folder before running client.")
    println("Goodbye.")
    println("#######################################################")
end

include("../gui/gui.jl")

using .Gui
using .Model

if soc_client ≠ nothing
    gui_data = Gui.GuiData()

    # Load app json
    Model.load_data!(app_data)

    # run() doesn't return until the application is closed
    Gui.run(gui_data, app_data, soc_client)

    # ------------ Shutting down -------------------------------
    using Sockets

    println("Closing socket")

    Sockets.close(soc_client.socket)

    println("Saving model")
    Model.save_data(app_data)

    println("Closing Gui")
    Gui.shutdown(gui_data)

    println("Goodbye.")
end

