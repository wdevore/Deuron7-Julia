using ...Model
using ..Gui

# Data is a list of floats. This graph connects them end to end forming
# a curve.
mutable struct SynapseSurgeGraph <: AbstractGraph
    show_vertical_t_bar_markers::Bool
    time_pos::Int64
    value::Float64

    function SynapseSurgeGraph()
        o = new()
        o.show_vertical_t_bar_markers = false
        o
    end
end

function draw_header(graph::SynapseSurgeGraph, gui_data::Gui.GuiData, model::Model.ModelData)
    if CImGui.TreeNode("Controls##6")
        CImGui.PushItemWidth(1000)

        duration = Cint(Model.duration(model))
        begin_v = Cint(Model.range_start(model))
        end_v = Cint(Model.range_end(model))
        @c CImGui.DragIntRange2("Range##6", &begin_v, &end_v, 1, 1, duration, "Start: %d", "End: %d")
        if Int64(begin_v) > 0 && Int64(end_v) <= duration
            if Int64(begin_v) < Int64(end_v)
                Model.set_range_start!(model, Int64(begin_v))
                Model.set_range_end!(model, Int64(end_v))
            end
        end

        pos = Cfloat(0.0)
        @c CImGui.SliderFloat("Scroll velocity", &pos, -5.0, 5.0, "%.2f")
        Model.set_scroll!(model, Float64(pos))

        range_start = Model.range_start(model)
        range_end = Model.range_end(model) # duration
        range = range_end - range_start
    
        if range < MAX_VERTICAL_BARS # Limit bars to less than 500 because Drawlist is limited to 2^16 items.
            @c CImGui.Checkbox("Vertical Time Bars", &graph.show_vertical_t_bar_markers)
        else
            graph.show_vertical_t_bar_markers = false
        end

        CImGui.PopItemWidth()

        CImGui.TreePop()
    end
end

function draw_data(graph::SynapseSurgeGraph, gui_data::Gui.GuiData,
    draw_list::Ptr{CImGui.LibCImGui.ImDrawList},
    canvas_pos::CImGui.LibCImGui.ImVec2, canvas_size::CImGui.LibCImGui.ImVec2,
    model::Model.ModelData, samples::Model.Samples)
    CImGui.PushClipRect(draw_list, canvas_pos, 
        ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y), true) # clip lines within the canvas (if we resize it, etc.)

    # We can't render anything until the model has been loaded
    # ALONG with the samples.
    if !Model.is_loaded(model)
        return
    end
    
    io = CImGui.GetIO()

    synapses = Model.synapses(model)
    span_time = Model.span_time(model)
    duration = Model.duration(model)
    canvas_width = Float64(canvas_size.x)
    canvas_height = Float64(canvas_size.y)

    # ------------------------------------------------------------------------
    # Adjust range_start and range_end
    # ------------------------------------------------------------------------
    range_start = Model.range_start(model)
    range_end = Model.range_end(model)
    range = range_end - range_start
    # Use window_position (0.0->1.0) to Lerp Range-start and Range-end.
    scroll = Model.scroll(model)

    velocity = scroll_velocity(scroll)

    if scroll < 0
        range_start += velocity
        # Left
        if range_start > 0
            range_end = range_start + range
        else
            range_start = 1
            range_end = range_start + range
        end
    elseif scroll > 0
        range_end += velocity
        if range_end < duration
            range_start = range_end - range
        else
            range_end = duration
            range_start = range_end - range
        end
    end
    range_start = Int64(round(range_start))
    if range_start < 1
        range_start = 1
        range_end = range_start + range
    end

    range_end = Int64(round(range_end))

    # Reflect values back to model
    Model.set_range_start!(model, Int64(round(range_start)))
    Model.set_range_end!(model, Int64(round(range_end)))
    # ------------------------------------------------------------------------

    # ------------------------------------------------------------------------
    # Mouse vertical tracking and markers
    # ------------------------------------------------------------------------
    mouse_pos = CImGui.GetMousePos()
    mpx = mouse_pos.x

    # Get weight samples based on active synapse
    syn_id = Model.active_synapse(model)
    data_samples = samples.syn_surge_samples.data[syn_id]
    
    # Mapped data coords
    u_x = 0.0
    w_x = 0.0
    pl_vx = 0.0
    # time_pos tracks the actual time regardless of scrolling so it always
    # starts at the current range start value.
    time_pos = range_start

    # "t" is a counter over the range "size". time_pos is the actual
    # time value capture for the tooltip
    for t in 1:range
        # We want the markers to track with time as well, so we map "t".
        u_x = map_sample_to_unit(Float64(t), 0.0, Float64(range))
        w_x = map_unit_to_window(u_x, 0.0, canvas_width)
        (l_x, l_y) = map_window_to_local(w_x, 0.0, canvas_pos)

        if mpx > pl_vx && mpx < l_x
            CImGui.AddLine(draw_list,
                ImVec2(l_x, l_y),
                ImVec2(l_x, l_y + canvas_size.y),
                LIGHT_GREY, LINE_THICKNESS)
            graph.time_pos = time_pos + 1
            graph.value = data_samples.samples[graph.time_pos]
        else
            # Show vertical bars for visual references.
            if graph.show_vertical_t_bar_markers
                CImGui.AddLine(draw_list,
                    ImVec2(l_x, l_y),
                    ImVec2(l_x, l_y + canvas_size.y),
                    GREY, LINE_THICKNESS)
            end
        end

        pl_vx = l_x # Capture previous value for interval testing
        time_pos += 1
    end
    # ------------------------------------------------------------------------
    s_y = 0.0
    pl_y = 0.0 # previously mapped y value
    pl_x = 0.0 # previously mapped x value

    # ------------------------------------------------------------------------
    # Render segmented curve
    # ------------------------------------------------------------------------

    # Iterate samples with the defined range. "t" is mapped as "x" coord
    for t in range_start:range_end
        s_y = data_samples.samples[t]

        # The sample value needs to be mapped
        u_x = map_sample_to_unit(Float64(t), Float64(range_start), Float64(range_end))
        u_y = map_sample_to_unit(s_y, data_samples.min, data_samples.max)

        w_x = map_unit_to_window(u_x, 0.0, canvas_width)
        # graph space has +Y downward, but the data is oriented as +Y upward
        # so we flip in unit-space.
        u_y = 1.0 - u_y
        w_y = map_unit_to_window(u_y, 0.0, canvas_height)
        (l_x, l_y) = map_window_to_local(w_x, w_y, canvas_pos)

        CImGui.AddLine(draw_list,
            ImVec2(pl_x, pl_y), ImVec2(l_x, l_y), 
            ORANGE, LINE_THICKNESS)

        # if model.bug println("vt: ", vt) end
        pl_x = l_x
        pl_y = l_y
    end

    # if model.bug print(l_x, ",") end
    # model.bug = false
    # Show the min/max values of the data.
    CImGui.AddText(draw_list, ImVec2(5 + canvas_pos.x, 3 + canvas_pos.y), WHITE_TRAN, @sprintf("%3.3f", data_samples.max))
    CImGui.AddText(draw_list, ImVec2(5 + canvas_pos.x, canvas_pos.y + canvas_size.y - 20), WHITE_TRAN, @sprintf("%3.3f", data_samples.min))
    
    CImGui.PopClipRect(draw_list)

