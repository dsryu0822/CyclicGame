const L = 100
itr = 0:96

resolution = 20
ε_log10M = range(0., 3., length = resolution); ε_range = (10. .^ ε_log10M)
p_log10M = range(-3., 0., length = resolution); p_range = (10. .^ p_log10M)
# ε_range = [1]
# p_range = [1]

endtime = 1(L^2)
# T = 10^2
# endtime = T

const σ, μ = 1, 1

function action(left::Int64, right::Int64,
    inter::Float64, reprod::Float64, intra::Float64
    )::Tuple{Int64, Int64}
probability = rand()
if probability < inter
if     left === 1 && (right === 2 || right === 4)
return (1, 0)
elseif left === 2 && (right === 3 || right === 5)
return (2, 0)
elseif left === 3 && (right === 4 || right === 1)    
return (3, 0)
elseif left === 4 && (right === 5 || right === 2)
return (4, 0)
elseif left === 5 && (right === 1 || right === 3)
return (5, 0)
end
elseif probability < inter + reprod
if     (left === 1 && right === 0) # || (right === 1 && left === 0)
return (1, 1)
elseif (left === 2 && right === 0) # || (right === 2 && left === 0)
return (2, 2)
elseif (left === 3 && right === 0) # || (right === 3 && left === 0)
return (3, 3)
elseif (left === 4 && right === 0) # || (right === 4 && left === 0)
return (4, 4)
elseif (left === 5 && right === 0) # || (right === 5 && left === 0)
return (5, 5)
end
elseif probability < inter + reprod + intra
if     left === right
# if rand([true, false])
    return (left, 0)
# else
#     return (0, right)
# end
end
else
return (right, left) # exchange
end

return (left, right)
end