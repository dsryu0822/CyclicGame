cd(@__DIR__) # 파일 저장 경로

@time using Random
@time using Statistics
@time using Base.Threads
@time using Plots

ReLU(x) = max(0,x)

function duel(A::Int64, B::Int64)
  if A == 0
    return B
  elseif B == 0
    return A
  end

  extraA = mod(A-1, 3) + 1
  extraB = mod(B-1, 3) + 1

  if extraA != extraB
    if (extraA == 1 && extraB == 2) ||
       (extraA == 2 && extraB == 3) ||
       (extraA == 3 && extraB == 1)
      odds_A = 10
      odds_B = 20
    else
      odds_A = 20
      odds_B = 10
    end
    if (odds_A + odds_B)*rand() < odds_A
      return A
    else
      return B
    end
  else
    intraA = A ≤ 3 ? 1 : 2
    intraB = B ≤ 3 ? 1 : 2
    odds_A = 10
    odds_B = 10

    if intraB == 2
      if intraA == 1
        if (odds_A + odds_B)*rand() < odds_A
          return A
        else
          return B
        end
      else
        if rand() < 0.5 #internal competition
          return 0
        else
          return A
        end
      end
    else
      return  A
    end
  end
end


# 0:W: Empty
# 1:R:R: Rock
# 2:B:P: Paper
# 3:G:S: scissors
colormap_RPS = [
  colorant"#FFFFFF",
  colorant"#FFCCCC",
  colorant"#99CCFF",
  colorant"#CCFFCC",
  colorant"#F66666",
  colorant"#6699FF",
  colorant"#339900"]
# colormap_RPS = [
#   colorant"#FFFFFF",
#   colorant"#FFCCCC",
#   colorant"#99CCFF",
#   colorant"#CCFFCC"]

row_size = column_size = 100
endtime = 500
stage_lattice = zeros(Int64, row_size, column_size)
fitness = zeros(Float64, row_size, column_size)

for j in 0:6
  stage_lattice[1,j+1] = j
  fitness[1,j+1] = 100
end

x = Int64[]
y = Int64[]
z = Int64[]
X = Int64[]
Y = Int64[]
Z = Int64[]
x_fitness = Float64[]
y_fitness = Float64[]
z_fitness = Float64[]
X_fitness = Float64[]
Y_fitness = Float64[]
Z_fitness = Float64[]

Random.seed!(0);
for t in 1:10
  I = rand(2:(row_size-1)); J = rand(2:(column_size-1)); fitness[I, J] = 100
  stage_lattice[I, J] = 1
  I = rand(2:(row_size-1)); J = rand(2:(column_size-1)); fitness[I, J] = 100
  stage_lattice[I, J] = 2
  I = rand(2:(row_size-1)); J = rand(2:(column_size-1)); fitness[I, J] = 100
  stage_lattice[I, J] = 3
end

lattice = @animate for t = 1:endtime
  print("|")
  if mod(t, 100) == 0 println() end
  stage_duel = copy(stage_lattice)
  @threads for j in 2:(column_size-1)
    for i in 3:(row_size-1)
      if i < 95 && (mod(j,10) == 0) continue end
      A = stage_lattice[i, j]
      I = i
      J = j

      if rand([true, false])
        I += rand([-1,1])
      else
        J += rand([-1,1])
      end
      B = stage_lattice[I, J]

      stage_duel[i,j] = duel(A, B)
    end
  end
  stage_lattice = stage_duel
  push!(x, sum(stage_lattice .== 1))
  push!(y, sum(stage_lattice .== 2))
  push!(z, sum(stage_lattice .== 3))
  push!(X, sum(stage_lattice .== 4))
  push!(Y, sum(stage_lattice .== 5))
  push!(Z, sum(stage_lattice .== 6))

  stage_lattice = stage_duel
  figure = heatmap(stage_lattice, color=colormap_RPS,
    xaxis=false,yaxis=false,axis=nothing, size = [400,400], legend = false)
  end
gif(lattice, "result_lattice.mp4", fps = 24)

time_evolution = plot(legend = :topleft)
plot!(time_evolution, x, linecolor = colormap_RPS[2], label = "x")
plot!(time_evolution, y, linecolor = colormap_RPS[3], label = "y")
plot!(time_evolution, z, linecolor = colormap_RPS[4], label = "z")
plot!(time_evolution, X, linecolor = colormap_RPS[5], label = "X")
plot!(time_evolution, Y, linecolor = colormap_RPS[6], label = "Y")
plot!(time_evolution, Z, linecolor = colormap_RPS[7], label = "Z")
png(time_evolution, "result_time evolution.png")

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
