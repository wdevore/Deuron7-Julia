function draw_neuron_panel(gui_data::GuiData, app_data::Model.AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Neuron")
        CImGui.PushItemWidth(80)

        # Row 1 *****************************************************
        gui_data.buffer = Model.prep_field(Model.refractory_period(app_data.model), 16)
        returned = CImGui.InputText("RefractoryPeriod", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_refractory_period!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)

        gui_data.buffer = Model.prep_field(Model.ap_max(app_data.model), 16)
        returned = CImGui.InputText("APMax", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_ap_max!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(450)

        gui_data.buffer = Model.prep_field(Model.threshold(app_data.model), 16)
        returned = CImGui.InputText("Threshold", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_threshold!(app.model, gui_data.buffer)
        end

        # Row 2 *****************************************************
        gui_data.buffer = Model.prep_field(Model.fast_surge(app_data.model), 16)
        returned = CImGui.InputText("Fast Surge", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_fast_surge!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)

        gui_data.buffer = Model.prep_field(Model.slow_surge(app_data.model), 16)
        returned = CImGui.InputText("Slow Surge", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_slow_surge!(app.model, gui_data.buffer)
        end

        # Row 3 *****************************************************
        gui_data.buffer = Model.prep_field(Model.tao(app_data.model), 16)
        returned = CImGui.InputText("Tao", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)

        gui_data.buffer = Model.prep_field(Model.tao_j(app_data.model), 16)
        returned = CImGui.InputText("Tao J", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao_j!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(450)

        gui_data.buffer = Model.prep_field(Model.tao_s(app_data.model), 16)
        returned = CImGui.InputText("Tao S", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao_s!(app.model, gui_data.buffer)
        end
        
        # Row 4 *****************************************************
        gui_data.buffer = Model.prep_field(Model.weight_min(app_data.model), 16)
        returned = CImGui.InputText("Weight min", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight_min!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)

        gui_data.buffer = Model.prep_field(Model.weight_max(app_data.model), 16)
        returned = CImGui.InputText("Weight max", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight_max!(app.model, gui_data.buffer)
        end

        gui_data.buffer = Model.prep_field(Model.active_synapse(app_data.model), 8)
        returned = CImGui.InputText("Active Synapse", gui_data.buffer, 8, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_active_synapse!(app.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end