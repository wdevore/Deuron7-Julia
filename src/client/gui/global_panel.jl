function draw_global_panel(gui_data::GuiData, app::Model.AppData, sock::Comm.SocClient)
    if CImGui.CollapsingHeader("Global")
        CImGui.PushItemWidth(150)

        gui_data.buffer = string(Model.simulation(app.model))
        returned = CImGui.InputText("Active Simulation", gui_data.buffer, 50, CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        # println(gui_data.buffer)
        if returned
            # println("enter: [", gui_data.buffer16, "]")
            # range = findfirst("\0", gui_data.buffer16)
            # value = String(SubString(gui_data.buffer16, 1:(range[1] - 1)))
            # Model.set_duration!(app.model, value)
            Model.set_simulation!(app.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.PushItemWidth(80)

        gui_data.buffer = string(Model.duration(app.model))
        returned = CImGui.InputText("Duration", gui_data.buffer, 50, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
        # println("enter: [", gui_data.buffer16, "]")
        # range = findfirst("\0", gui_data.buffer16)
        # value = String(SubString(gui_data.buffer16, 1:(range[1] - 1)))
        # Model.set_duration!(app.model, value)
            Model.set_duration!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(200)

        gui_data.buffer = string(Model.time_scale(app.model))
        returned = CImGui.InputText("Time Scale", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_time_scale!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(400)

        gui_data.buffer = string(Model.spans(app.model))
        returned = CImGui.InputText("Spans", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_spans!(app.model, gui_data.buffer)
        end

        gui_data.buffer = string(Model.range_start(app.model))
        returned = CImGui.InputText("Range Start", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_range_start!(app.model, gui_data.buffer)
        end
        CImGui.SameLine(300)

        gui_data.buffer = string(Model.range_end(app.model))
        returned = CImGui.InputText("Range End", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_range_end!(app.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()
    end
end