function draw_synapse_panel(gui_data::GuiData, app::Model.AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Synapse")
        CImGui.PushItemWidth(80)

        gui_data.buffer = string(Model.alpha(app.model))
        returned = CImGui.InputText("Alpha", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_alpha!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(180)
        
        gui_data.buffer = string(Model.ama(app.model))
        returned = CImGui.InputText("ama", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_ama!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(330)

        gui_data.buffer = string(Model.amb(app.model))
        returned = CImGui.InputText("amb", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_amb!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(480)

        gui_data.buffer = string(Model.lambda(app.model))
        returned = CImGui.InputText("lambda", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_lambda!(app.model, gui_data.buffer)
        end

        # new row
        gui_data.buffer = string(Model.learning_rate_fast(app.model))
        returned = CImGui.InputText("Fast Learn Rate", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_learning_rate_fast!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(280)

        gui_data.buffer = string(Model.learning_rate_slow(app.model))
        returned = CImGui.InputText("Slow Learn Rate", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_learning_rate_slow!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(530)

        gui_data.buffer = string(Model.mu(app.model))
        returned = CImGui.InputText("mu", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_mu!(app.model, gui_data.buffer)
        end

        # new row
        gui_data.buffer = string(Model.taoI(app.model))
        returned = CImGui.InputText("taoI", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_taoI!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(150)

        gui_data.buffer = string(Model.taoN(app.model))
        returned = CImGui.InputText("taoN", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_taoN!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(300)

        gui_data.buffer = string(Model.taoP(app.model))
        returned = CImGui.InputText("taoP", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_taoP!(app.model, gui_data.buffer)
        end

        # new row
        gui_data.buffer = string(Model.distance(app.model))
        returned = CImGui.InputText("distance", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_distance!(app.model, gui_data.buffer)
        end
        CImGui.PopItemWidth()
        CImGui.SameLine(200)

        CImGui.PushItemWidth(200)
        gui_data.buffer = string(Model.weight(app.model))
        returned = CImGui.InputText("weight", gui_data.buffer, 32, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight!(app.model, gui_data.buffer)
        end
        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end