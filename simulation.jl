@time using Base.Threads
@time using Random, Statistics, StatsBase
@time using CSV, DataFrames
@time using Dates
using Profile
@time include("Config.jl")

#---

# @time using Plots
# colormap_RPS = cgrad([
#     colorant"#FF3333",
#     colorant"#33CC00",
#     colorant"#0066FF",
#     colorant"#FFCC00",
#     colorant"#9933CC",
#     colorant"#FFFFFF"], categorical = true)

# varying_p = ARGS[1]
varying_p = "5"
println("recieved: " * varying_p)
println(pwd())
println(Dates.now())

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
        
        # elseif right === 1 && (left === 2 || left === 4)
        #     return (0, 1)
        # elseif right === 2 && (left === 3 || left === 5)
        #     return (0, 2)
        # elseif right === 3 && (left === 4 || left === 1)
        #     return (0, 3)
        # elseif right === 4 && (left === 5 || left === 2)
        #     return (0, 4)
        # elseif right === 5 && (left === 1 || left === 3)
        #     return (0, 5)
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

const σ, μ = 1, 1

# ---
folder_name = "result" * varying_p
try; mkdir("result" * varying_p); catch; println("result" * varying_p * ": already exists"); end
try; mkdir("result" * varying_p * "/cases"); catch; println("result" * varying_p  * "/cases" * ": already exists"); end
# try; mkdir("temp"); catch; println("temp: already exists"); end
# try; mkdir("Entropy"); catch; println("Entropy: already exists"); end
# try; mkdir("Alive"); catch; println("Alive: already exists"); end

for T ∈ itr
Random.seed!(T)
println()
println("                           T: $T")
print('[')
for t ∈ itr
    if t ≤ T print('|') else print(' ') end
end
print(']')
println(' ' * lpad(T, 2, '0') * " / $(lpad(itr[end], 2, '0'))")

case = open(folder_name * "/itr" * lpad(T,3,'0') * ".csv", "a")
# println(case, "ε,p1,p2,p3,p4,p5,empty,alive,entropy5,entropy6"); close(case)
println(case, "ε,p,empty,alive,entropy6"); close(case)


for p ∈ p_range
for ε ∈ ε_range

cool_ε = replace(string(round(ε, digits =  3)), "//" => "／")
cool_p = replace(string(round(p, digits =  3)), "//" => "／")
cool = "ε = " * cool_ε * ", p = " * cool_p
# println("\n" * cool)

# ps = zeros(Float64, 5)
# ps[1:parse(Int64, varying_p)] .= p
# ps = [p,0,0,0,0]

Σ = (p + σ + μ + ε)
inter  = σ / Σ  # intraspecific competition
reprod = μ / Σ  # reproduction rate
intra  = p / Σ  # interspecific competition
exchan = ε / Σ  # exchange rate

# stage_lattice = zeros(Int64, L, L)
stage_lattice = rand(0:5, L, L)

A_ = zeros(Int64, endtime)
B_ = zeros(Int64, endtime)
C_ = zeros(Int64, endtime)
D_ = zeros(Int64, endtime)
E_ = zeros(Int64, endtime)
empty_ = zeros(Int64, endtime)
alive_ = zeros(Int64, endtime)
entropy6_ = zeros(Float64, endtime)

