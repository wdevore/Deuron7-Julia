
module Gui

using CImGui
using CImGui.CSyntax
using CImGui.CSyntax.CStatic
using CImGui.GLFWBackend
using CImGui.OpenGLBackend
using CImGui.GLFWBackend.GLFW
using CImGui.OpenGLBackend.ModernGL
using Printf
using JSON

const DISPLAY_RATIO = 16.0 / 9.0
const GUI_WIDTH = 1024 * 2 + 512 * 2
const GUI_HEIGHT = UInt32(Float64(GUI_WIDTH) / DISPLAY_RATIO)

using ..Model

include("init.jl")
include("gui_data.jl")
include("graphs/graphs.jl")

using .Graphs
using ..Comm

include("main_panel.jl")
include("popup_window.jl")

function run(gui_data::GuiData, app_data::Model.AppData, sock::Comm.SocClient)
    while !GLFW.WindowShouldClose(gui_data.window)
        
        GLFW.PollEvents()

        begin_render()

        draw_main_panel(gui_data, app_data, sock)

        # Graph rendering -----------------------------------------------------------
        vert_pos = 25

        # Renders boths stimulus and cell output spikes.
        Graphs.draw(Graphs.spikes_graph, gui_data::GuiData, app_data.model, app_data.samples, vert_pos)

        vert_pos += Graphs.GRAPH_WINDOW_HEIGHT + 20

        Graphs.draw(Graphs.soma_apFast_graph, gui_data::GuiData, app_data.model, app_data.samples, vert_pos)

        vert_pos += Graphs.GRAPH_WINDOW_HEIGHT
        Graphs.draw(Graphs.soma_apSlow_graph, gui_data::GuiData, app_data.model, app_data.samples, vert_pos)

        vert_pos += Graphs.GRAPH_WINDOW_HEIGHT
        Graphs.draw(Graphs.soma_psp_graph, gui_data::GuiData, app_data.model, app_data.samples, vert_pos)

        vert_pos += Graphs.GRAPH_WINDOW_HEIGHT
        Graphs.draw(Graphs.synapse_weights_graph, gui_data::GuiData, app_data.model, app_data.samples, vert_pos)

        vert_pos += Graphs.GRAPH_WINDOW_HEIGHT
        Graphs.draw(Graphs.synapse_surge_graph, gui_data::GuiData, app_data.model, app_data.samples, vert_pos)

        vert_pos += Graphs.GRAPH_WINDOW_HEIGHT
        Graphs.draw(Graphs.synapse_psp_graph, gui_data::GuiData, app_data.model, app_data.samples, vert_pos)
        # ----------------------------------------------------------------------------

        end_render(gui_data)
    
        # App communications
        Comm.read_channel(sock)
    end
end

function begin_render()
    # start the Dear ImGui frame
    ImGui_ImplOpenGL3_NewFrame()
    ImGui_ImplGlfw_NewFrame()
    CImGui.NewFrame()
end

function end_render(data::GuiData)
        # rendering
    CImGui.Render()
    GLFW.MakeContextCurrent(data.window)

    glViewport(0, 0, data.display_w, data.display_h)
    glClearColor(data.clear_color...)
    glClear(GL_COLOR_BUFFER_BIT)

    ImGui_ImplOpenGL3_RenderDrawData(CImGui.GetDrawData())
    
    GLFW.MakeContextCurrent(data.window)
    GLFW.SwapBuffers(data.window)
end

function shutdown(data::GuiData)
    println("Shutting down...")

    ImGui_ImplOpenGL3_Shutdown()
    ImGui_ImplGlfw_Shutdown()
    CImGui.DestroyContext(data.ctx)
    
    GLFW.DestroyWindow(data.window)
end

end # Module ---------------------------------------------