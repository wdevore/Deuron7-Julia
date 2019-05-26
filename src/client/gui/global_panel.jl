function draw_global_panel(gui_data::GuiData, app_data::Model.AppData, sock::Comm.SocClient)
    if CImGui.CollapsingHeader("Global")
        CImGui.PushItemWidth(150)

        gui_data.buffer = Model.prep_field(Model.simulation(app_data.model), 50)
        returned = CImGui.InputText("Active Simulation", gui_data.buffer, 50, CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        # println(gui_data.buffer)
        if returned
            # println("enter: [", gui_data.buffer16, "]")
            # range = findfirst("\0", gui_data.buffer16)
            # value = String(SubString(gui_data.buffer16, 1:(range[1] - 1)))
            # Model.set_duration!(app.model, value)
            Model.set_simulation!(app_data.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()

        CImGui.PushItemWidth(80)

        gui_data.buffer = Model.prep_field(Model.duration(app_data.model), 20)
        returned = CImGui.InputText("Duration", gui_data.buffer, 20, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
        # println("enter: [", gui_data.buffer16, "]")
        # range = findfirst("\0", gui_data.buffer16)
        # value = String(SubString(gui_data.buffer16, 1:(range[1] - 1)))
        # Model.set_duration!(app.model, value)
            Model.set_duration!(app_data.model, gui_data.buffer)
        end
        CImGui.SameLine(200)

        gui_data.buffer = Model.prep_field(Model.time_scale(app_data.model), 10)
        returned = CImGui.InputText("Time Scale", gui_data.buffer, 10, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_time_scale!(app_data.model, gui_data.buffer)
        end
        CImGui.SameLine(400)

        gui_data.buffer = Model.prep_field(Model.spans(app_data.model), 10)
        returned = CImGui.InputText("Spans", gui_data.buffer, 10, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_spans!(app_data.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()
    end
end