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
using CImGui: ImVec2, ImVec4, IM_COL32, ImU32
using Printf

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

include("spike_scatter_graph.jl")

spikes_graph = Graphs.SpikeScatterGraph()

end # Module ---------------------------------------