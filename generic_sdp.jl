# developed with Julia 1.0.3
#
# functions for Stochastic Dynamic Programming 

using ProgressMeter, IterTools


function admissible_state(x, states)
	"""check if x is in states: return a boolean

	x > state point
	states > discretized state space

	"""

	for i in length(x)

		if x[i] < states[i][1]
			return false
		elseif x[i] > states[i][end]
			return false
		end

	end

	return true

end

function is_on_grid(x, states)
	"""check if x is a grid node of states: return a boolean

	x > state point
	states > discretized state space as Tuple of ranges e.g. (1:10, 1:10)

	"""

	for i in length(x)

		if !(x[i] in states[i])
			return false
		end

	end

	return true

end

function state_dictionary(states)
	"""compute Dict mapping state values to positions in the state grid: return Dict(x=>coordinates)

	states > discretized space as Tuple of ranges e.g. (1:10, 1:10)

	"""

	xdict = Dict()
	enumerate_states = [enumerate(x) for x in states]
	for iterator in product(enumerate_states...)

		coordinates = [i[1] for i in iterator]
		x = [i[2] for i in iterator]
		xdict[x] = coordinates

	end

	return xdict

end

function compute_value_functions(train_noise::Union{Noise{T}, Array{Noise{T}}}, controls::Grid{T}, states::Grid{T}, xdict, dynamics::Function, cost::Function, price::Array{T}, horizon::Int64)

	"""compute value functions: return Dict(1=>Array ... horizon=>Array)

	train_noise > noise training data
	controls, states > discretized control and state spaces
	xdict > Dict mapping states to positions in value_function 
	dynamics > function(x, u, w) returning next state
	cost > function returning stagewise cost
	price > (T, :) Array
	H > time horizon

	"""

	state_size = dimension(states)
	control_size = dimension(controls)
	noise_dim = length(train_noise)

	value_function = Dict()
	value_function[T+1] = zeros(state_size...)

	@showprogress for t in T:-1:1

		w_t = train_noise[t]
		noises = [zip(w_t[i][1], w_t[i][2]) for i in 1:noise_dim]
		price = price[t, :]

		for x in product(states...)

			expectation = 0

			for iterator in product(noises...)

				w = [i[1] for  i in iterator]
				p_w = prod([i[2] for  i in iterator])
				v = 10e8

				for u in product(controls...)

					next_state = dynamics(x, u, w)

					if !admissible_state(next_state, states)
						continue
					end

					if is_on_grid(next_state, states)
						next_value_function = value_function[t+1][xdict[next_state]]
					else
						next_value_function = interpolation(next_state, states, value_function[t+1])
					end

					v = min(v, cost(price, x, u, w) + next_value_function)

				end

				expectation += w*p_w

			end

			value_function[t][xdict[x]...] = expectation

		end

	end

	return value_function

end

function compute_online_policy(x, w, price, controls, cost, interpolation, xdict, value_function)

	"""compute online policy: return optimal control at state x observing w

	x > current state
	w > observed noise 
	price > price at current stage
	controls > discretized space as Tuple of ranges e.g. (1:10, 1:10)
	cost > function returning stagewise cost
	interpolation > fonction returning interpolated value function
	xdict > Dict mapping states to positions in value_function 
	value_function > multi dimensional array

	"""

	vopt = 10e8
    uopt = 0
        
    for u in product(controls...)
        
        next_state = dynamics(x, u, w)

		if !admissible_state(next_state, states)
			continue
		end

		if is_on_grid(next_state, states)
			next_value_function = value_function[t+1][xdict[next_state]]
		else
			next_value_function = interpolation(next_state, states, value_function[t+1])
		end

        v = cost(price, x, u, w) + next_value_function

        if v < vopt

            vopt = v
            uopt = u
        
        end
        
    end
    
    return uopt, vopt

end