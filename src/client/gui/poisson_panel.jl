function draw_poisson_panel(gui_data::GuiData, app_data::Model.AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Poisson Patterns")
        CImGui.PushItemWidth(80)

        # Poisson pattern generater properties
        gui_data.buffer = Model.prep_field(Model.firing_rate(app_data.model), 16)
        returned = CImGui.InputText("Firing Rate", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_firing_rate!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)  # Shifted 200px right
        
        gui_data.buffer = Model.prep_field(Model.poisson_pattern_min(app_data.model), 16)
        returned = CImGui.InputText("Pattern Min", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_min!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(450)

        gui_data.buffer = Model.prep_field(Model.poisson_pattern_max(app_data.model), 16)
        returned = CImGui.InputText("Pattern Max", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_max!(app.model, gui_data.buffer)
        end

        # Row 2 *****************************************************
        gui_data.buffer = Model.prep_field(Model.poisson_pattern_spread(app_data.model), 16)
        returned = CImGui.InputText("Pattern Spread", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_poisson_pattern_spread!(app.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end