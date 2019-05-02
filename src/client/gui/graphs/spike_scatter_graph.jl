# This graph renders chains of Spikes
# Each spike is a vertical lines about N pixels in length
# Each row is seperated by ~2px.
# Poisson spikes are orange, AP spikes are green.
# Poisson is drawn first then AP.
#
# The samples are a 2D array: zeros(UInt8, synapses, duration)

mutable struct SpikeScatterGraph <: AbstractGraph
    poi_samples::Array{UInt8,2}

end

function append!(graph::SpikeScatterGraph, data::Array{UInt8,2})
    append!(graph.poi_samples, data)
end

function draw_header(graph::SpikeScatterGraph)
    
end

function draw(graph::SpikeScatterGraph)
    draw_header(graph)
    
end