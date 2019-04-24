function draw_synapse_panel(app::AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Synapse")
        CImGui.PushItemWidth(80)

        app.buffer16 = Model.alpha(app.model)
        returned = CImGui.InputText("Alpha", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_alpha!(app.model, app.buffer16)
        end
        CImGui.SameLine(180)
        
        app.buffer16 = Model.ama(app.model)
        returned = CImGui.InputText("ama", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_ama!(app.model, app.buffer16)
        end
        CImGui.SameLine(300)

        app.buffer16 = Model.amb(app.model)
        returned = CImGui.InputText("amb", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_amb!(app.model, app.buffer16)
        end
        CImGui.SameLine(450)

        app.buffer16 = Model.lambda(app.model)
        returned = CImGui.InputText("lambda", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_lambda!(app.model, app.buffer16)
        end

        # new row
        app.buffer16 = Model.learning_rate_fast(app.model)
        returned = CImGui.InputText("Fast Learn Rate", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_learning_rate_fast!(app.model, app.buffer16)
        end
        CImGui.SameLine(250)

        app.buffer16 = Model.learning_rate_slow(app.model)
        returned = CImGui.InputText("Slow Learn Rate", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_learning_rate_slow!(app.model, app.buffer16)
        end
        CImGui.SameLine(500)

        app.buffer16 = Model.mu(app.model)
        returned = CImGui.InputText("mu", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_mu!(app.model, app.buffer16)
        end

        # new row
        app.buffer16 = Model.taoI(app.model)
        returned = CImGui.InputText("taoI", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_taoI!(app.model, app.buffer16)
        end
        CImGui.SameLine(150)

        app.buffer16 = Model.taoN(app.model)
        returned = CImGui.InputText("taoN", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_taoN!(app.model, app.buffer16)
        end
        CImGui.SameLine(300)

        app.buffer16 = Model.taoP(app.model)
        returned = CImGui.InputText("taoP", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_taoP!(app.model, app.buffer16)
        end

        # new row
        app.buffer16 = Model.distance(app.model)
        returned = CImGui.InputText("distance", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_distance!(app.model, app.buffer16)
        end
        CImGui.PopItemWidth()
        CImGui.SameLine(200)

        CImGui.PushItemWidth(200)
        app.buffer32 = Model.weight(app.model)
        returned = CImGui.InputText("weight", app.buffer32, 32, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_weight!(app.model, app.buffer32)
        end
        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end