function draw_synapse_panel(app::AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Synapse")
        CImGui.PushItemWidth(80)

        app.buffer = string(Model.alpha(app.model))
        returned = CImGui.InputText("Alpha", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_alpha!(app.model, app.buffer)
        end
        CImGui.SameLine(180)
        
        app.buffer = string(Model.ama(app.model))
        returned = CImGui.InputText("ama", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_ama!(app.model, app.buffer)
        end
        CImGui.SameLine(300)

        app.buffer = string(Model.amb(app.model))
        returned = CImGui.InputText("amb", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_amb!(app.model, app.buffer)
        end
        CImGui.SameLine(450)

        app.buffer = string(Model.lambda(app.model))
        returned = CImGui.InputText("lambda", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_lambda!(app.model, app.buffer)
        end

        # new row
        app.buffer = string(Model.learning_rate_fast(app.model))
        returned = CImGui.InputText("Fast Learn Rate", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_learning_rate_fast!(app.model, app.buffer)
        end
        CImGui.SameLine(250)

        app.buffer = string(Model.learning_rate_slow(app.model))
        returned = CImGui.InputText("Slow Learn Rate", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_learning_rate_slow!(app.model, app.buffer)
        end
        CImGui.SameLine(500)

        app.buffer = string(Model.mu(app.model))
        returned = CImGui.InputText("mu", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_mu!(app.model, app.buffer)
        end

        # new row
        app.buffer = string(Model.taoI(app.model))
        returned = CImGui.InputText("taoI", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_taoI!(app.model, app.buffer)
        end
        CImGui.SameLine(150)

        app.buffer = string(Model.taoN(app.model))
        returned = CImGui.InputText("taoN", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_taoN!(app.model, app.buffer)
        end
        CImGui.SameLine(300)

        app.buffer = string(Model.taoP(app.model))
        returned = CImGui.InputText("taoP", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_taoP!(app.model, app.buffer)
        end

        # new row
        app.buffer = string(Model.distance(app.model))
        returned = CImGui.InputText("distance", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_distance!(app.model, app.buffer)
        end
        CImGui.PopItemWidth()
        CImGui.SameLine(200)

        CImGui.PushItemWidth(200)
        app.buffer = string(Model.weight(app.model))
        returned = CImGui.InputText("weight", app.buffer, 32, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight!(app.model, app.buffer)
        end
        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end