using ...Model

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
# The graph shows only a few spans at any one time.
# |<------------------------------ Duration --------------------------->|
# |<--- Span ---><--- Span ---><--- Span ---><--- Span ---><--- Span --->
# |              |<-------------- Graph view -------------|
#
# The graph only shows up to 3 spans at a time.

mutable struct SpikeScatterGraph <: AbstractGraph
    function SpikeScatterGraph()
        o = new()
        # TODO capture model data here to save time.
        o
    end
end

function draw_header(graph::SpikeScatterGraph)
    if CImGui.TreeNode("Controls##1")
        CImGui.PushItemWidth(80)

        # Row 1 *****************************************************
        buff = ""
        returned = CImGui.InputText("Window Start##1", buff, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        CImGui.SameLine(250)

        returned = CImGui.InputText("Window End##1", buff, 16, CImGui.ImGuiInputTextFlags_CharsDecimal | CImGui.ImGuiInputTextFlags_EnterReturnsTrue)
        # if returned
        #     Model.set_ap_max!(app.model, app.buffer)
        # end

        CImGui.PopItemWidth()
    
        CImGui.TreePop()
    end
end

const GRAY = 64
const YELLOW = IM_COL32(255, 255, 0, 255)
const GREEN = IM_COL32(0, 255, 0, 255)
const LINE_THICKNESS = 1.0
const WINDOW_WIDTH = 1000
const WINDOW_HEIGHT = 300
const SPIKE_ROW_OFFSET = 2 # Adds a gap between rows
const SPIKE_HEIGHT = 10

function draw_spikes(graph::SpikeScatterGraph, 
    draw_list::Ptr{CImGui.LibCImGui.ImDrawList},
    canvas_pos::CImGui.LibCImGui.ImVec2, canvas_size::CImGui.LibCImGui.ImVec2,
    model::Model.ModelData, samples::Model.Samples)
    CImGui.PushClipRect(draw_list, canvas_pos, 
        ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y), true) # clip lines within the canvas (if we resize it, etc.)

    # We can't render anything until the model has been loaded.
    if !Model.is_loaded(model)
        return
    end
    
    synapses = Model.synapses(model)
    span_time = Model.span_time(model)
    duration = Model.duration(model)
    duration_f = Float64(Model.duration(model))
    canvas_width = Float64(canvas_size.x)

    # We define y in window-space
    u_x = 0.0
    w_x = 0.0
    if model.bug println("duration: ", duration) end

    w_y = 1.0 # Offset from border. 0 is underneath.
    # A span is a collection of rows (aka synapse lanes)
    for id in 1:synapses
        # if model.bug println("id: ", id) end
        # Look for spikes to be drawn.
        for t in 1:duration
            if samples.poi_samples[id, t] == 1
                u_x = map_sample_to_unit(Float64(t), 0.0, duration_f)
                w_x = map_unit_to_window(u_x, 0.0, canvas_width)
                (l_x, l_y) = map_window_to_local(w_x, w_y, canvas_pos)
                if model.bug print(l_x, ",") end

                CImGui.AddLine(draw_list,
                    ImVec2(l_x, l_y), 
                    ImVec2(l_x, l_y + SPIKE_HEIGHT), 
                    YELLOW, LINE_THICKNESS)
            end
        end
        w_y += SPIKE_HEIGHT + SPIKE_ROW_OFFSET
    end

    model.bug = false

    CImGui.PopClipRect(draw_list)

end
function draw_spikes2(graph::SpikeScatterGraph, 
    draw_list::Ptr{CImGui.LibCImGui.ImDrawList},
    canvas_pos::CImGui.LibCImGui.ImVec2, canvas_size::CImGui.LibCImGui.ImVec2,
    model::Model.ModelData, samples::Model.Samples)
    CImGui.PushClipRect(draw_list, canvas_pos, 
        ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y), true) # clip lines within the canvas (if we resize it, etc.)

    # We can't render anything until the model has been loaded.
    if !Model.is_loaded(model)
        return
    end
    
    synapses = Model.synapses(model)
    span_time = Model.span_time(model)
    duration = Float64(Model.span_time(model))
    canvas_width = Float64(canvas_size.x)

    # We define y in window-space
    u_x = 0.0
    w_x = 0.0
    te = span_time

    # Process each span in order
    for span in samples.spans
        w_y = 1.0 # Offset from border. 0 is underneath.
        # A span is a collection of rows (aka synapse lanes)
        for id in 1:synapses
            # Look for spikes to be drawn.
            for t in 1:te
                if span[id, t] == 1
                    u_x = map_sample_to_unit(Float64(t), 0.0, duration)
                    w_x = map_unit_to_window(u_x, 0.0, canvas_width)
                    (l_x, l_y) = map_window_to_local(w_x, w_y, canvas_pos)

                    CImGui.AddLine(draw_list,
                        ImVec2(l_x, l_y), 
                        ImVec2(l_x, l_y + SPIKE_HEIGHT), 
                        YELLOW, LINE_THICKNESS)
                end
            end
            w_y += SPIKE_HEIGHT + SPIKE_ROW_OFFSET
        end

        te += span_time
        model.bug = false
    end

    CImGui.PopClipRect(draw_list)

end
# if model.bug print("") end

function draw_graph(graph::SpikeScatterGraph, model::Model.ModelData, samples::Model.Samples)
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

    CImGui.AddRectFilledMultiColor(draw_list, canvas_pos, 
        ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y),
        IM_COL32(GRAY, GRAY, GRAY, 255), IM_COL32(GRAY, GRAY, GRAY, 255),
        IM_COL32(GRAY, GRAY, GRAY, 255), IM_COL32(GRAY, GRAY, GRAY, 255))

    CImGui.AddRect(draw_list, canvas_pos, 
        ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y),
        IM_COL32(128, 128, 128, 255))

    draw_spikes(graph, draw_list, canvas_pos, canvas_size, model, samples)
end

function draw(graph::SpikeScatterGraph, model::Model.ModelData, samples::Model.Samples)
    CImGui.SetNextWindowSize((WINDOW_WIDTH, WINDOW_HEIGHT), CImGui.ImGuiCond_Always)

    CImGui.Begin("Spike Graph")
    
    draw_header(graph)

    CImGui.Separator()

    draw_graph(graph, model, samples)

    CImGui.End()
end

# Map from sample-space to unit-space where unit-space is 0->1
function map_sample_to_unit(x::Float64, min::Float64, max::Float64)
    linear(min, max, x) 
end

# Map from unit-space to window-space
function map_unit_to_window(x::Float64, min::Float64, max::Float64)
    lerp(min, max, x) 
end

# Local = graph-space
function map_window_to_local(x::Float64, y::Float64, offsets::CImGui.LibCImGui.ImVec2)
    (offsets.x + x, offsets.y + y)
end

