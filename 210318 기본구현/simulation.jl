cd(@__DIR__) # 파일 저장 경로

@time using Random
@time using Statistics
@time using Base.Threads
@time using Plots

ReLU(x) = max(0, x)

σ = 3
μ = 1
ε = 1
Σ = (σ + μ + ε)
σ = σ / Σ
μ = μ / Σ
ε = ε / Σ

function action(left::Char, center::Char, right::Char)
    probability = rand()
    if probability < σ
        if center == 'A' && right == 'B'
            return (left, 'A', '∅')
        elseif center == 'B' && right == 'C'
            return (left, 'B', '∅')
        elseif center == 'C' && right == 'A'
            return (left, 'C', '∅')
        else
            return (left, center, right)
        end
    elseif (1-μ) < probability
        if center == 'A' && right == '∅'
            return (left, 'A', 'A')
        elseif center == 'B' && right == '∅'
            return (left, 'B', 'B')
        elseif center == 'C' && right == '∅'
            return (left, 'C', 'C')
        else
            return (left, center, right)
        end
    else
        if left == 'A' && center == 'B' && right == '∅'
            return ('A', '∅', 'B')
        elseif left == 'B' && center == 'C' && right == '∅'
            return ('B', '∅', 'C')
        elseif left == 'C' && center == 'A' && right == '∅'
            return ('C', '∅', 'A')

        elseif left == 'A' && center == '∅' && right == 'B'
            return ('∅', 'A', 'B')
        elseif left == 'B' && center == '∅' && right == 'C'
            return ('∅', 'B', 'C')
        elseif left == 'C' && center == '∅' && right == 'A'
            return ('∅', 'C', 'A')

        else
            return (left, center, right)
        end
    end
end

# 0:W: Empty
# 1:R:R: Rock
# 2:B:P: Paper
# 3:G:S: scissors
# colormap_RPS = [
#   colorant"#FFFFFF",
#   colorant"#FFCCCC",
#   colorant"#99CCFF",
#   colorant"#CCFFCC",
#   colorant"#000000"]
colormap_RPS = [
  colorant"#FFCCCC",
  colorant"#CCFFCC",
  colorant"#99CCFF",
  colorant"#FFFFFF"]
#   colorant"#FFFF99",
#   colorant"#9933FF",
#   colorant"#339900"]

N = row_size = column_size = 100
endtime = 500
# stage_lattice = zeros(Char, row_size, column_size)
# μ = 0.2

stage_lattice = Array{Char, 2}(undef, row_size, column_size)
stage_lattice .= '∅'

x = Int64[]
y = Int64[]
z = Int64[]
X = Int64[]
Y = Int64[]
Z = Int64[]

Random.seed!(0);
# for t ∈ 1:2
#     I = rand(3:(row_size - 1)); J = rand(2:(column_size - 1))
#     stage_lattice[I, J] = 1
#     I = rand(3:(row_size - 1)); J = rand(2:(column_size - 1))
#     stage_lattice[I, J] = 2
#     I = rand(3:(row_size - 1)); J = rand(2:(column_size - 1))
#     stage_lattice[I, J] = 3
#     # I = rand(3:(row_size - 1)); J = rand(2:(column_size - 1))
#     # stage_lattice[I, J] = 4
#     # I = rand(3:(row_size - 1)); J = rand(2:(column_size - 1))
#     # stage_lattice[I, J] = 5
# end

stage_lattice[3:(row_size - 1), 2:(column_size - 1)] =
 (rand(['A','B','C'], row_size - 3, column_size -2))

stage_lattice[1, 1] = 'A'
stage_lattice[1, 2] = 'B'
stage_lattice[1, 3] = 'C'

# for t = 1:endtime
lattice = @animate for t = 1:endtime
    print("|")
    if mod(t, 100) == 0 println(t) end
    # stage_duel = copy(stage_lattice)
    
    for τ ∈ 1:(N^2)
        j = rand(3:(row_size - 1))
        i = rand(3:(column_size - 1))
        나 = stage_lattice[i,j]

        if rand([true, false])
            Δx = rand([-1,1])
            Δy = 0
        else
            Δx = 0
            Δy = rand([-1,1])
        end
        가 = stage_lattice[i + Δx, j + Δy]
        다 = stage_lattice[i - Δx, j + Δy]

        stage_lattice[i + Δx, j + Δy],
         stage_lattice[i,j],
         stage_lattice[i - Δx, j + Δy] = action(가, 나, 다)
        #     catch
        #         println("A: $A, B: $B")
        # # println("A: $(typeof(A)), B: $(typeof(A))")
        # # println(typeof(duel(A, B, coop_A, coop_B)))
        #     end
    end
    # stage_lattice = stage_duel
    # stage_lattice[3:(row_size - 1), 2:(column_size - 1)] .*= (rand(row_size - 3, column_size -2) .< 0.9)
    push!(x, sum(stage_lattice .== 'A'))
    push!(y, sum(stage_lattice .== 'B'))
    push!(z, sum(stage_lattice .== 'C'))
    # push!(X, sum(stage_lattice .== 4))
    # push!(Y, sum(stage_lattice .== 5))
    # push!(Z, sum(stage_lattice .== 6))

    # stage_lattice = stage_duel
    figure = heatmap(stage_lattice, color=colormap_RPS,
    xaxis=false,yaxis=false,axis=nothing, size=[400, 400], legend=false)
end
gif(lattice, "result_lattice.mp4", fps=24)

time_evolution = plot(legend=:topleft)
plot!(time_evolution, x, linecolor=colormap_RPS[1], label="x")
plot!(time_evolution, y, linecolor=colormap_RPS[2], label="y")
plot!(time_evolution, z, linecolor=colormap_RPS[3], label="z")
# plot!(time_evolution, X, linecolor=colormap_RPS[5], label="X")
# plot!(time_evolution, Y, linecolor=colormap_RPS[6], label="Y")
# plot!(time_evolution, Z, linecolor=colormap_RPS[7], label="Z")
# png(time_evolution, "result_time evolution.png")

# time_evolution_sum = plot()
# plot!(time_evolution_sum, X+x, linecolor = colormap_RPS[2], label = "X+x")
# plot!(time_evolution_sum, Y+y, linecolor = colormap_RPS[3], label = "Y+y")
# plot!(time_evolution_sum, Z+z, linecolor = colormap_RPS[4], label = "Z+z")
# png(time_evolution_sum, "time evolution sum.png")

# traj = @animate for t in 1:10:(endtime-10)
#   plot(X[1:t],-Y[1:t],Z[1:t], camera = (45,45), linealpha = (1:t)/t)
#   xlims!(0,maximum(X)); ylims!(-maximum(Y),0); zlims!(0,maximum(Z))
# end
# gif(traj, "traj.mp4", fps = 12)

