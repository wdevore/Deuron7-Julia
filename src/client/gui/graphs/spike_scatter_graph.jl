# This graph renders chains of Spikes
# Each spike is a vertical lines about N pixels in length
# Each row is seperated by ~2px.
# Poisson spikes are orange, AP spikes are green.
# Poisson is drawn first then AP.
#
# The samples are a 2D array: zeros(UInt8, synapses, duration)

mutable struct SpikeScatterGraph <: AbstractGraph
    poi_samples::Array{UInt8,2}

    function SpikeScatterGraph()
        o = new()

        o
    end
end

function append!(graph::SpikeScatterGraph, data::Array{UInt8,2})
    append!(graph.poi_samples, data)
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
const LINE_THICKNESS = 1.0

function draw_spikes(graph::SpikeScatterGraph, draw_list::Ptr{CImGui.LibCImGui.ImDrawList}, canvas_pos::CImGui.LibCImGui.ImVec2, canvas_size::CImGui.LibCImGui.ImVec2)
    CImGui.PushClipRect(draw_list, canvas_pos, 
        ImVec2(canvas_pos.x + canvas_size.x, canvas_pos.y + canvas_size.y), true) # clip lines within the canvas (if we resize it, etc.)

    # Map screen to local
    # canvas_pos.x + local.x...
    
    CImGui.AddLine(draw_list, 
        ImVec2(canvas_pos.x + 1.0, canvas_pos.y + 1.0), 
        ImVec2(canvas_pos.x + 200.0, canvas_pos.y + 200.0), 
        YELLOW, LINE_THICKNESS)

    CImGui.PopClipRect(draw_list)

end

function draw_graph(graph::SpikeScatterGraph)
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

    draw_spikes(graph, draw_list, canvas_pos, canvas_size)
end

function draw(graph::SpikeScatterGraph)
    CImGui.SetNextWindowSize((1000, 300), CImGui.ImGuiCond_Always)

    CImGui.Begin("Spike Graph")
    
    draw_header(graph)

    CImGui.Separator()

    draw_graph(graph)

    CImGui.End()
end