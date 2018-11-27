# developed under  Julia 0.6.4
#
# functions for Stochastic Dynamic Programming 

using ProgressMeter

function compute_value_functions(train_noise, controls, states, dynamics, interpolation, price, T)

	"""compute value functions: return (T+1, length(states)) array
	train_noise > (w, p_w) both (T, K) arrays of K noise states w[t, :] of probability p_w[t, :]
	controls, states > 1-dim arrays of discretized spaces
	dynamics > function returning next states
	interpolation > fonction returning interpolated value function
	price > (T, ) array
	T > Int
	"""
   
    n_states = length(states)
    Δx = states[2]-states[1]
    xmin = states[1]
    xmax = states[end]
    xdict = Dict(states[i] => i for i in 1:1:num_states)
    value_function = zeros(T+1, n_states)
    
    @showprogress for t in T:-1:1
        
        noise = train_noise[1][t, :]
        p_noise = train_noise[2][t, :]
        p_t = price[t]
        
        for x in states
            
            expectation = 0
            
            for i in 1:1:length(noise)
               
                w = noise[i]
                p_w = p_noise[i]
                v = 10e8
                
                for u in controls
                    
                    next_state = dynamics(x, u)
                    if next_state < xmin || next_state > xmax
                        continue
                    end
                    if next_state in states
                        next_value_function = value_function[t+1, xdict[next_state]]
                    else next_value_function = interpolation(next_state, Δx, value_function[t+1, :])
                    end
                    v = min(v, p_t*max(0, w+u) + next_value_function)
                    
                end
                
                expectation += v*p_w
                
            end
            
            value_function[t, xdict[x]] = expectation
                   
        end
    
    end
    
    return value_function
    
end

function compute_online_trajectory(x0, noise, value_function, controls, states, dynamics, interpolation, prices, T)

	"""compute online trajectory: return (T, ) array of visited states, cost
	x0 > (admissible) init state
	noise > (T, ) array 
	value_function > (T+1, length(states)) array
	controls, states > 1-dim arrays of discretized spaces
	dynamics > function returning next states
	interpolation > fonction returning interpolated value function
	price > (T, ) array
	T > Int
	"""
   
    n_states = length(states)
    Δx = states[2]-states[1]
    xmin = states[1]
    xmax = states[end]
    xdict = Dict(states[i] => i for i in 1:1:num_states)
    cost = 0
    stock = [x0]
    x = x0
    
    for t in 1:1:T
        
        w = noise[t]
        p_t = price[t]
       
        vopt = 10e8
        uopt = 0
            
        for u in controls
            
            next_state = dynamics(x, u)
            if next_state < xmin || next_state > xmax
                continue
            end
            if next_state in states
                next_value_function = value_function[t+1, xdict[next_state]]
            else next_value_function = interpolation(next_state, Δx, value_function[t+1, :])
            end

            v = p_t*max(0, w+u) + next_value_function
            if v < vopt

                vopt = v
                uopt = u
            
            end
            
        end
        
        x = dynamics(x, uopt)
        append!(stock, x)
        cost += p_t*max(0, w+uopt)
        
    end
    
    return stock, cost
    
end