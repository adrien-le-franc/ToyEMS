# developed with Julia 1.0.3
#
# functions for interpolation on a grid space

using LinearAlgebra

include("struct.jl")

function nadaraya_watson_estimator(g::Grid, point::Union{T, Array{T, 1}}, f::Array{T}, 
	dimension::Int64, sigma::Float64, neighbor_inf::Array{Int64, 1}, 
	neighbor_steps::Array{Array{Int64,1},1}) where T<:Real

	"""nadaraya watson estimator with gaussian kernel: return type T
	g, point, f > see interpolate function
	dimension > space dimension
	sigma > kernel width parameter
	neighbor_inf > origin of hypercube neighborhood
	neighbor_steps > steps to reach neighbors from origin

	"""

	f_hat = 0
	sum_kernel = 0

	for step in Iterators.product(neighbor_steps...)

		coordinates = neighbor_inf + collect(step)
		neighbor = [g[i][coordinates[i]] for i in 1:dimension]
		value = f[coordinates...]
		square_distance = (point.-neighbor)'*(point.-neighbor)
		kernel = exp(-square_distance/(2*sigma^2))

		f_hat += value*kernel
		sum_kernel += kernel

	end

	return f_hat

end

function local_linear_regression(g::Grid, point::Union{T, Array{T, 1}}, f::Array{T}, 
	dimension::Int64, sigma::Float64, neighbor_inf::Array{Int64, 1}, 
	neighbor_steps::Array{Array{Int64,1},1}) where T<:Real

	"""weighted least square with gaussian kernel: return type T
	g, point, f > see interpolate function
	dimension > space dimension
	sigma > kernel width parameter
	neighbor_inf > origin of hypercube neighborhood
	neighbor_steps > steps to reach neighbors from origin

	"""

	kernel = zeros(0)
	x = zeros(0)
	y = zeros(0)

	for step in Iterators.product(neighbor_steps...)

		coordinates = neighbor_inf + collect(step)
		neighbor = [g.states[i][coordinates[i]] for i in 1:dimension]
		value = f[coordinates...]
		square_distance = (point.-neighbor)'*(point.-neighbor)

		append!(kernel, exp(-square_distance/(2*sigma^2)))
		append!(y, value)
		append!(x, vcat(1, neighbor))

	end

	x = reshape(x, (dimension+1, 2^dimension))'
	diag = Diagonal(kernel)

	beta = pinv(x'*diag*x)*x'*diag*y

	return beta'*vcat(1, point)

end

function interpolate(g::Grid, point::Union{T, Array{T, 1}}, f::Array{T}; 
	h::Float64=1/sqrt(5), order::Int64=1) where T<:Real

	"""interpolate function: return type T
	g > discretized space grid
	point > point for interpolation
	f > values of function on the grid
	h > neighborhood width factor to parametrize sigma in the kernel
	order > order of interpolation, implemented: 0, 1

	"""

	if !(order in [0, 1])
		throw(ArgumentError("implemented interpolation order: 0, 1"))
	end

	dimension = length(g)
	delta = grid_steps(g)
	neighbor_inf = zeros(Int, dimension)
	neighbor_steps = [[0, 1] for x in 1:dimension]
	sigma = sqrt(sum([dx^2 for dx in delta])) * h

	for i in 1:dimension

		x = point[i]
		xmin = g.states[i][1]
		xmax = g.states[i][end]

		if x < xmin || x > xmax
			throw(error("interpolation argument must be within the grid"))
		elseif x == xmin
			neighbor_inf[i] = 1
			continue
		elseif x == xmax
			neighbor_inf[i] = size(g)[i] - 1
			continue
		end

		x_inf = Int(floor((x-xmin)/delta[i])) + 1
		neighbor_inf[i] = x_inf

	end

	if order == 0
		return nadaraya_watson_estimator(g, point, f, dimension, sigma, neighbor_inf, neighbor_steps)
	elseif order == 1
		return local_linear_regression(g, point, f, dimension, sigma, neighbor_inf, neighbor_steps)
	end

end

