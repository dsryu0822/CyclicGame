@time using Base.Threads
@time using Random, Statistics, StatsBase
@time using CSV, DataFrames
@time using Plots, Dates

# @time using CUDA
# CUDA.versioninfo()
# CUDA.functional()

# cd("E:/RPS")
println(pwd())
println(Dates.now())

function action(left::Char, right::Char,
                inter::Real, reprod::Real, intra::Real
                )::Tuple{Char, Char}
    probability = rand()
    if probability < inter
        if     left == 'A' && (right == 'B' || right == 'D')
            return ('A', '∅')
        elseif left == 'B' && (right == 'C' || right == 'E')
            return ('B', '∅')
        elseif left == 'C' && (right == 'D' || right == 'A')    
            return ('C', '∅')
        elseif left == 'D' && (right == 'E' || right == 'B')
            return ('D', '∅')
        elseif left == 'E' && (right == 'A' || right == 'C')
            return ('E', '∅')
        
        # elseif right == 'A' && (left == 'B' || left == 'D')
        #     return ('∅', 'A')
        # elseif right == 'B' && (left == 'C' || left == 'E')
        #     return ('∅', 'B')
        # elseif right == 'C' && (left == 'D' || left == 'A')
        #     return ('∅', 'C')
        # elseif right == 'D' && (left == 'E' || left == 'B')
        #     return ('∅', 'D')
        # elseif right == 'E' && (left == 'A' || left == 'C')
        #     return ('∅', 'E')
        end
    elseif probability < inter + reprod
        if     (left == 'A' && right == '∅') # || (right == 'A' && left == '∅')
            return ('A', 'A')
        elseif (left == 'B' && right == '∅') # || (right == 'B' && left == '∅')
            return ('B', 'B')
        elseif (left == 'C' && right == '∅') # || (right == 'C' && left == '∅')
            return ('C', 'C')
        elseif (left == 'D' && right == '∅') # || (right == 'D' && left == '∅')
            return ('D', 'D')
        elseif (left == 'E' && right == '∅') # || (right == 'E' && left == '∅')
            return ('E', 'E')
        end
    elseif probability < inter + reprod + intra
        if     left == right
            # if rand([true, false])
                return (left, '∅')
            # else
            #     return ('∅', right)
            # end
        end
    else
        return (right, left) # exchange
    end

    return (left, right)
end

colormap_RPS = [
  colorant"#FF3333",
  colorant"#33CC00",
  colorant"#0066FF",
  colorant"#FFCC00",
  colorant"#9933CC",
  colorant"#FFFFFF"]
idx = Dict('A' => 1,
           'B' => 2,
           'C' => 3,
           'D' => 4,
           'E' => 5)

L = 100
row_size = column_size = L + 4
# ε_range = [0, 1//10,1,10]
# p_range = [0, 1//10,1,10]

