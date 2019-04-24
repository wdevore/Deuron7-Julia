function draw_neuron_panel(app::AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Neuron")
        CImGui.PushItemWidth(80)

        # Row 1 *****************************************************
        app.buffer16 = Model.refractory_period(app.model)
        returned = CImGui.InputText("RefractoryPeriod", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_refractory_period!(app.model, app.buffer16)
        end
        CImGui.SameLine(250)

        app.buffer16 = Model.ap_max(app.model)
        returned = CImGui.InputText("APMax", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_ap_max!(app.model, app.buffer16)
        end
        CImGui.SameLine(450)

        app.buffer16 = Model.threshold(app.model)
        returned = CImGui.InputText("Threshold", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_threshold!(app.model, app.buffer16)
        end

        # Row 2 *****************************************************
        app.buffer16 = Model.fast_surge(app.model)
        returned = CImGui.InputText("Fast Surge", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_fast_surge!(app.model, app.buffer16)
        end
        CImGui.SameLine(250)

        app.buffer16 = Model.slow_surge(app.model)
        returned = CImGui.InputText("Slow Surge", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_slow_surge!(app.model, app.buffer16)
        end

        # Row 3 *****************************************************
        app.buffer16 = Model.tao(app.model)
        returned = CImGui.InputText("Tao", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao!(app.model, app.buffer16)
        end
        CImGui.SameLine(250)

        app.buffer16 = Model.tao_j(app.model)
        returned = CImGui.InputText("Tao J", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao_j!(app.model, app.buffer16)
        end
        CImGui.SameLine(450)

        app.buffer16 = Model.tao_s(app.model)
        returned = CImGui.InputText("Tao S", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_tao_s!(app.model, app.buffer16)
        end
        
        # Row 4 *****************************************************
        app.buffer16 = Model.weight_min(app.model)
        returned = CImGui.InputText("Weight min", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight_min!(app.model, app.buffer16)
        end
        CImGui.SameLine(250)

        app.buffer16 = Model.weight_max(app.model)
        returned = CImGui.InputText("Weight max", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight_max!(app.model, app.buffer16)
        end

        app.buffer = Model.active_synapse(app.model)
        returned = CImGui.InputText("Active Synapse", app.buffer, 8, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_active_synapse!(app.model, app.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end