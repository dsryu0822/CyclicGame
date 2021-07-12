@time using Base.Threads
@time using Random, Statistics, StatsBase
@time using CSV, DataFrames
@time using Dates
@time include("Config.jl")

#---

# @time using Profile
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
# println("recieved: " * varying_p)
println(pwd())
println(Dates.now())

# ---
folder_name = "result" * varying_p
try; mkdir("result" * varying_p); catch; println("result" * varying_p * ": already exists"); end
try; mkdir("result" * varying_p * "/cases"); catch; println("result" * varying_p  * "/cases" * ": already exists"); end

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
println(case, "date,T,earlystop,ε,p,empty,alive,entropy6"); close(case)

# for (p, ε) ∈ [10. .^(-1,-1), 10. .^(+1,0), 10. .^(-1,0), 10. .^(-1,+1)]
# for (p, ε) ∈ zip(p_range, ε_range)
for p ∈ p_range
@threads for ε ∈ ε_range

cool_ε = replace(string(round(ε, digits =  3)), "//" => "／")
cool_p = replace(string(round(p, digits =  3)), "//" => "／")
cool = "ε = " * cool_ε * ", p = " * cool_p
# println("\n" * cool)

Σ = (p + σ + μ + ε)
inter  = σ / Σ  # intraspecific competition
reprod = μ / Σ  # reproduction rate
intra  = p / Σ  # interspecific competition
exchan = ε / Σ  # exchange rate

stage_lattice = rand(0:5, L, L)

A_ = zeros(Int64, endtime)
B_ = zeros(Int64, endtime)
C_ = zeros(Int64, endtime)
D_ = zeros(Int64, endtime)
E_ = zeros(Int64, endtime)
empty_ = zeros(Int64, endtime)
alive_ = zeros(Int64, endtime)
entropy6_ = zeros(Float64, endtime)

earlycount = 0
earlystop = copy(endtime)

@time for t = 1:endtime
# snapshot = @animate for t = 1:endtime

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
        end # for τ ∈ 1:(L^2)
    
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


    if (mod(t, L) === 1) && (t > L)
        A_[t] = sum(stage_lattice .== 1)
        B_[t] = sum(stage_lattice .== 2)
        C_[t] = sum(stage_lattice .== 3)
        D_[t] = sum(stage_lattice .== 4)
        E_[t] = sum(stage_lattice .== 5)

        l1 = sum(abs.([
          A_[t] - A_[t-L],
          B_[t] - B_[t-L],
          C_[t] - C_[t-L],
          D_[t] - D_[t-L],
          E_[t] - E_[t-L]]))

        if l1 < (L÷10)^2
            earlycount += 1
        end
        if earlycount > 5
            println("early stopping!")
            earlystop = t
            break
        end
    end
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

# print(lpad(alive_[end],2))

# if T === 0
#     try
#         gif(snapshot, "movie_" * cool * ".mp4", fps=24)
#     catch LoadError
#         println("스냅샷을 깜빡했습니다")
#     end
# end
# if T === 1
#     time_evolution = DataFrame(hcat(alive_, entropy6_, empty_, A_, B_, C_, D_, E_),
#      ["alive_", "entropy6_", "empty_", "A_", "B_", "C_", "D_", "E_"])
#     CSV.write(folder_name  * "/cases" * "/time_evolution" * cool * ".csv", time_evolution)
# end
autosave = open(folder_name * "/autosave.csv", "a")
print(autosave, Dates.now())
println(autosave, ",$T,$earlystop,$ε,$p,$(empty_[end]),$(alive_[end]),$(entropy6_[end])")
close(autosave)

case = open(folder_name * "/itr" * lpad(T,3,'0') * ".csv", "a")
print(case, Dates.now())
println(case, ",$T,$earlystop,$ε,$p,$(empty_[end]),$(alive_[end]),$(entropy6_[end])")
close(case)

end # for p, ε ∈ ...

# end # for ε ∈ ε_range
# print("  "); println(Dates.now())
# end # for p ∈ p_range

try
    mv(folder_name * "/itr" * lpad(T,3,'0') * ".csv", folder_name * "/T" * lpad(T,3,'0') * ".csv", force=true)
catch
    println("itr*.csv 파일이 T*.csv 파일로 변경되지 못했습니다")
end

end # for T ∈ itr