
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
const WIDTH = 1024 + 512
const HEIGHT = UInt32(Float64(WIDTH) / DISPLAY_RATIO)

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

        Graphs.draw(Graphs.spikes_graph, gui_data::GuiData, app_data.model, app_data.samples)

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