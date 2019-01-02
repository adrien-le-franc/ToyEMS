# developed with Julia 1.0.3
#
# generic struct items for EMS problems 

using Clustering

struct Grid{T<:Real}
	"""discretized space grid"""
	states::Array{StepRangeLen{T,Base.TwicePrecision{T},Base.TwicePrecision{T}}, 1}
end

Base.size(g::Grid) = Tuple([length(g.states[i]) for i in 1:length(g.states)])
Base.length(g::Grid) = length(size(g))
Base.getindex(g::Grid, i::Int) = g.states[i]

function grid_steps(g::Grid{T}) where T<:Real
	"""grid steps, assuming a regular space grid: return type Tuple"""
	dimension = length(size(g))
	grid_steps = [g.states[i][2] - g.states[i][1] for i in 1:dimension]
	Tuple(grid_steps)
end


struct Noise{T<:Real}
	"""discretized noise space with probabilities"""
	w::Array{T, 2}
	pw::Array{T, 2}
	function Noise{T}(w::Array{T, 2}, pw::Array{T, 2}) where T<:Real
		if size(w) != size(pw)
			error("noise size $(size(w)) not equal to probabilities size $(size(pw))")
		end
		new(w, pw)
	end
end

function Noise(w::Array{T, 2}, pw::Array{T, 2}) where T<:Real
	Noise{T}(w, pw)
end

function Noise(data::Array{T, 2}, k::Int64) where T<:Real

	"""dicretize noise space to k values using Kmeans: return type Noise
	data > time series data of dimension (horizon, n_data)
	k > Kmeans parameter

	"""

	horizon, n_data = size(data)
	w = zeros(horizon, k)
	pw = zeros(horizon, k)

	for t in 1:1:horizon
		w_t = reshape(data[t, :], (1, :))
		kmeans_w = kmeans(w_t, k)
		w[t, :] = kmeans_w.centers
		pw[t, :] = kmeans_w.cweights / n_data
	end

	return Noise{T}(w, pw)

end



