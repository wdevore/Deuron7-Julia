include("global_panel.jl")
include("simulation_panel.jl")

function draw_main_panel(gui_data::GuiData, app_data::Model.AppData, sock::Comm.SocClient)
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
        Model.load_sim!(app_data.model)
    end
    CImGui.SameLine()

    if CImGui.Button("Save Sim")
        Model.save_sim(app_data.model)
    end

    CImGui.SameLine()
    if CImGui.Button("Simulate")
        # Get protocol
        data = app_data.basic_protocol

        # Populate
        data["From"] = "Client"
        data["To"] = "Server"
        data["Type"] = "Cmd"
        data["Data"] = "Simulate"
        data["Data1"] = Model.simulation(app_data.model)

        if !Model.is_loaded(app_data.model)
            Model.load_sim!(app_data.model)
            Model.config!(app_data)
        end

        Comm.send(sock, data)
    end
    CImGui.SameLine()

    if CImGui.Button("Stop")
        # Get protocol
        data = app_data.basic_protocol

        # Populate
        data["From"] = "Client"
        data["To"] = "Server"
        data["Type"] = "Cmd"
        data["Data"] = "Stop"

        Comm.send(sock, data)
    end
    CImGui.SameLine()

    if CImGui.Button("Shutdown Server")
        # Get protocol
        data = app_data.basic_protocol

        # Populate
        data["From"] = "Client"
        data["To"] = "Server"
        data["Type"] = "Cmd"
        data["Data"] = "Shutdown Server"

        Comm.send(sock, data)
    end

    # Global panel ************************************************
    draw_global_panel(gui_data, app_data, sock)

    # Neuron panel ************************************************
    draw_simulation_panel(gui_data, app_data, sock)
        
    CImGui.End()
end
