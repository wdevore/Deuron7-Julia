function draw_popup_window(app::Model.AppData, sock::Comm.SocClient)
    @c CImGui.Begin("Another Window", &app.show_another_window)  # pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
    CImGui.Text("Hello from another window!")
    CImGui.Button("Close Me") && (app.show_another_window = false;)
    CImGui.End()
end