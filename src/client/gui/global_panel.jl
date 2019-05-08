function draw_global_panel(app::AppData, sock::Comm.SocClient)
    if CImGui.CollapsingHeader("Global")
        CImGui.PushItemWidth(150)

        app.buffer = string(Model.simulation(app.model))
        returned = CImGui.InputText("Active Simulation", app.buffer, 50, CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        # println(app.buffer)
        if returned
            # println("enter: [", app.buffer16, "]")
            # range = findfirst("\0", app.buffer16)
            # value = String(SubString(app.buffer16, 1:(range[1] - 1)))
            # Model.set_duration!(app.model, value)
            Model.set_simulation!(app.model, app.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.PushItemWidth(80)

        app.buffer = string(Model.duration(app.model))
        returned = CImGui.InputText("Duration", app.buffer, 50, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
        # println("enter: [", app.buffer16, "]")
        # range = findfirst("\0", app.buffer16)
        # value = String(SubString(app.buffer16, 1:(range[1] - 1)))
        # Model.set_duration!(app.model, value)
            Model.set_duration!(app.model, app.buffer)
        end
        CImGui.SameLine(200)

        app.buffer = string(Model.time_scale(app.model))
        returned = CImGui.InputText("Time Scale", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_time_scale!(app.model, app.buffer)
        end
        CImGui.SameLine(400)

        app.buffer = string(Model.spans(app.model))
        returned = CImGui.InputText("Spans", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_spans!(app.model, app.buffer)
        end

        app.buffer = string(Model.range_start(app.model))
        returned = CImGui.InputText("Range Start", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_range_start!(app.model, app.buffer)
        end
        CImGui.SameLine(300)

        app.buffer = string(Model.range_end(app.model))
        returned = CImGui.InputText("Range End", app.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_range_end!(app.model, app.buffer)
        end

        CImGui.PopItemWidth()
    end
end