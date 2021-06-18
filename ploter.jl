@time using CSV, DataFrames
@time using Plots
@time include("Config.jl")

cd(@__DIR__); print(pwd())

folder_name = "210617 5 parameter/"
for ITR ∈ 1:16
    Alive = zeros(Float64, 20, 20)
    Entropy = zeros(Float64, 20, 20)
    itr = 1:ITR

    for seed ∈ lpad.(itr, 2, "0")
        temp1 = CSV.read(folder_name * "Alive/T" * seed * ".csv", DataFrame, header = false)
        temp2 = CSV.read(folder_name * "Entropy/T" * seed * ".csv", DataFrame, header = false)
        Alive += transpose(reshape(temp1.Column7, 20, 20))
        Entropy += transpose(reshape(temp2.Column7, 20, 20))
    end
    Alive /= length(itr)
    Entropy /= length(itr)

    diagram_Alive = heatmap(log10M, log10M, Alive,
     size = (400, 400), clim=(1,5), color = :Spectral_11)
     xlabel!("L²10^ε"); ylabel!("L²10^p")
    #  png(diagram_Alive, "diagram_Alive" * lpad(length(itr), 2, "0") * ".png")

    diagram_Entropy = heatmap(log10M, log10M, Entropy,
     size = (400, 400), clim=(0,1), color = :Spectral_11)
     xlabel!("L²10^ε"); ylabel!("L²10^p")
    #  png(diagram_Entropy, "diagram_Entropy" * lpad(length(itr), 2, "0") * ".png")
    
    diagram = plot(diagram_Alive, diagram_Entropy, layout = (1,2),
     size = (900, 400))
     png(diagram, "diagram_vs" * lpad(length(itr), 2, "0") * ".png")
end


