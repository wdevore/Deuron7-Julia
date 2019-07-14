function draw_synapse_panel(gui_data::GuiData, app_data::Model.AppData, sock::Comm.SocClient)
    if CImGui.TreeNode("Synapse")
        CImGui.PushItemWidth(80)

        gui_data.buffer = Model.prep_field(Model.alpha(app_data.model), 16)
        returned = CImGui.InputText("Alpha", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_alphas!(app_data.model, gui_data.buffer)
            else
                Model.set_alpha!(app_data.model, gui_data.buffer)
            end
        end
        CImGui.SameLine(180)
        
        gui_data.buffer = Model.prep_field(Model.ama(app_data.model), 16)
        returned = CImGui.InputText("ama", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_amas!(app_data.model, gui_data.buffer)
            else
                Model.set_ama!(app_data.model, gui_data.buffer)
            end
        end
        CImGui.SameLine(330)

        gui_data.buffer = Model.prep_field(Model.amb(app_data.model), 16)
        returned = CImGui.InputText("amb", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_ambs!(app_data.model, gui_data.buffer)
            else
                Model.set_amb!(app_data.model, gui_data.buffer)
            end
        end
        CImGui.SameLine(480)

        gui_data.buffer = Model.prep_field(Model.lambda(app_data.model), 16)
        returned = CImGui.InputText("lambda", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_lambdas!(app_data.model, gui_data.buffer)
            else
                Model.set_lambda!(app_data.model, gui_data.buffer)
            end
        end

        # new row
        gui_data.buffer = Model.prep_field(Model.learning_rate_fast(app_data.model), 16)
        returned = CImGui.InputText("Fast Learn Rate", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_learning_rate_fasts!(app_data.model, gui_data.buffer)
            else
                Model.set_learning_rate_fast!(app_data.model, gui_data.buffer)
            end
        end
        CImGui.SameLine(280)

        gui_data.buffer = Model.prep_field(Model.learning_rate_slow(app_data.model), 16)
        returned = CImGui.InputText("Slow Learn Rate", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_learning_rate_slows!(app_data.model, gui_data.buffer)
            else
                Model.set_learning_rate_slow!(app_data.model, gui_data.buffer)
            end
        end
        CImGui.SameLine(530)

        gui_data.buffer = Model.prep_field(Model.mu(app_data.model), 16)
        returned = CImGui.InputText("mu", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_mus!(app_data.model, gui_data.buffer)
            else
                Model.set_mu!(app_data.model, gui_data.buffer)
            end
        end

        # new row
        gui_data.buffer = Model.prep_field(Model.taoI(app_data.model), 16)
        returned = CImGui.InputText("taoI", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_taoIs!(app_data.model, gui_data.buffer)
            else
                Model.set_taoI!(app_data.model, gui_data.buffer)
            end
        end
        CImGui.SameLine(150)

        gui_data.buffer = Model.prep_field(Model.taoN(app_data.model), 16)
        returned = CImGui.InputText("taoN", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_taoNs!(app_data.model, gui_data.buffer)
            else
                Model.set_taoN!(app_data.model, gui_data.buffer)
            end
        end
        CImGui.SameLine(300)

        gui_data.buffer = Model.prep_field(Model.taoP(app_data.model), 16)
        returned = CImGui.InputText("taoP", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_taoPs!(app_data.model, gui_data.buffer)
            else
                Model.set_taoP!(app_data.model, gui_data.buffer)
            end
        end

        # new row
        gui_data.buffer = Model.prep_field(Model.distance(app_data.model), 16)
        returned = CImGui.InputText("distance", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_distances!(app_data.model, gui_data.buffer)
            else
                Model.set_distance!(app_data.model, gui_data.buffer)
            end
        end
        CImGui.PopItemWidth()
        CImGui.SameLine(200)

        CImGui.PushItemWidth(200)
        gui_data.buffer = Model.prep_field(Model.weight(app_data.model), 32)
        returned = CImGui.InputText("weight", gui_data.buffer, 32, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            if app_data.model.apply_to_all
                Model.set_weights!(app_data.model, gui_data.buffer)
            else
                Model.set_weight!(app_data.model, gui_data.buffer)
            end
        end
        CImGui.PopItemWidth()

        CImGui.PushItemWidth(500)
        active = Cint(Model.active_synapse(app_data.model))
        synapses = Cint(Model.synapses(app_data.model))
        
        @c CImGui.SliderInt("Synapse##7", &active, 1, synapses)
        Model.set_active_synapse!(app_data.model, Int64(active))
        CImGui.PopItemWidth()

        CImGui.SameLine(650)
        @c CImGui.Checkbox("Apply To All", &app_data.model.apply_to_all)

        CImGui.TreePop()
    end
end