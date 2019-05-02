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

include("spike_scatter_graph.jl")

end # Module ---------------------------------------