end
# if model.bug print("") end

function draw_graph(graph::SynapseSurgeGraph, gui_data::Gui.GuiData, model::Model.ModelData, samples::Model.Samples)
    draw_list = CImGui.GetWindowDrawList()
    canvas_pos = CImGui.GetCursorScreenPos()            # ImDrawList API uses screen coordinates!
    canvas_size = CImGui.GetContentRegionAvail()        # resize canvas to what's available

    cx, cy = canvas_size.x, canvas_size.y
    if cx < 50.0 
        cx = 50.0
    end
    if cy < 50.0 
        cy = 50.0
    end
    canvas_size = ImVec2(cx, cy)
    # A visible button scaled to the size of the canvas is used for hover checking
    CImGui.InvisibleButton("canvas", canvas_size)

    CImGui.AddRectFilledMultiColor(draw_list, canvas_pos, 
        ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y),
        IM_COL32(GRAY, GRAY, GRAY, 255), IM_COL32(GRAY, GRAY, GRAY, 255),
        IM_COL32(GRAY, GRAY, GRAY, 255), IM_COL32(GRAY, GRAY, GRAY, 255))

    if CImGui.IsItemHovered()
        CImGui.BeginTooltip()
        CImGui.Text(@sprintf("%d (%4.3f)", graph.time_pos, graph.value))
        CImGui.EndTooltip()
    end
    
    CImGui.AddRect(draw_list, canvas_pos, 
        ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y),
        IM_COL32(128, 128, 128, 255))

    draw_data(graph, gui_data, draw_list, canvas_pos, canvas_size, model, samples)
end

function draw(graph::SynapseSurgeGraph, gui_data::Gui.GuiData, model::Model.ModelData, samples::Model.Samples, vert_pos::Int64)
    CImGui.SetNextWindowPos((0, vert_pos), CImGui.ImGuiCond_Once)
    CImGui.SetNextWindowSize((GRAPH_WINDOW_WIDTH, GRAPH_WINDOW_HEIGHT), CImGui.ImGuiCond_Always)

    CImGui.Begin("Synapse Surge Graph")
    
    draw_header(graph, gui_data, model)

    CImGui.Separator()

    draw_graph(graph, gui_data, model, samples)

    CImGui.End()
end

