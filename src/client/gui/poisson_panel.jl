function draw_poisson_panel(app::AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Poisson Patterns")
        CImGui.PushItemWidth(80)

        # Poisson pattern generater properties
        app.buffer = Model.firing_rate(app.model)
        returned = CImGui.InputText("Firing Rate", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_firing_rate!(app.model, app.buffer)
        end
        CImGui.SameLine(250)  # Shifted 200px right
        
        app.buffer = Model.poisson_pattern_min(app.model)
        returned = CImGui.InputText("Pattern Min", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_min!(app.model, app.buffer)
        end
        CImGui.SameLine(450)

        app.buffer = Model.poisson_pattern_max(app.model)
        returned = CImGui.InputText("Pattern Max", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_max!(app.model, app.buffer)
        end

        # Row 2 *****************************************************
        app.buffer = Model.poisson_pattern_spread(app.model)
        returned = CImGui.InputText("Pattern Spread", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_spread!(app.model, app.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end