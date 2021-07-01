@time using CSV, DataFrames
@time using Plots
@time include("Config.jl")

cd(@__DIR__); println(pwd())

######################################################

plot(1 .- Empty, Alive, seriestype = :scatter,
legend = :none, color = :black, size = (400, 400));
xlabel!("prosperity"); ylabel!("coexistence");
png(folder_name * "pros_vs_coex.png")

plot(Alive, Entropy6, seriestype = :scatter,
legend = :none, color = :black, size = (400, 400));
xlabel!("coexistence"); ylabel!("entropic");
png(folder_name * "coex_vs_entr.png")

plot(1 .- Empty, Entropy6, seriestype = :scatter,
legend = :none, color = :black, size = (400, 400));
xlabel!("prosperity"); ylabel!("entropic");
png(folder_name * "pros_vs_entr.png")

######################################################

ITR = 16
camera_angle = abs.((0:180) .- 90)
# folder_name = "result5/"
for folder_name ∈ "result" .* string.(1:5) .* "/"
    Alive = zeros(Float64, 20, 20)
    # Entropy5 = zeros(Float64, 20, 20)
    Entropy6 = zeros(Float64, 20, 20)
    Empty = zeros(Float64, 20, 20)
    itr = 1:ITR

    for seed ∈ lpad.(itr, 3, "0")
        temp = CSV.read(folder_name * "T" * seed * ".csv", DataFrame, header = true)
        # temp2 = CSV.read(folder_name * "T" * seed * ".csv", DataFrame, header = false)
        Alive += transpose(reshape(temp.alive, 20, 20))
        # Entropy5 += transpose(reshape(temp.entropy5, 20, 20))
        Entropy6 += transpose(reshape(temp.entropy6, 20, 20))
        Empty += (transpose(reshape(temp.empty, 20, 20)) ./ L^2)
    end
    Empty /= length(itr)
    Alive /= length(itr)
    # Entropy5 /= length(itr)
    Entropy6 /= length(itr)

    diagram_Alive = heatmap(ε_log10M, p_log10M, Alive,
     size = (400, 400), clim=(1,5), color = :Spectral_11)
    #  title!("Couts"); xlabel!("L²10^ε"); ylabel!("L²10^p")
    #  png(diagram_Alive, "diagram_Alive" * lpad(length(itr), 2, "0") * ".png")

    # diagram_Entropy5 = heatmap(log10M, log10M, Entropy5,
    #  size = (400, 400), clim=(0,1), color = :Spectral_11)
    #  title!("Entropy5"); xlabel!("L²10^ε"); ylabel!("L²10^p")
    #  png(diagram_Entropy, "diagram_Entropy" * lpad(length(itr), 2, "0") * ".png")

    diagram_Entropy6 = heatmap(ε_log10M, p_log10M, Entropy6,
     size = (400, 400), clim=(0,1), color = :Spectral_11)
    #  title!("Entropy6"); xlabel!("L²10^ε"); ylabel!("L²10^p")
    #  png(diagram_Entropy, "diagram_Entropy" * lpad(length(itr), 2, "0") * ".png")

    diagram_Empty = heatmap(ε_log10M, p_log10M, Empty,
    size = (400, 400), clim=(0,1), color = :bone)
    # title!("Empty"); xlabel!("L²10^ε"); ylabel!("L²10^p")

    diagram = plot(diagram_Alive, diagram_Entropy6, diagram_Empty, layout = (3,1),
     size = (400, 900))
     png(diagram, folder_name * "diagram_" * lpad(length(itr), 3, "0") * ".png")
    
    a = @animate for θ ∈ camera_angle
        plot(1 .- Empty, Alive, Entropy6, seriestype = :scatter, legend = :none,
         size = (400, 400), color = :black, alpha = Entropy6, camera = (θ,45))
    end
    gif(a, folder_name * "111.gif")
end
# diagram_Entropy6

# diagram_temp = heatmap(log10M, log10M, (1 .- Empty) .* Alive,
# size = (400, 400), clim = (0,5), color = :Spectral_11)



# plot(1 .- Empty, Alive, color = :black, seriestype = :scatter, legend = :none, size = (400, 400))
# plot(1 .- Empty, Alive, Entropy6, color = :black, seriestype = :scatter, legend = :none, size = (400, 400), camera = (45,0))
# plot!([(1,1,0), (1,0,1)])


