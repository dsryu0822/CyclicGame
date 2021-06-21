@time using CSV, DataFrames
@time using Plots
@time include("Config.jl")

cd(@__DIR__); print(pwd())

folder_name = "result1/"
for ITR ∈ 6:6
    Alive = zeros(Float64, 20, 20)
    Entropy5 = zeros(Float64, 20, 20)
    Entropy6 = zeros(Float64, 20, 20)
    itr = 1:ITR

    for seed ∈ lpad.(itr, 3, "0")
        temp = CSV.read(folder_name * "T" * seed * ".csv", DataFrame, header = true)
        # temp2 = CSV.read(folder_name * "T" * seed * ".csv", DataFrame, header = false)
        Alive += transpose(reshape(temp.alive, 20, 20))
        Entropy5 += transpose(reshape(temp.entropy5, 20, 20))
        Entropy6 += transpose(reshape(temp.entropy6, 20, 20))
    end
    Alive /= length(itr)
    Entropy5 /= length(itr)
    Entropy6 /= length(itr)

    diagram_Alive = heatmap(log10M, log10M, Alive,
     size = (400, 400), clim=(1,5), color = :Spectral_11)
     xlabel!("L²10^ε"); ylabel!("L²10^p")
    #  png(diagram_Alive, "diagram_Alive" * lpad(length(itr), 2, "0") * ".png")

    diagram_Entropy5 = heatmap(log10M, log10M, Entropy5,
     size = (400, 400), clim=(0,1), color = :Spectral_11)
     xlabel!("L²10^ε"); ylabel!("L²10^p")
    #  png(diagram_Entropy, "diagram_Entropy" * lpad(length(itr), 2, "0") * ".png")

    diagram_Entropy6 = heatmap(log10M, log10M, Entropy6,
     size = (400, 400), clim=(0,1), color = :Spectral_11)
     xlabel!("L²10^ε"); ylabel!("L²10^p")
    #  png(diagram_Entropy, "diagram_Entropy" * lpad(length(itr), 2, "0") * ".png")
    
    diagram = plot(diagram_Alive, diagram_Entropy5, diagram_Entropy6, layout = (1,3),
     size = (900, 200))
     png(diagram, folder_name * "diagram_" * lpad(length(itr), 3, "0") * ".png")
end
