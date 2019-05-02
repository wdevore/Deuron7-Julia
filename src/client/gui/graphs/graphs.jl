#
# Graphs have a collapsable header and plotting area
# The header has fields for:
#   horizontal range, vertical range
#   cursor position,
#
# A graph renders data from a data collection.

module Graphs

abstract type AbstractGraph end

include("spike_scatter_graph.jl")

end # Module ---------------------------------------