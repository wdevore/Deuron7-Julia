mutable struct AppData
    # export window
    window::GLFW.Window
    ctx::Ptr{Nothing}
    clear_color::Array{Cfloat,1}
    show_demo_window::Bool
    show_another_window::Bool
    counter::Cint
    float_slide::Cfloat
    display_w::Int32
    display_h::Int32

    model::Model.ModelData

    buffer1024::String
    buffer32::String
    buffer16::String
    buffer8::String

    function AppData()
        o = new()

        o.model = Model.ModelData()

        o.buffer1024 = "" # "\0"^1024
        o.buffer32 = ""
        o.buffer16 = "" # "\0"^16
        o.buffer8 = "" # "1\0"^7

        o.window = GLFW.CreateWindow(WIDTH, HEIGHT, "Deuron7")
        @assert o.window != C_NULL
        GLFW.MakeContextCurrent(o.window)
        GLFW.SwapInterval(1)  # enable vsync

        o.ctx = CImGui.CreateContext()

        o.display_w, o.display_h = GLFW.GetFramebufferSize(o.window)

        # CImGui.StyleColorsDark()
        CImGui.StyleColorsClassic()
        # CImGui.StyleColorsLight()

        ImGui_ImplGlfw_InitForOpenGL(o.window, true)
        ImGui_ImplOpenGL3_Init(glsl_version)

        o.clear_color = Cfloat[0.45, 0.55, 0.60, 1.00]
        o.show_demo_window = true
        o.show_another_window = false
        
        o.counter = 0
        o.float_slide = 0.0
        o
    end
end

function load_data!(data::AppData)
    Model.load!(data.model, "../data/app.json")
end

function save_data(data::AppData)
    Model.save(data.model, "../data/app.json")
end