@time for t = 1:endtime
# snapshot = @animate for t = 1:endtime
    # if mod(t, 1000) === 0 print("|") end
    # if mod(t, 1000) === 0 println(t) end

    from_idx = rand(1:L, L^2, 2)
    temp = rand(Bool, L^2);
    to_idx = from_idx .+ (hcat(temp, .~(temp)) .* rand([-1,1], L^2, 2));
    to_idx = mod.(to_idx .- 1, L) .+ 1

    @inbounds for τ ∈ 1:(L^2)
        # i₁ = rand(1:L)
        # j₁ = rand(1:L)

        i₁, j₁ = from_idx[τ,1], from_idx[τ,2]
        left = stage_lattice[i₁, j₁]
        if left === 0 continue end

        # Δi, Δj = 0, 0
        # if rand([true, false])
        #     Δi = rand([-1,1])
        # else
        #     Δj = rand([-1,1])
        # end
        # i₂ = mod(i₁ + Δi - 1, L) + 1
        # j₂ = mod(j₁ + Δj - 1, L) + 1

        i₂, j₂ = to_idx[τ,1], to_idx[τ,2]
        right = stage_lattice[i₂, j₂]

        stage_lattice[i₁, j₁], stage_lattice[i₂, j₂] =
         action(left, right, inter, reprod, intra)
    
        # if T === 0
        #     figure = heatmap(stage_lattice, color=colormap_RPS,
        #     xaxis=false,yaxis=false,axis=nothing, size=[400, 400], legend=false)
        # end
        # if T === 1
        #     A_[t] = sum(stage_lattice .== 1)
        #     B_[t] = sum(stage_lattice .== 2)
        #     C_[t] = sum(stage_lattice .== 3)
        #     D_[t] = sum(stage_lattice .== 4)
        #     E_[t] = sum(stage_lattice .== 5)
        #     end_population = [A_[t], B_[t], C_[t], D_[t], E_[t]]
        #     total = sum(end_population)

        #     empty_[t] = L^2 - total
        #     alive_[t] = (A_[t] > 0) + (B_[t] > 0) + (C_[t] > 0) + (D_[t] > 0) + (E_[t] > 0)
        #     entropy6_[t] = entropy(push!(end_population, empty_[t]) ./ L^2, 6)

        #     if alive_[t] === 1
        #         A_[t:end] .= A_[t]
        #         B_[t:end] .= B_[t]
        #         C_[t:end] .= C_[t]
        #         D_[t:end] .= D_[t]
        #         E_[t:end] .= E_[t]
        
        #         empty_[t:end] .= empty_[t]
        #         alive_[t:end] .= alive_[t]
        #         entropy6_[t:end] .= entropy6_[t]
        #         break
        #     end
        # end

    end # for τ ∈ 1:(L^2)
end # for t = 1:endtime

A_[end] = sum(stage_lattice .== 1)
B_[end] = sum(stage_lattice .== 2)
C_[end] = sum(stage_lattice .== 3)
D_[end] = sum(stage_lattice .== 4)
E_[end] = sum(stage_lattice .== 5)
end_population = [A_[end], B_[end], C_[end], D_[end], E_[end]]
total = sum(end_population)

empty_[end] = L^2 - total
alive_[end] = (A_[end] > 0) + (B_[end] > 0) + (C_[end] > 0) + (D_[end] > 0) + (E_[end] > 0)
entropy6_[end] = entropy(push!(end_population, empty_[end]) ./ L^2, 6)

print(lpad(alive_[end],2))

if T === 0
    try
        gif(snapshot, "movie_" * cool * ".mp4", fps=24)
    catch LoadError
        println("스냅샷을 깜빡했습니다")
    end
elseif T === 1
    time_evolution = DataFrame(hcat(alive_, entropy6_, empty_, A_, B_, C_, D_, E_),
     ["alive_", "entropy6_", "empty_", "A_", "B_", "C_", "D_", "E_"])
    CSV.write(folder_name  * "/cases" * "/time_evolution" * cool * ".csv", time_evolution)
end
autosave = open(folder_name * "/autosave.csv", "a")
print(autosave, Dates.now())
# println(autosave, ",$T,$ε,$(string(p)[2:end-1]),$(empty_[end]),$(alive_[end]),$(entropy6_[end])")
println(autosave, ",$T,$ε,$p,$(empty_[end]),$(alive_[end]),$(entropy6_[end])")
close(autosave)

case = open(folder_name * "/itr" * lpad(T,3,'0') * ".csv", "a")
# println(case, "$ε,$(string(ps)[2:end-1]),$(empty_[end]),$(alive_[end]),$(entropy6_[end])")
println(case, "$ε,$p,$(empty_[end]),$(alive_[end]),$(entropy6_[end])")
close(case)
end # for ε ∈ ε_range
print("  "); println(Dates.now())
end # for p ∈ p_range

mv(folder_name * "/itr" * lpad(T,3,'0') * ".csv", folder_name * "/T" * lpad(T,3,'0') * ".csv")

end # for T ∈ itr
