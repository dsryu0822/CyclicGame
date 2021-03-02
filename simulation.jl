cd(@__DIR__) # 파일 저장 경로

@time using Random
@time using Base.Threads
@time using Plots

function duel(A::Int, B::Int; p=0.8)
  if A == 0
    return B
  elseif B == 0
    return A
  end

  extraA = mod(A-1, 3) + 1
  extraB = mod(B-1, 3) + 1

  if extraA == 1 && extraB == 2
    return B
    # if rand() < 0.2 return A else return B end
  elseif extraA == 2 && extraB == 3
    return B
    # if rand() < 0.2 return A else return B end
  elseif extraA == 3 && extraB == 1
    return B
    # if rand() < 0.2 return A else return B end
  end

  intraA = A ≤ 3 ? 1 : 2
  intraB = B ≤ 3 ? 1 : 2

  if intraA == 1 && intraB == 1
    # return A
    if rand() < (1-p) return 0 else return A end
  elseif intraA == 2 && intraB == 2
    # return 0
    if rand() < p return 0 else return A end
  elseif intraA == 2 && intraB == 1
    # return A
    if rand() < (1-p) return B else return A end
  elseif intraA == 1 && intraB == 2
    # return B
    if rand() < p return B else return A end
  end
end

# 0:W: Empty
# 1:R:R: Rock
# 2:B:P: Paper
# 3:G:S: scissors
colormap_RPS = [
  colorant"#FFFFFF",
  colorant"#990000",
  colorant"#0033FF",
  colorant"#006600",
  colorant"#FFCCCC",
  colorant"#99CCFF",
  colorant"#CCFFCC"]

row_size = column_size = 200
endtime = 500
stage_lattice = zeros(Int64, row_size, column_size)

x = Int64[]
y = Int64[]
z = Int64[]
X = Int64[]
Y = Int64[]
Z = Int64[]

Random.seed!(0);
for k in 1:12
  stage_lattice[rand(2:(row_size-1)), rand(2:(column_size-1))] = mod(k-1,6) + 1
end

lattice = @animate for t = 1:endtime
  print("|")
  if mod(t, 100) == 0 println() end
  # @threads
  stage_duel = copy(stage_lattice)
  @threads for j in 2:(row_size-1)
    for i in 2:(row_size-1)
      I = i
      J = j
      A = stage_lattice[I, J]
  
      if rand(Bool)
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
gif(lattice, "lattice.mp4", fps = 24)

time_evolution = plot()
plot!(time_evolution, x, linecolor = colormap_RPS[2], label = "X")
plot!(time_evolution, y, linecolor = colormap_RPS[3], label = "Y")
plot!(time_evolution, z, linecolor = colormap_RPS[4], label = "Z")
plot!(time_evolution, X, linecolor = colormap_RPS[5], label = "x")
plot!(time_evolution, Y, linecolor = colormap_RPS[6], label = "y")
plot!(time_evolution, Z, linecolor = colormap_RPS[7], label = "z")
png(time_evolution, "time evolution.png")

time_evolution_sum = plot()
plot!(time_evolution_sum, X+x, linecolor = colormap_RPS[2], label = "X+x")
plot!(time_evolution_sum, Y+y, linecolor = colormap_RPS[3], label = "Y+y")
plot!(time_evolution_sum, Z+z, linecolor = colormap_RPS[4], label = "Z+z")
png(time_evolution_sum, "time evolution sum.png")

traj = @animate for t in 1:10:(endtime-10)
  plot(X[1:t],-Y[1:t],Z[1:t], camera = (45,45), linealpha = (1:t)/t)
  xlims!(0,maximum(X)); ylims!(-maximum(Y),0); zlims!(0,maximum(Z))
end
gif(traj, "traj.mp4", fps = 12)