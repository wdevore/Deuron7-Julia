#
# Graphs have a collapsable header and plotting area
# The header has fields for:
#   horizontal range, vertical range
#   cursor position,
#
# A graph renders data from a data collection.

module Graphs

using CImGui
using CImGui.CSyntax
using CImGui.CSyntax.CStatic
using CImGui.GLFWBackend
using CImGui.OpenGLBackend
using CImGui.GLFWBackend.GLFW
using CImGui.OpenGLBackend.ModernGL
using CImGui: ImVec2, ImVec4, IM_COL32, ImU32, ImColor
using Printf

using ..Gui

const GRAPH_WINDOW_WIDTH = Gui.GUI_WIDTH - 10
const GRAPH_WINDOW_HEIGHT = 200

const MAX_VERTICAL_BARS = 250
const LINE_THICKNESS = 1.0

const GRAY = 64
const YELLOW = IM_COL32(255, 255, 0, 255)
const GREEN = IM_COL32(0, 255, 0, 255)
const GREEN_TRAN = IM_COL32(0, 255, 0, 128)
const WHITE_TRAN = IM_COL32(255, 255, 255, 100)
const WHITE = IM_COL32(255, 255, 255, 255)
const LIME_GREEN = IM_COL32(166, 255, 77, 255)
const BLUE = IM_COL32(26, 209, 255, 255)
const ORANGE = IM_COL32(255, 128, 0, 255)
const LIGHT_BLUE = IM_COL32(121, 189, 232, 255)
const GREY = IM_COL32(100, 100, 100, 255)
const LIGHT_GREY = IM_COL32(200, 200, 200, 255)

abstract type AbstractGraph end

export linear, lerp

# linear returns 0->1 for a "value" between min and max.
# Generally used to map from view/data-space to unit-space
function linear(min::Float64, max::Float64, value::Float64)
   	if min < 0
        return 1.0 - ((value - max) / (min - max))
    end

   	(value - min) / (max - min)
end

# lerp returns a the value between min and max given t = 0->1
# Call linear() first to get "t".
# Generally used to map from unit-space to window-space.
# A graph will then map to local-space of the graph.
function lerp(min::Float64, max::Float64, t::Float64)
    min * (1.0 - t) + max * t
end

# Map from sample-space to unit-space where unit-space is 0->1
function map_sample_to_unit(v::Float64, min::Float64, max::Float64)
    linear(min, max, v) 
end

# Map from unit-space to window-space
function map_unit_to_window(v::Float64, min::Float64, max::Float64)
    lerp(min, max, v) 
end

# Local = graph-space
function map_window_to_local(x::Float64, y::Float64, offsets::CImGui.LibCImGui.ImVec2)
    (offsets.x + x, offsets.y + y)
end

function scroll_velocity(scroll::Float64)
    sign(scroll) * exp(sign(scroll) * scroll)
end

include("spike_scatter_graph.jl")
include("soma_ap_fast_graph.jl")
include("soma_ap_slow_graph.jl")
include("soma_psp_graph.jl")
include("synapse_weights_graph.jl")
include("synapse_surge_graph.jl")
include("synapse_psp_graph.jl")
include("synapse_input_graph.jl")

spikes_graph = Graphs.SpikeScatterGraph()
soma_apFast_graph = Graphs.SomaAPFastGraph()
soma_apSlow_graph = Graphs.SomaAPSlowGraph()
soma_psp_graph = Graphs.SomaPSPGraph()
synapse_weights_graph = Graphs.SynapseWeightGraph()
synapse_surge_graph = Graphs.SynapseSurgeGraph()
synapse_psp_graph = Graphs.SynapsePSPGraph()
synapse_input_graph = Graphs.SynapticInputGraph()

end # Module ---------------------------------------