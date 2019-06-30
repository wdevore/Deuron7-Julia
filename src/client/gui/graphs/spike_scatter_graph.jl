using ...Model
using ..Gui

# This graph renders chains of Spikes
# Each spike is a vertical lines about N pixels in height
# Each row is seperated by ~2px.
# Poisson spikes are orange, AP spikes are green.
# Poisson is drawn first then AP.
#
# Graph is shaped like this:
#      .----------------> +X
#  1   :  |   ||     |   | |       ||     |
#  2   :    |   |   ||     ||     |    |        <-- a row ~2px height
#  3   :   |    |    |         | |   |     |
#      v
#      +Y
#
# Only the X-axis is mapped Y is simply a height is graph-space.
#
# This graph also shows the Neuron's Post spike (i.e. the output of the neuron)

mutable struct SpikeScatterGraph <: AbstractGraph
    show_vertical_t_bar_markers::Bool
    time_pos::Int64
    show_poission_data::Bool
    show_stimulus_data::Bool

    function SpikeScatterGraph()
        o = new()
        # TODO capture model data here to save time.
        o.show_vertical_t_bar_markers = false
        o.show_poission_data = true
        o.show_stimulus_data = true
        o
    end
end

function draw_header(graph::SpikeScatterGraph, gui_data::Gui.GuiData, model::Model.ModelData)
    if CImGui.TreeNode("Controls##1")
        # CImGui.PushItemWidth(80)
        # # Row 1 *****************************************************
        # gui_data.buffer = Model.prep_field(Model.range_start(model), 10)
        # returned = CImGui.InputText("Range Start##1", gui_data.buffer, 10, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        # if returned
        #     Model.set_range_start!(model, gui_data.buffer)
        # end
        # CImGui.SameLine(250)

        # gui_data.buffer = Model.prep_field(Model.range_end(model), 10)
        # returned = CImGui.InputText("Range End##1", gui_data.buffer, 10, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        # if returned
        #     Model.set_range_end!(model, gui_data.buffer)
        # end
        # CImGui.PopItemWidth()

        duration = Cint(Model.duration(model))
        begin_v = Cint(Model.range_start(model))
        end_v = Cint(Model.range_end(model))
        @c CImGui.DragIntRange2("Range##1", &begin_v, &end_v, 1, 1, duration, "Start: %d", "End: %d")
        if Int64(begin_v) > 0 && Int64(end_v) <= duration
            if Int64(begin_v) < Int64(end_v)
                Model.set_range_start!(model, Int64(begin_v))
                Model.set_range_end!(model, Int64(end_v))
            end
        end

        pos = Cfloat(0.0) #Cfloat(Model.window_position(model))
        @c CImGui.SliderFloat("Scroll velocity", &pos, -5.0, 5.0, "%.2f")
        Model.set_scroll!(model, Float64(pos))

        @c CImGui.Checkbox("Poisson Data", &graph.show_poission_data)
        CImGui.SameLine(250)
        @c CImGui.Checkbox("Stimulus Data", &graph.show_stimulus_data)

        range_start = Model.range_start(model)
        range_end = Model.range_end(model) # duration
        range = range_end - range_start
    
        if range < MAX_VERTICAL_BARS # Limit bars to less than 500 because Drawlist is limited to 2^16 items.
            @c CImGui.Checkbox("Vertical Time Bars", &graph.show_vertical_t_bar_markers)
        else
            graph.show_vertical_t_bar_markers = false
        end

        CImGui.TreePop()
    end
end

const SPIKE_ROW_OFFSET = 2 # Adds a gap between rows
const SPIKE_HEIGHT = 10
const CELL_SPIKE_HEIGHT = 30
const CELL_LINE_THICKNESS = 2.0

