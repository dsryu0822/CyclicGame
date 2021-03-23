@time using Base.Threads
@time using Random
@time using Statistics
@time using Dates
@time using StatsBase
@time using Plots


println(Dates.now())

cd(@__DIR__)
if pwd() == "c:\\Users\\rmsms\\OneDrive\\lab\\RPS"
    cd("C:\\Users\\rmsms\\OneDrive\\lab\\RPS\\210324") # 파일 저장 경로
end
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

# 0:W: Empty
# 1:R:R: Rock
# 2:B:P: Paper
# 3:G:S: scissors
# colormap_RPS = [
#   colorant"#FFCCCC",
#   colorant"#99FF66",
#   colorant"#99CCFF",
#   colorant"#FFFFFF"]
colormap_RPS = [
  colorant"#FF3333",
  colorant"#33CC00",
  colorant"#0066FF",
  colorant"#FFCC00",
  colorant"#9933CC",
  colorant"#FFFFFF"]

save = open("save.csv", "a")

L = 100
# endtime = 5000
# log10M = range(-6., -3., length = 20)
# EPSILON = 10
# itr = 0:0

endtime = 5000
log10M = range(-6., -3., length = 30)
EPSILON = 2(10. .^ log10M)*(L^2)
itr = 1:10

row_size = column_size = L + 4

biodiversity = Float64[]
for ϵ ∈ EPSILON
stage_lattice = Array{Char, 2}(undef, row_size, column_size)
stage_lattice .= '∅'

σ = 1
μ = 1
ε = ϵ
# ε = 10
Σ = (σ + μ + ε)
σ = σ / Σ
μ = μ / Σ
ε = ε / Σ

A = Int64[]
B = Int64[]
C = Int64[]
D = Int64[]
E = Int64[]

stage_lattice[3:(row_size - 2), 3:(column_size - 2)] =
 (rand(['A','B','C','D','E'], row_size - 4, column_size -4))

stage_lattice[1, 1] = 'A'
stage_lattice[1, 2] = 'B'
stage_lattice[1, 3] = 'C'
stage_lattice[1, 4] = 'D'
stage_lattice[1, 5] = 'E'

print(save, "\n", Dates.now())
realization = Float64[]
@threads for T ∈ itr
Random.seed!(T)

# for t = 1:endtime
lattice = @animate for t = 1:endtime
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

        stage_lattice[i,j], stage_lattice[i + Δx, j + Δy] = action(나, 다)
    end

    push!(A, sum(stage_lattice .== 'A'))
    push!(B, sum(stage_lattice .== 'B'))
    push!(C, sum(stage_lattice .== 'C'))
    push!(D, sum(stage_lattice .== 'D'))
    push!(E, sum(stage_lattice .== 'E'))
 
    if T == 0
        figure = heatmap(stage_lattice, color=colormap_RPS,
        xaxis=false,yaxis=false,axis=nothing, size=[400, 400], legend=false)
    end
end
if T == 0
    gif(lattice, "result_lattice $ϵ.mp4", fps=24)

    time_evolution = plot(legend=:topleft)
    plot!(time_evolution, A, linecolor=colormap_RPS[1], label="A")
    plot!(time_evolution, B, linecolor=colormap_RPS[2], label="B")
    plot!(time_evolution, C, linecolor=colormap_RPS[3], label="C")
    plot!(time_evolution, D, linecolor=colormap_RPS[4], label="D")
    plot!(time_evolution, E, linecolor=colormap_RPS[5], label="E")
    png(time_evolution, "result_time evolution $ϵ.png")
end

end_population = [A[end], B[end], C[end], D[end], E[end]]
print(end_population)
push!(realization, entropy(end_population ./ sum(end_population)))

print(save, ",", realization[end])
# print(realization[end])
print(T)
end

push!(biodiversity, mean(realization))
println("ε = $ε over!")
end

biodiversity_plot = plot((10. .^ log10M), biodiversity, xaxis = :log10)
png(biodiversity_plot, "biodiversity_plot_ϵ.png")
close(save)
