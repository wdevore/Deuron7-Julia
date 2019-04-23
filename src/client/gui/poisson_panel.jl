function draw_poisson_panel(app::AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Poisson Patterns")
        CImGui.PushItemWidth(80)

        # Poisson pattern generater properties
        app.buffer16 = Model.firing_rate(app.model)
        returned = CImGui.InputText("Firing Rate", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_firing_rate!(app.model, app.buffer16)
        end
        CImGui.SameLine(250)  # Shifted 200px right
        
        app.buffer16 = Model.poisson_pattern_min(app.model)
        returned = CImGui.InputText("Pattern Min", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_min!(app.model, app.buffer16)
        end
        CImGui.SameLine(450)

        app.buffer16 = Model.poisson_pattern_max(app.model)
        returned = CImGui.InputText("Pattern Max", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_max!(app.model, app.buffer16)
        end

        # Row 2 *****************************************************
        app.buffer16 = Model.poisson_pattern_spread(app.model)
        returned = CImGui.InputText("Pattern Spread", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_spread!(app.model, app.buffer16)
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end