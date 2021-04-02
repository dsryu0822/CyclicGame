@time using Base.Threads
@time using Dates
@time using Random
@time using Statistics
@time using StatsBase
@time using CSV, DataFrames
@time using Plots

println(Dates.now())

# cd("E:/RPS")
println(pwd())

σ = 1
μ = 1

function action(center::Char, right::Char)    
    probability = rand()
    if probability < σ
        if     center == 'A' && (right == 'B' || right == 'D')
            return ('A', '∅')
        elseif center == 'B' && (right == 'C' || right == 'E')
            return ('B', '∅')
        elseif center == 'C' && (right == 'D' || right == 'A')
            return ('C', '∅')
        elseif center == 'D' && (right == 'E' || right == 'B')
            return ('D', '∅')
        elseif center == 'E' && (right == 'A' || right == 'C')
            return ('E', '∅')
        else
            return (center, right)
        end
    elseif (1-μ) < probability
        if     center == 'A' && right == '∅'
            return ('A', 'A')
        elseif center == 'B' && right == '∅'
            return ('B', 'B')
        elseif center == 'C' && right == '∅'
            return ('C', 'C')
        elseif center == 'D' && right == '∅'
            return ('D', 'D')
        elseif center == 'E' && right == '∅'
            return ('E', 'E')
        else
            return (center, right)
        end
    else
        return (right, center) # exchange
    end
end

colormap_RPS = [
  colorant"#FF3333",
  colorant"#33CC00",
  colorant"#0066FF",
  colorant"#FFCC00",
  colorant"#9933CC",
  colorant"#FFFFFF"]

L = 200
row_size = column_size = L + 4

# endtime = 600
# log10M = range(-6., -3., length = 20)[3]
# EPSILON = 10
# itr = 0:0

endtime = 1000
log10M = range(-10., -1., length = 10)
# EPSILON = 2(10. .^ log10M)*(L^2)
EPSILON = 2(10//1) .^(-10:-1)*(L^2)
itr = 1:8

note = open("summary.csv", "a")

try

for ϵ ∈ EPSILON

print("$ϵ start!")

global σ = 1
global μ = 1
ε = ϵ
# ε = 10
Σ = (σ + μ + ε)
global σ = σ / Σ
global μ = μ / Σ
ε = ε / Σ

print(note, Dates.now())
# realization = Float64[]
@threads for T ∈ itr
Random.seed!(T)
stage_lattice = Array{Char, 2}(undef, row_size, column_size)
stage_lattice .= '∅'

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
# lattice = @animate for t = 1:endtime
    if mod(t, 500) == 0 print("|") end
    # if mod(t, 1000) == 0 println(t) end
    
    for τ ∈ 1:(L^2)
        j = rand(3:(row_size - 2))
        i = rand(3:(column_size - 2))
        나 = stage_lattice[i,j]

        if rand([true, false])
            Δx = rand([-1,1])
            Δy = 0
        else
            Δx = 0
            Δy = rand([-1,1])
        end
        다 = stage_lattice[i + Δx, j + Δy]

        if 나 != 다
            stage_lattice[i,j], stage_lattice[i + Δx, j + Δy] = action(나, 다)
        end
    end

    A_[t] = sum(stage_lattice .== 'A') - 1
    B_[t] = sum(stage_lattice .== 'B') - 1
    C_[t] = sum(stage_lattice .== 'C') - 1
    D_[t] = sum(stage_lattice .== 'D') - 1
    E_[t] = sum(stage_lattice .== 'E') - 1

    end_population = [A_[t], B_[t], C_[t], D_[t], E_[t]]
    entropy_[t] = entropy(end_population ./ sum(end_population)) / log(5)
    if entropy_[t] == 0.0
        print("!")
        break
    end
 
    if T == 0
        figure = heatmap(stage_lattice, color=colormap_RPS,
        xaxis=false,yaxis=false,axis=nothing, size=[400, 400], legend=false)
    end
end
cool_ε = replace(string(ϵ), "//" => "／")
if T == 0
    gif(lattice, "result_lattice $ϵ.mp4", fps=24)

    time_evolution = plot(legend=:topleft)
    plot!(time_evolution, A_, linecolor=colormap_RPS[1], label="A")
    plot!(time_evolution, B_, linecolor=colormap_RPS[2], label="B")
    plot!(time_evolution, C_, linecolor=colormap_RPS[3], label="C")
    plot!(time_evolution, D_, linecolor=colormap_RPS[4], label="D")
    plot!(time_evolution, E_, linecolor=colormap_RPS[5], label="E")
    png(time_evolution, "result_time evolution " * cool_ε * "cool_ε.png")
elseif T == 1
    time_evolution = DataFrame(hcat(entropy_, A_, B_, C_, D_, E_),
     ["entropy_", "A_", "B_", "C_", "D_", "E_"])
    CSV.write("time_evolution " * cool_ε * ".csv", time_evolution)
end

println(note, ", $T, $ε, $(entropy_[end])")

# print(save, ",", realization[end])
# print(realization[end])
# print(T)
end

# close(note); note = open("summary.csv", "a")
# push!(biodiversity, mean(realization))
# println("ε = $ε over!")
end

# biodiversity_plot = plot((10. .^ log10M), biodiversity, xaxis = :log10)
# png(biodiversity_plot, "biodiversity_plot_ϵ.png")

finally
    close(note)
end