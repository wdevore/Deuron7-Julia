# Contains: start, stop

function draw_main_panel(app::AppData, sock::Comm.SocClient)
    CImGui.SetNextWindowPos((0, 0), CImGui.ImGuiCond_Once)

    # we use a Begin/End pair to create a named window.
    CImGui.Begin("Main panel")  # create a window panel and append into it.
    # CImGui.Text("This is some useful text.")  # display some text
    # @c CImGui.Checkbox("Demo Window", &app.show_demo_window)  # edit bools storing our window open/close state
    # @c CImGui.Checkbox("Another Window", &app.show_another_window)
    
    # @c CImGui.SliderFloat("float", &app.float_slide, 0, 1)  # edit 1 float using a slider from 0 to 1
    # CImGui.ColorEdit3("clear color", app.clear_color)  # edit 3 floats representing a color
    # CImGui.Separator()

    # CImGui.Text(@sprintf("counter %d", app.counter))
    CImGui.Text(@sprintf("Status: %.3f ms/frame (%.1f FPS)", 1000 / CImGui.GetIO().Framerate, CImGui.GetIO().Framerate))
    CImGui.Separator()

    if CImGui.Button("Load")
        # app.counter += 1
        Model.load(app.model, "../data/app.json")
    end

    CImGui.SameLine()
    if CImGui.Button("Simulate")
        # app.counter += 1
        Comm.send(sock, "Channel::Cmd::Simulate")
    end
    CImGui.SameLine()

    if CImGui.Button("Stop")
        Comm.send(sock, "Channel::Cmd::Stop")
    end
    CImGui.SameLine()

    if CImGui.Button("Shutdown")
        Comm.send(sock, "Channel::Cmd::Shutdown server")
    end
    # CImGui.SameLine()

    if CImGui.CollapsingHeader("Global")
        if CImGui.TreeNode("Neuron")
            # str3 =  " " * "\0"^(16)
            # buf = Cstring(pointer(str3))
            # buf = "\0"^16
            returned = CImGui.InputText("Tao", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
            # if returned
            #     println("enter: [", app.buffer16, "]")
            # end
            # CImGui.InputText("Tao", app.buffer16, 16, CImGui.ImGuiInputTextFlags_CharsDecimal)
            # println("enter: [", app.buffer16, "]")
            CImGui.TreePop()
        end
    end

    CImGui.End()
end
