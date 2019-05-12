include("neuron_panel.jl")
include("poisson_panel.jl")
include("synapse_panel.jl")

function draw_simulation_panel(gui_data::GuiData, data::Model.AppData, sock::Comm.SocClient)
    if CImGui.CollapsingHeader("Simulation")
        CImGui.PushItemWidth(80)

        gui_data.buffer = string(Model.stimulus_scaler(data.model))
        returned = CImGui.InputText("Stimulus Scaler", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            # println("enter: [", app.buffer, "]")
            # range = findfirst("\0", app.buffer)
            # value = String(SubString(app.buffer, 1:(range[1] - 1)))
            # Model.set_duration!(app.model, value)
            Model.set_stimulus_scaler!(data.model, gui_data.buffer)
        end
        CImGui.SameLine(300)

        gui_data.buffer = string(Model.hertz(data.model))
        returned = CImGui.InputText("Hertz (ISI)", gui_data.buffer, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        if returned
            Model.set_hertz!(data.model, gui_data.buffer)
        end

        CImGui.PopItemWidth()
        
        # Poisson panel ************************************************
        draw_poisson_panel(gui_data, data, sock)

        draw_neuron_panel(gui_data, data, sock)

        draw_synapse_panel(gui_data, data, sock)
    end
end