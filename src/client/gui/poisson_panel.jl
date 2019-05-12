function draw_poisson_panel(gui_data::GuiData, app::Model.AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Poisson Patterns")
        CImGui.PushItemWidth(80)

        # Poisson pattern generater properties
        gui_data.buffer = string(Model.firing_rate(app.model))
        returned = CImGui.InputText("Firing Rate", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_firing_rate!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)  # Shifted 200px right
        
        gui_data.buffer = string(Model.poisson_pattern_min(app.model))
        returned = CImGui.InputText("Pattern Min", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_min!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(450)

        gui_data.buffer = string(Model.poisson_pattern_max(app.model))
        returned = CImGui.InputText("Pattern Max", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_max!(app.model, gui_data.buffer)
        end

        # Row 2 *****************************************************
        gui_data.buffer = string(Model.poisson_pattern_spread(app.model))
        returned = CImGui.InputText("Pattern Spread", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_spread!(app.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end