ε_range = p_range = (2//1) .^ (-5:5)
# ε_range = p_range = [1//1]

endtime = 10000
itr = 1:16
# log10M = range(-10., -1., length = 10)
# EPSILON = 2(10. .^ log10M)*(L^2)

global autosave = open("autosave.csv", "a")
global bifurcation = open("bifurcation.csv", "a")

try

for ε ∈ ε_range
for p ∈ p_range

cool_ε = replace(string(ε), "//" => "／")
cool_p = replace(string(p), "//" => "／")
cool = " ε = " * cool_ε * ", p = " * cool_p
println(cool)

σ = μ = 1//1
p = Rational.([p,p,p,p,p])
# p = Rational.([1,1,1,1,1])

Σ = p .+ (σ + μ + ε)
inter  = σ ./ Σ  # intraspecific competition
reprod = μ ./ Σ  # reproduction rate
intra  = p ./ Σ  # interspecific competition
exchan = ε ./ Σ  # exchange rate
println(join([inter, reprod, intra, exchan], ", "))

print(autosave, Dates.now())
# realization = Float64[]
ENTROPY_ = zeros(Float64, length(itr))

@threads for T ∈ itr
Random.seed!(T)
stage_lattice = fill('∅', row_size, column_size)

stage_lattice[3:(row_size - 2), 3:(column_size - 2)] =
    (rand(['∅', 'A','B','C','D','E'], row_size - 4, column_size -4))

stage_lattice[1, 1] = 'A'
stage_lattice[1, 2] = 'B'
stage_lattice[1, 3] = 'C'
stage_lattice[1, 4] = 'D'
stage_lattice[1, 5] = 'E'

A_ = zeros(Int64, endtime)
B_ = zeros(Int64, endtime)
C_ = zeros(Int64, endtime)
D_ = zeros(Int64, endtime)
E_ = zeros(Int64, endtime)
entropy_ = zeros(Float64, endtime)

for t = 1:endtime
# snapshot = @animate for t = 1:endtime
    if mod(t, 10) == 0 print("|") end
    # if mod(t, 1000) == 0 println(t) end
    
    for τ ∈ 1:(L^2)
        j = rand(3:(row_size - 2))
        i = rand(3:(column_size - 2))
        left = stage_lattice[i,j]
        if left == '∅' break end

        Δi, Δj = 0, 0
        if rand([true, false])
            Δi = rand([-1,1])
        else
            Δj = rand([-1,1])
        end
        x = mod(i + Δi-3, row_size-4) + 3
        y = mod(j + Δj-3, column_size-4) + 3
        right = stage_lattice[x, y]

        stage_lattice[i, j], stage_lattice[x, y] =
         action(left, right, inter[idx[left]], reprod[idx[left]], intra[idx[left]])
    end

    A_[t] = sum(stage_lattice .== 'A') - 1
    B_[t] = sum(stage_lattice .== 'B') - 1
    C_[t] = sum(stage_lattice .== 'C') - 1
    D_[t] = sum(stage_lattice .== 'D') - 1
    E_[t] = sum(stage_lattice .== 'E') - 1

    end_population = [A_[t], B_[t], C_[t], D_[t], E_[t]]
    entropy_[t] = entropy(end_population ./ sum(end_population), 5)
    if entropy_[t] == 0.0 print("sigular entropy!"); break end
 
    if T == 0
        figure = heatmap(stage_lattice, color=colormap_RPS,
         xaxis=false,yaxis=false,axis=nothing, size=[400, 400], legend=false)
    end
end # for t = 1:endtime

if T == 0
    try
        gif(snapshot, "movie_" * cool * ".mp4", fps=24)
    catch LoadError
        println("스냅샷을 깜빡했습니다")
    end

    plot_time_evolution = plot(legend=:topleft)
    plot!(plot_time_evolution, A_, linecolor=colormap_RPS[1], label="A")
    plot!(plot_time_evolution, B_, linecolor=colormap_RPS[2], label="B")
    plot!(plot_time_evolution, C_, linecolor=colormap_RPS[3], label="C")
    plot!(plot_time_evolution, D_, linecolor=colormap_RPS[4], label="D")
    plot!(plot_time_evolution, E_, linecolor=colormap_RPS[5], label="E")
    png(plot_time_evolution, "plot_time evolution" * cool * ".png")
    
    plot_entropy = plot(entropy_, legend=:topleft)
    hline!(log.(5,1:4)); ylims!(0.,1.)
    png(plot_entropy, "plot_EB" * cool * ".png")
    
elseif T == 1
    time_evolution = DataFrame(hcat(entropy_, A_, B_, C_, D_, E_),
     ["entropy_", "A_", "B_", "C_", "D_", "E_"])
    CSV.write("time_evolution" * cool * ".csv", time_evolution)

    # println("report over")
end

ENTROPY_[max(T, 1)] = entropy_[end]
println(autosave, ", $T,$ε,$p,$(entropy_[end])")
close(autosave); global autosave = open("autosave.csv", "a")

end # for T ∈ itr
println(bifurcation, "$ε,$p,$(mean(ENTROPY_))")
close(bifurcation); global bifurcation = open("bifurcation.csv", "a")

end # for p ∈ p_range
end # for ε ∈ ε_range

finally
    close(autosave)
    close(bifurcation)
end