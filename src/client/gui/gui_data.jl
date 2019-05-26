mutable struct GuiData
    # export window
    window::GLFW.Window
    ctx::Ptr{Nothing}
    clear_color::Array{Cfloat,1}
    counter::Cint
    float_slide::Cfloat
    display_w::Int32
    display_h::Int32

    show_warning_dialog::Bool

    buffer::String

    function GuiData()
        o = new()

        o.buffer = ""

        o.window = GLFW.CreateWindow(WIDTH, HEIGHT, "Deuron7")
        @assert o.window != C_NULL
        GLFW.MakeContextCurrent(o.window)
        GLFW.SwapInterval(1)  # enable vsync

        o.ctx = CImGui.CreateContext()

        o.display_w, o.display_h = GLFW.GetFramebufferSize(o.window)

        # CImGui.StyleColorsDark()
        CImGui.StyleColorsClassic()
        # CImGui.StyleColorsLight()

        fonts_dir = joinpath(@__DIR__, "../gui/", "fonts")
        fonts = CImGui.GetIO().Fonts
        CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "Roboto-Medium.ttf"), 20)

        ImGui_ImplGlfw_InitForOpenGL(o.window, true)
        ImGui_ImplOpenGL3_Init(glsl_version)

        o.clear_color = Cfloat[0.45, 0.55, 0.60, 1.00]
        o.show_warning_dialog = false
        
        o.counter = 0
        o.float_slide = 0.0
        
        o
    end
end