function draw_dendrite_panel(gui_data::GuiData, app_data::Model.AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Dendrite")
        CImGui.PushItemWidth(80)

        # Row 1 *****************************************************
        gui_data.buffer = Model.prep_field(Model.tao_eff(app_data.model), 16)
        returned = CImGui.InputText("taoEff", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao_eff!(app_data.model, gui_data.buffer)
        end
        CImGui.SameLine(250)

        gui_data.buffer = Model.prep_field(Model.dendrite_length(app_data.model), 16)
        returned = CImGui.InputText("Length", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_dendrite_length!(app_data.model, gui_data.buffer)
        end
        CImGui.SameLine(450)

        gui_data.buffer = Model.prep_field(Model.dendrite_min_psp(app_data.model), 16)
        returned = CImGui.InputText("MinPSP", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_dendrite_min_psp!(app_data.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end