function draw_spikes(graph::SpikeScatterGraph, gui_data::Gui.GuiData,
    draw_list::Ptr{CImGui.LibCImGui.ImDrawList},
    canvas_pos::CImGui.LibCImGui.ImVec2, canvas_size::CImGui.LibCImGui.ImVec2,
    model::Model.ModelData, samples::Model.Samples)

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

    CImGui.PushClipRect(draw_list, canvas_pos, ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y), true) # clip lines within the canvas (if we resize it, etc.)

    # ------------------------------------------------------------------------
    # Mouse vertical tracking and markers
    # ------------------------------------------------------------------------
    mouse_pos = CImGui.GetMousePos()
    mpx = mouse_pos.x

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

    # ------------------------------------------------------------------------
    # Render poisson spikes
    # ------------------------------------------------------------------------
    # Tracks a spike row.
    if graph.show_poission_data
        w_y = 1.0 # Offset from border. 0 is underneath it.

        # A span is a collection of rows (aka synapses)
        for id in 1:synapses
            # Narrow down to a single row by id
            synaptic_samples = samples.poi_samples[id, :]
            # if model.bug println("synaptic_samples: ", synaptic_samples) end

            # Iterate samples with the defined range.
            for t in range_start:range_end
                if synaptic_samples[t] == 1 # A spike = 1
                    # The sample value needs to be mapped
                    u_x = map_sample_to_unit(Float64(t), Float64(range_start), Float64(range_end))
                    w_x = map_unit_to_window(u_x, 0.0, canvas_width)
                    (l_x, l_y) = map_window_to_local(w_x, w_y, canvas_pos)
                    # if model.bug print(l_x, ",") end

                    CImGui.AddLine(draw_list,
                    ImVec2(l_x, l_y), 
                    ImVec2(l_x, l_y + SPIKE_HEIGHT), 
                    YELLOW, LINE_THICKNESS)
                end

                # if model.bug println("vt: ", vt) end
            end

            # Update row/y value and offset by a few pixels
            w_y += SPIKE_HEIGHT + SPIKE_ROW_OFFSET
        end
    end
    # ------------------------------------------------------------------------

    # model.bug = false

    # ------------------------------------------------------------------------
    # Render stimulus spikes
    # ------------------------------------------------------------------------
    if graph.show_stimulus_data
        w_y = 1.0 # Offset from border. 0 is underneath it.

        # A span is a collection of rows (aka synapses)
        for id in 1:synapses
            # Narrow down to a single row by id
            synaptic_samples = samples.stimulus_samples[id, :]
            # if model.bug println("synaptic_samples: ", synaptic_samples) end

            # Iterate samples with the defined range.
            for t in range_start:range_end
                if synaptic_samples[t] == 1 # A spike = 1
                    # The sample value needs to be mapped
                    u_x = map_sample_to_unit(Float64(t), Float64(range_start), Float64(range_end))
                    w_x = map_unit_to_window(u_x, 0.0, canvas_width)
                    (l_x, l_y) = map_window_to_local(w_x, w_y, canvas_pos)

                    CImGui.AddLine(draw_list,
                    ImVec2(l_x, l_y), 
                    ImVec2(l_x, l_y + SPIKE_HEIGHT), 
                    LIME_GREEN, LINE_THICKNESS)
                end
            end

            # Update row/y value and offset by a few pixels
            w_y += SPIKE_HEIGHT + SPIKE_ROW_OFFSET
        end
    end

    # ------------------------------------------------------------------------
    # Render soma/cell spikes
    # ------------------------------------------------------------------------

    synaptic_samples = samples.cell_samples.samples

    # Iterate samples with the defined range.
    for t in range_start:range_end
        if synaptic_samples[t] == 1 # A spike = 1
            # The sample value needs to be mapped
            u_x = map_sample_to_unit(Float64(t), Float64(range_start), Float64(range_end))
            w_x = map_unit_to_window(u_x, 0.0, canvas_width)
            (l_x, l_y) = map_window_to_local(w_x, w_y, canvas_pos)

            CImGui.AddLine(draw_list,
                ImVec2(l_x, l_y), 
                ImVec2(l_x, l_y + CELL_SPIKE_HEIGHT), 
                WHITE, CELL_LINE_THICKNESS)
        end
    end

    CImGui.PopClipRect(draw_list)
end
# if model.bug print("") end

function draw_graph(graph::SpikeScatterGraph, gui_data::Gui.GuiData, model::Model.ModelData, samples::Model.Samples)
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
        CImGui.Text(@sprintf("%d", graph.time_pos))
        CImGui.EndTooltip()
    end
    
    CImGui.AddRect(draw_list, canvas_pos, 
        ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y),
        IM_COL32(128, 128, 128, 255))


    draw_spikes(graph, gui_data, draw_list, canvas_pos, canvas_size, model, samples)
end

function draw(graph::SpikeScatterGraph, gui_data::Gui.GuiData, model::Model.ModelData, samples::Model.Samples, vert_pos::Int64)
    # CImGui.SetNextWindowPos((0, 25), CImGui.ImGuiCond_Once)
    CImGui.SetNextWindowPos((0, vert_pos), CImGui.ImGuiCond_Once)
    CImGui.SetNextWindowSize((GRAPH_WINDOW_WIDTH, GRAPH_WINDOW_HEIGHT + 20), CImGui.ImGuiCond_Always)

    CImGui.Begin("Spike Graph")
    
    draw_header(graph, gui_data, model)

    CImGui.Separator()

    draw_graph(graph, gui_data, model, samples)

    CImGui.End()
end

