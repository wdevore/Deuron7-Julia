# In this simulation the synapse is the smallest component.
# A synapse is feed by a StreamMerger's output

const INITIAL_PRE_T = 0.0 # -1000000000.0

mutable struct Synapse <: AbstractSynapse
    soma::AbstractSoma
    dendrite::AbstractDendrite
    compartment::AbstractCompartment
   	model::Model.ModelData

    id::Int64

    # true = excititory, false = inhibitory
    excititory::Bool

    # The weight of the synapse
    w::Float64
    
    wMax::Float64
   	wMin::Float64

    # The stream (aka Merger) that feeds into this synapse
    stream::AbstractBitStream

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Surge
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Surge base value
   	amb::Float64

	# Surge peak
   	ama::Float64

	# Surge window
   	tsw::Float64

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# new surge ion concentration
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# concentration base. We should always have a minimum concentration
	# as a result of a spike
	# Surge is calculated at the arrival of a spike
	# surge = amb - ama*e^(-psp/tsw) == rising curve
   	surge::Float64

	# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

	# The time-mark at which a spike arrived at a synapse
   	preT::Float64

	# The current ion concentration
    psp::Float64
       
	# =============================================================
	# Learning rules:
	# =============================================================
	#
	# Depression pair-STDP, Potentiation is triplet.
	# "tao"s control the rate of decay. Larger values means a slower decay.
	# Smaller values equals a sharper decay.
	# -----------------------------------

	# denominator, positive window time decay
   	taoP::Float64

	# denominator, negative window time decay
   	taoN::Float64

	# Ratio of mRate/taoX
   	tao::Float64

	# -----------------------------------
	# Weight dependence
	# -----------------------------------
	# F-(w) = λ⍺w^µ, F+(w) = λ(1-w)^µ
   	mu::Float64 # µ
   	lambda::Float64 # λ
   	alpha::Float64 # ⍺

	# -----------------------------------
	# Suppression
	# -----------------------------------
   	taoI::Float64
   	prevEffTrace::Float64

   	learningRateSlow::Float64
   	learningRateFast::Float64

	# -----------------------------------
	# Fall off
	# -----------------------------------
   	distanceEfficacy::Float64
   	distance::Float64       

    function Synapse(soma::AbstractSoma, dendrite::AbstractDendrite, compartment::AbstractCompartment, model::Model.ModelData)
        o = new()
        o.model = model
        o.soma = soma
        o.dendrite = dendrite
        o.compartment = compartment
        o.excititory = true # default to excite type
        o.preT = INITIAL_PRE_T
        o.id = 0
        add_synapse!(compartment, o)

        o
    end
end

function set_stream!(syn::Synapse, stream::AbstractBitStream)
   	syn.stream = stream
end

function set_as_inhibit!(syn::Synapse)
    syn.excititory = false
end

function initialize!(syn::Synapse)
	# Focus the model on the correct synapse.
   	Model.set_active_synapse!(syn.model, syn.id)

	# Set properties based on model. These drive the other properties.
   	syn.taoP = Model.taoP(syn.model)
   	syn.taoN = Model.taoN(syn.model)
   	syn.mu = Model.mu(syn.model)
   	syn.distance = Model.distance(syn.model)
   	syn.lambda = Model.lambda(syn.model)
   	syn.amb = Model.amb(syn.model)
   	syn.w = Model.weight(syn.model)
   	syn.alpha = Model.alpha(syn.model)
   	syn.learningRateFast = Model.learning_rate_fast(syn.model)
   	syn.learningRateSlow = Model.learning_rate_slow(syn.model)
   	syn.taoI = Model.taoI(syn.model)
   	syn.ama = Model.ama(syn.model)

	# Calc this synapses's reaction to the AP based on its
	# distance from the soma.
   	syn.distanceEfficacy = AP_efficacy(syn.compartment.dendrite, syn.distance)

   	syn.wMax = Model.w_max(syn.model)
   	syn.wMin = Model.w_min(syn.model)
