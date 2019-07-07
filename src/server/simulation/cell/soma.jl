mutable struct Soma <: AbstractSoma
   	model::Model.ModelData
   	samples::Model.Samples

   # Axon is the output
   	axon::AbstractAxon

   	dendrite::AbstractDendrite

	# Soma threshold. When exceeded an AP is generated.
   	threshold::Float64
	# Post synaptic potential
   	psp::Float64

	# --------------------------------------------------------
	# Action potential
	# --------------------------------------------------------
	# AP can travel back down the dendrite. The value decays
	# with distance.
   	apFast::Float64 # Fast trace
   	apSlow::Float64 # Slow trace
   	apSlowPrior::Float64 # Slow trace (t-1)

	# The time-mark of the current AP.
   	APt::Float64
	# The previous time-mark
   	preAPt::Float64
   	APMax::Float64

	# --------------------------------------------------------
	# STDP
	# --------------------------------------------------------
	# -----------------------------------
	# AP decay
	# -----------------------------------
   	ntao::Float64 # fast trace
   	ntaoS::Float64 # slow trace

	# Fast Surge
   	nFastSurge::Float64
   	nDynFastSurge::Float64
   	nInitialFastSurge::Float64

	# Slow Surge
   	nSlowSurge::Float64
   	nDynSlowSurge::Float64
   	nInitialSlowSurge::Float64

	# The time-mark at which a spike arrived at a synapse
   	preT::Float64

    refractoryPeriod::Float64
    refractoryCnt::Float64
    refractoryState::Bool
   
	# -----------------------------------
	# Suppression
	# -----------------------------------
   	ntaoJ::Float64
    efficacyTrace::Float64
        
    function Soma(axon::AbstractAxon, model::Model.ModelData, samples::Model.Samples)
        o = new()
        o.axon = axon
        o.model = model
        o.samples = samples
        o
    end
end

function initialize!(soma::AbstractSoma)
	# Set properties based on model. These drive the other properties.
   	soma.refractoryPeriod = Model.refractory_period(soma.model)
   	soma.nInitialFastSurge = Model.fast_surge(soma.model)
   	soma.nInitialSlowSurge = Model.slow_surge(soma.model)
   	soma.ntao = Model.tao(soma.model)
   	soma.ntaoS = Model.tao_s(soma.model)
   	soma.ntaoJ = Model.tao_j(soma.model)
   	soma.threshold = Model.threshold(soma.model)
   	soma.APMax = Model.ap_max(soma.model)
    # println(soma.nInitialFastSurge, ", ", soma.nInitialSlowSurge, ", ", soma.ntao, ", ", soma.ntaoS)

   	println("___ Soma properties ___")
    println("| refractoryPeriod: ", soma.refractoryPeriod)
    println("| nInitialFastSurge: ", soma.nInitialFastSurge)
    println("| nInitialSlowSurge: ", soma.nInitialSlowSurge)
    println("| ntao: ", soma.ntao)
    println("| ntaoS: ", soma.ntaoS)
    println("| ntaoJ: ", soma.ntaoJ)
    println("| threshold: ", soma.threshold)
    println("| APMax: ", soma.APMax)
    println("---------------------------")

   	initialize!(soma.dendrite)
end

function reset!(soma::AbstractSoma)
   	# print_trace(stacktrace(), "")
    soma.apFast = 0.0
    soma.apSlow = 0.0
    soma.preT = -1000000000000000.0
    soma.refractoryState = false
    soma.refractoryCnt = 0
    soma.nSlowSurge = 0.0
    soma.nFastSurge = 0.0
    soma.efficacyTrace = 0.0

   	reset!(soma.axon)
    reset!(soma.dendrite)
end

function integrate!(soma::AbstractSoma, span_t::Int64, t::Int64)
   	dt = t - soma.preT

   	soma.efficacyTrace = efficacy(soma, dt)

	# The dendrite will return a value that affects the soma.
    soma.psp = integrate!(soma.dendrite, span_t, t)

	# Default state
    set!(soma.axon, UInt8(0)) # Set output

    if soma.refractoryState
		# this algorithm should be the same as for the synapse or at least very
		# close.

        if soma.refractoryCnt >= soma.refractoryPeriod 
            soma.refractoryState = false
            soma.refractoryCnt = 0
			# fmt.Printf("Refractory ended at (%d)\n", int(t))
        else 
            soma.refractoryCnt += 1
        end
    else
        if soma.psp > soma.threshold
			# An action potential just occurred.
			# TODO Handle depolarization

            soma.refractoryState = true

			# TODO
			# Generate a back propagating spike that fades spatial/temporally similar to CaDP model.
			# This spike affects forward in time.
			# The value is driven by the time delta of (preAPt - APt)
           	set!(soma.axon, UInt8(1)) # Set output

			# Surge from action potential
            soma.nFastSurge = soma.APMax + soma.apFast * soma.nInitialFastSurge * exp(-soma.apFast / soma.ntao)
            soma.nSlowSurge = soma.APMax + soma.apSlow * soma.nInitialSlowSurge * exp(-soma.apSlow / soma.ntaoS)

			# Reset time deltas
            soma.preT = t
            dt = 0
        end
   	end
	
	# Prior is for triplet
   	soma.apSlowPrior = soma.apSlow
    # println(soma.nFastSurge, ", ", soma.nSlowSurge, ", ", soma.ntao, ", ", soma.ntaoS)
   	soma.apFast = soma.nFastSurge * exp(-dt / soma.ntao)
   	soma.apSlow = soma.nSlowSurge * exp(-dt / soma.ntaoS)

	# Collecting is centralized in streams.jl for consistency.
   	collect!(soma.samples, soma, span_t)

   	output(soma.axon)
end

function output(soma::AbstractSoma)
   	output(soma.axon)
end

# This is a time based property NOT distance.
# Each spike of the neuron i sets the post spike efficacy j to 0
# whereafter it recovers exponentially to 1 with a time constant toaI.
# In other words, the efficacy of a spike is suppressed by
# the proximity of a previous post spike.
function efficacy_trace(soma::AbstractSoma)
   	soma.efficacyTrace
end

function efficacy(soma::AbstractSoma, dt::Float64)
   	1.0 - exp(-dt / soma.ntaoJ)
end

