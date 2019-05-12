function draw_neuron_panel(gui_data::GuiData, app::Model.AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Neuron")
        CImGui.PushItemWidth(80)

        # Row 1 *****************************************************
        gui_data.buffer = string(Model.refractory_period(app.model))
        returned = CImGui.InputText("RefractoryPeriod", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_refractory_period!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)

        gui_data.buffer = string(Model.ap_max(app.model))
        returned = CImGui.InputText("APMax", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_ap_max!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(450)

        gui_data.buffer = string(Model.threshold(app.model))
        returned = CImGui.InputText("Threshold", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_threshold!(app.model, gui_data.buffer)
        end

        # Row 2 *****************************************************
        gui_data.buffer = string(Model.fast_surge(app.model))
        returned = CImGui.InputText("Fast Surge", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_fast_surge!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)

        gui_data.buffer = string(Model.slow_surge(app.model))
        returned = CImGui.InputText("Slow Surge", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_slow_surge!(app.model, gui_data.buffer)
        end

        # Row 3 *****************************************************
        gui_data.buffer = string(Model.tao(app.model))
        returned = CImGui.InputText("Tao", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)

        gui_data.buffer = string(Model.tao_j(app.model))
        returned = CImGui.InputText("Tao J", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao_j!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(450)

        gui_data.buffer = string(Model.tao_s(app.model))
        returned = CImGui.InputText("Tao S", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao_s!(app.model, gui_data.buffer)
        end
        
        # Row 4 *****************************************************
        gui_data.buffer = string(Model.weight_min(app.model))
        returned = CImGui.InputText("Weight min", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight_min!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(250)

        gui_data.buffer = string(Model.weight_max(app.model))
        returned = CImGui.InputText("Weight max", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight_max!(app.model, gui_data.buffer)
        end

        gui_data.buffer = string(Model.active_synapse(app.model))
        returned = CImGui.InputText("Active Synapse", gui_data.buffer, 8, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_active_synapse!(app.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end