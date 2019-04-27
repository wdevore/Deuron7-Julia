# Contains: start, stop

include("global_panel.jl")
include("simulation_panel.jl")

function draw_main_panel(app::AppData, sock::Comm.SocClient)
    CImGui.SetNextWindowPos((0, 0), CImGui.ImGuiCond_Once)

    # we use a Begin/End pair to create a named window.
    CImGui.Begin("Main panel")  # create a window panel and append into it.
    # CImGui.Text("This is some useful text.")  # display some text
    # @c CImGui.Checkbox("Demo Window", &app.show_demo_window)  # edit bools storing our window open/close state
    # @c CImGui.Checkbox("Another Window", &app.show_another_window)
    
    # @c CImGui.SliderFloat("float", &app.float_slide, 0, 1)  # edit 1 float using a slider from 0 to 1
    # CImGui.ColorEdit3("clear color", app.clear_color)  # edit 3 floats representing a color
    # CImGui.Separator()

    # CImGui.Text(@sprintf("Simulation '%s'", Model.simulation(app.model)))
    CImGui.Text(@sprintf("Status: %.2f ms/frame (%.1f FPS)", 1000 / CImGui.GetIO().Framerate, CImGui.GetIO().Framerate))
    CImGui.Separator()

    # Button bar ************************************************
    if CImGui.Button("Load Sim")
        # load simulation data
        Model.load_sim!(app.model)
    end
    CImGui.SameLine()

    if CImGui.Button("Save Sim")
        Model.save_sim(app.model)
    end

    CImGui.SameLine()
    if CImGui.Button("Simulate")
        # app.counter += 1
        # Get protocol
        data = JSON.parsefile("../data/com_protocol_basic.json")

        # Populate
        data["From"] = "Client"
        data["To"] = "Server"
        data["Type"] = "Cmd"
        data["Data"] = "Simulate"

        Comm.send(sock, data)
    end
    CImGui.SameLine()

    if CImGui.Button("Stop")
        Comm.send(sock, "Channel::Cmd::Stop")
    end
    CImGui.SameLine()

    if CImGui.Button("Shutdown Server")
        # Get protocol
        data = JSON.parsefile("../data/com_protocol_basic.json")

        # Populate
        data["From"] = "Client"
        data["To"] = "Server"
        data["Type"] = "Cmd"
        data["Data"] = "Shutdown Server"

        Comm.send(sock, data)
    end

    # Global panel ************************************************
    draw_global_panel(app, sock)

    # Neuron panel ************************************************
    draw_simulation_panel(app, sock)
        
    CImGui.End()
end
