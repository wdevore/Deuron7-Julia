
module Gui

using CImGui
using CImGui.CSyntax
using CImGui.CSyntax.CStatic
using CImGui.GLFWBackend
using CImGui.OpenGLBackend
using CImGui.GLFWBackend.GLFW
using CImGui.OpenGLBackend.ModernGL
using Printf

const DISPLAY_RATIO = 16.0 / 9.0
const WIDTH = 1024 + 512
const HEIGHT = UInt32(Float64(WIDTH) / DISPLAY_RATIO)

using ..Model

include("init.jl")
include("app_data.jl")
include("callbacks.jl")
include("graphs/graphs.jl")

using ..Comm
using JSON
using .Graphs

include("main_panel.jl")
include("popup_window.jl")

function run(data::AppData, sock::Comm.SocClient)
    while !GLFW.WindowShouldClose(data.window)
        
        GLFW.PollEvents()

        begin_render()

        draw_main_panel(data, sock)

        Graphs.draw(data.spikes_graph)

        # if data.show_another_window
        #     draw_popup_window(data, sock)
        # end
    
        end_render(data)
    
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

function end_render(data::AppData)
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

function shutdown(data::AppData)
    println("Shutting down...")

    ImGui_ImplOpenGL3_Shutdown()
    ImGui_ImplGlfw_Shutdown()
    CImGui.DestroyContext(data.ctx)
    
    GLFW.DestroyWindow(data.window)
end

end # Module ---------------------------------------------