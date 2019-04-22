
include("model/model.jl")
include("gui/gui.jl")

using .Gui

app_data = Gui.AppData()

Gui.run(app_data, soc_client)

# cleanup
using Sockets

println("Closing socket")

Sockets.close(soc_client.socket)

Gui.shutdown(app_data)
