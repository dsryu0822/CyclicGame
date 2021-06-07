@time using CSV, DataFrames
@time using Plots

cd(@__DIR__)

df1 = CSV.read("bifurcation.csv", DataFrame, header = false)
# rename!(df1, ["ε", "p", "EB"])
rename!(df1, :Column7 => :EB, :Column1 => :ε, :Column2 => :p)

# bifurcation_diagram = heatmap(log10M, log10M, reshape(df1.EB, 20, 20),
#  size = (400, 400), xscale = :log, xticks = [0.2, 20,  200], clim=(0,1))

log10M = range(-6., -2., length = 20); L = 100
axis = 2(10. .^ log10M)*(L^2)

bifurcation_diagram = heatmap(log10M, log10M, reshape(df1.EB, 20, 20),
 size = (400, 400), clim=(0,1), color = :RdYlGn_8)
# xaxis!(2(10. .^ log10M)*(L^2)); yaxis!(2(10. .^ log10M)*(L^2))
xlabel!("2L²10^ε"); ylabel!("2L²10^p")

png(bifurcation_diagram, "bifurcation_diagram 2개.png")


# row_size, column_size = 100, 100
# @time stage_lattice1 = Array{Char, 2}(undef, row_size, column_size); stage_lattice .= '∅';
# @time stage_lattice2 = fill('∅', row_size, column_size);

# using CUDA
# N = 100000
# Base.@time x = rand(N);
# CUDA.@time y = CUDA.rand(N);

# Base.@time x = x.^2;
# CUDA.@time y = y.^2;

# x = Dict{Char, Int64}()

# push!(x, ('A'=>1))

# x['A']

# x = y = copy(zeros(Int64, 2))
