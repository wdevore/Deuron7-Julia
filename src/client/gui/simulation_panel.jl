function draw_simulation_panel(app::AppData, sock::Comm.SocClient)
    if CImGui.CollapsingHeader("Simulation")
        CImGui.PushItemWidth(80)

        app.buffer16 = Model.stimulus_scaler(app.model)
        returned = CImGui.InputText("Stimulus Scaler", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            # println("enter: [", app.buffer16, "]")
            # range = findfirst("\0", app.buffer16)
            # value = String(SubString(app.buffer16, 1:(range[1] - 1)))
            # Model.set_duration!(app.model, value)
            Model.set_stimulus_scaler!(app.model, app.buffer16)
        end
        CImGui.SameLine(300)

        app.buffer16 = Model.hertz(app.model)
        returned = CImGui.InputText("Hertz (ISI)", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_hertz!(app.model, app.buffer16)
        end

        CImGui.PopItemWidth()
        
        # Poisson panel ************************************************
        draw_poisson_panel(app, sock)

        draw_neuron_panel(app, sock)

        draw_synapse_panel(app, sock)
    end
end