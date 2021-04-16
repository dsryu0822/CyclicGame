@time using CSV, DataFrames
@time using Plots

df1 = CSV.read("bifurcation.csv", DataFrame, header = false)
rename!(df1, ["ε", "p", "EB"])

bifurcation_diagram = heatmap(reshape(df1.EB, 11, 11), size = (400, 400))
xaxis!((2//1) .^ (-5:5)); yaxis!((2//1) .^ (-5:5))
xlabel!("ε"); ylabel!("p")

png(bifurcation_diagram, "bifurcation_diagram.png")


row_size, column_size = 100, 100
@time stage_lattice1 = Array{Char, 2}(undef, row_size, column_size); stage_lattice .= '∅';
@time stage_lattice2 = fill('∅', row_size, column_size);

using CUDA
N = 100000
Base.@time x = rand(N);
CUDA.@time y = CUDA.rand(N);

Base.@time x = x.^2;
CUDA.@time y = y.^2;

x = Dict{Char, Int64}()

push!(x, ('A'=>1))

x['A']

x = y = copy(zeros(Int64, 2))
