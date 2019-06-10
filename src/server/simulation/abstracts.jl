# BitStreams are streams of spikes. The spikes are generated several ways:
# 1) From virtual neurons
# 2) Interneurons (IN)s
# 3) external source. Ex images
# 4) Poisson generators

# BitStream as Stimulus is in motion:

# A stream has an optional input and an output.
# Represents a stream of spikes.
abstract type AbstractBitStream end

# -------------------------------------------------------------------------
# Axons
# -------------------------------------------------------------------------

# Axons have only one input and one output, and can have an optional
# delay.

# A stream's output is routed to a Axon's input.
# On each pass the input is "shifted" to the Axon's output.
# Some Axons have zero delay so the input/outputs are the same on
# each pass (aka DirectAxon)
#
# A simulation pass has a "pre" and post step.
# The "pre" step takes the output of a stream and places on the input.
# The "post" step shifts the input through the delay towards the output.
#
# A Axon's delay is a simple representation of distance.
abstract type AbstractAxon end


abstract type AbstractDelay end

abstract type AbstractCell end
abstract type AbstractSoma end
abstract type AbstractDendrite end
abstract type AbstractCompartment end
abstract type AbstractSynapse end
