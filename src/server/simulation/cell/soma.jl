mutable struct Soma <: AbstractSoma
   	model::Model.ModelData
	
   # Axon is the output
    axon::AbstractAxon
   	dendrite::AbstractDendrite

	# Soma threshold. When exceeded an AP is generated.
   	threshold::Float64

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
        
   	function Soma(axon::AbstractAxon, model::Model.ModelData)
       	o = new()
       	o.axon = axon
       	o.model = model
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

   	initialize!(soma.dendrite)
end

function reset!(soma::AbstractSoma)
   	soma.apFast = 0.0
   	soma.apSlow = 0.0
   	soma.preT = -1000000000000000.0
   	soma.refractoryState = false
   	soma.refractoryCnt = 0
   	soma.nSlowSurge = 0.0
   	soma.nFastSurge = 0.0
   	soma.output = 0.0
   	soma.prevOutput = 0.0
    soma.efficacyTrace = 0.0
    
    reset!(soma.dendrite)
end