end

# Reset properties to default values from model.
function reset!(syn::Synapse)
   	syn.prevEffTrace = 1.0
   	syn.surge = 0.0
   	syn.psp = 0.0
    syn.preT = 0.0
       
	# Reset weights back to best guess values.
    syn.wMax = syn.compartment.weight_max
   	syn.w = syn.wMax / syn.compartment.weight_divisor
end

# This is considered the 1st pass of the simulation per time step.
# Each "pass" is broken up into several steps.
# Internal values are 'moved' to the outputs.
# Learning rules are applied.
# Prepare for next integration step
function pre_integrate!(syn::Synapse)
end

# The main integration. Returns a float value
function integrate!(syn::Synapse, t::Int64)
    triplet_integration(syn, t)
end

function post_integrate!(syn::Synapse)
end

# =============================================================
# Triplet:
# =============================================================
# Pre trace, Post slow and fast traces.
#
# Depression: fast post trace with at pre spike
# Potentiation: slow post trace at post spike
function triplet_integration(syn::Synapse, t::Int64)
	# Calc psp based on current dynamics: (t - preT). As dt increases
	# psp will decrease asymtotically to zero.
    dt = Float64(t) - syn.preT
    
   	dwD = 0.0
   	dwP = 0.0
   	updateWeight = false

	# The output of the stream is the input to this synapse.
	# The stream is almost always a StreamMerger
   	if output(syn.stream) == 1
       	# println("(", t, ") syn: ", syn.id)
       	if syn.excititory
            syn.surge = syn.psp + syn.ama * exp(-syn.psp / syn.taoP)
       	else 
            syn.surge = syn.psp + syn.ama * exp(-syn.psp / syn.taoN)
        end

		# #######################################
		# Depression LTD
		# #######################################
		# Read post trace and adjust weight accordingly.
        dwD = syn.prevEffTrace * weight_factor(syn, false) * syn.soma.apFast

        syn.prevEffTrace = efficacy(syn, dt)

        syn.preT = t
        dt = 0.0

        updateWeight = true
    end

   	if syn.excititory
        syn.psp = syn.surge * exp(-dt / syn.taoP)
   	else
        syn.psp = syn.surge * exp(-dt / syn.taoN)
    end

	# If an AP occurred (from the soma) we read the current psp value and add it to the "w"
   	if output(syn.soma) == 1.0
		# #######################################
		# Potentiation LTP
		# #######################################
		# Read pre trace (aka psp) and slow AP trace for adjusting weight accordingly.
		#     Post efficacy                                          weight dependence                 triplet sum
        dwP = efficacy_trace(syn.soma) * syn.distanceEfficacy * weight_factor(syn, true) * (syn.psp + syn.soma.apSlowPrior)
        updateWeight = true
    end

	# Finally update the weight.
   	if updateWeight
        syn.w = max(min(syn.w + dwP - dwD, syn.wMax), syn.wMin)
    end

	# Return the "value" of this synapse for this "t"
   	value = if syn.excititory 
       	syn.psp * syn.w
   	else
       	-syn.psp * syn.w # is inhibitory
   	end

	# Collecting is centralized in streams.jl for consistency.
   	collect_synapse!(syn.soma.samples, syn, t)

   	value
end

# Each spike of pre-synaptic neuron j sets the presynaptic spike
# efficacy j to 0
# whereafter it recovers exponentially to 1 with a time constant
# τj = toaJ
# In other words, the efficacy of a spike is suppressed by
# the proximity of a previous spike.
function efficacy(syn::Synapse, dt)
   	1 - exp(-dt / syn.taoI)
end

# mu = 0.0 = additive, mu = 1.0 = multiplicative
function weight_factor(syn::Synapse, potentiation::Bool)
    if potentiation 
        return syn.lambda * ((1 - syn.w / syn.wMax)^syn.mu)
   	end

   	syn.lambda * syn.alpha * ((syn.w / syn.wMax)^syn.mu)
end
