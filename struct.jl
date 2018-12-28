# developed with Julia 1.0.3
#
# generic struct items for EMS problems 


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
