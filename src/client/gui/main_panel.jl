# Contains: start, stop

include("simulation_panel.jl")
include("neuron_panel.jl")
include("poisson_panel.jl")
include("synapse_panel.jl")

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
        Comm.send(sock, "Channel::Cmd::Simulate")
    end
    CImGui.SameLine()

    if CImGui.Button("Stop")
        Comm.send(sock, "Channel::Cmd::Stop")
    end
    CImGui.SameLine()

    if CImGui.Button("Shutdown Server")
        Comm.send(sock, "Channel::Cmd::Shutdown server")
    end

    # Global panel ************************************************
    if CImGui.CollapsingHeader("Global")
        app.buffer1024 = Model.simulation(app.model)
        returned = CImGui.InputText("Simulation", app.buffer1024, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            # println("enter: [", app.buffer16, "]")
            # range = findfirst("\0", app.buffer16)
            # value = String(SubString(app.buffer16, 1:(range[1] - 1)))
            # Model.set_duration!(app.model, value)
            Model.set_simulation!(app.model, app.buffer1024)
        end

        CImGui.PushItemWidth(80)
        app.buffer16 = Model.duration(app.model)
        returned = CImGui.InputText("Duration", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            # println("enter: [", app.buffer16, "]")
            # range = findfirst("\0", app.buffer16)
            # value = String(SubString(app.buffer16, 1:(range[1] - 1)))
            # Model.set_duration!(app.model, value)
            Model.set_duration!(app.model, app.buffer16)
        end
        CImGui.SameLine(200)  # Shifted 200px right

        app.buffer16 = Model.time_step(app.model)
        returned = CImGui.InputText("Time Step", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_time_step!(app.model, app.buffer16)
        end

        app.buffer16 = Model.range_start(app.model)
        returned = CImGui.InputText("Range Start", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_range_start!(app.model, app.buffer16)
        end
        CImGui.SameLine(200)

        app.buffer16 = Model.range_end(app.model)
        returned = CImGui.InputText("Range End", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_range_end!(app.model, app.buffer16)
        end

        # Synapse panel ************************************************
        app.buffer16 = Model.active_synapse(app.model)
        returned = CImGui.InputText("Active Synapse", app.buffer8, 8, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_active_synapse!(app.model, app.buffer16)
        end

        CImGui.PopItemWidth()
    end

    # Neuron panel ************************************************
    draw_simulation_panel(app, sock)
        
    CImGui.End()
end
