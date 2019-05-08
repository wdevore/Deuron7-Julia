function draw_neuron_panel(app::AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Neuron")
        CImGui.PushItemWidth(80)

        # Row 1 *****************************************************
        app.buffer = string(Model.refractory_period(app.model))
        returned = CImGui.InputText("RefractoryPeriod", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_refractory_period!(app.model, app.buffer)
        end
        CImGui.SameLine(250)

        app.buffer = string(Model.ap_max(app.model))
        returned = CImGui.InputText("APMax", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_ap_max!(app.model, app.buffer)
        end
        CImGui.SameLine(450)

        app.buffer = string(Model.threshold(app.model))
        returned = CImGui.InputText("Threshold", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_threshold!(app.model, app.buffer)
        end

        # Row 2 *****************************************************
        app.buffer = string(Model.fast_surge(app.model))
        returned = CImGui.InputText("Fast Surge", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_fast_surge!(app.model, app.buffer)
        end
        CImGui.SameLine(250)

        app.buffer = string(Model.slow_surge(app.model))
        returned = CImGui.InputText("Slow Surge", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_slow_surge!(app.model, app.buffer)
        end

        # Row 3 *****************************************************
        app.buffer = string(Model.tao(app.model))
        returned = CImGui.InputText("Tao", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao!(app.model, app.buffer)
        end
        CImGui.SameLine(250)

        app.buffer = string(Model.tao_j(app.model))
        returned = CImGui.InputText("Tao J", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao_j!(app.model, app.buffer)
        end
        CImGui.SameLine(450)

        app.buffer = string(Model.tao_s(app.model))
        returned = CImGui.InputText("Tao S", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao_s!(app.model, app.buffer)
        end
        
        # Row 4 *****************************************************
        app.buffer = string(Model.weight_min(app.model))
        returned = CImGui.InputText("Weight min", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight_min!(app.model, app.buffer)
        end
        CImGui.SameLine(250)

        app.buffer = string(Model.weight_max(app.model))
        returned = CImGui.InputText("Weight max", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight_max!(app.model, app.buffer)
        end

        app.buffer = string(Model.active_synapse(app.model))
        returned = CImGui.InputText("Active Synapse", app.buffer, 8, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_active_synapse!(app.model, app.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end