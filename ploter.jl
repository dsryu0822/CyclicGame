@time using CSV, DataFrames
@time using Plots

cd(@__DIR__)

function ctail(tail)
    if tail == ""
        return (0,1)
    elseif tail == "_n"
        return (0,5)
    end
end

for file_name ∈ ["bifurcation_0", "bifurcation_1"]
for tail ∈ ["", "_n"]
df1 = CSV.read(file_name * tail * ".csv", DataFrame, header = false)
rename!(df1, :Column7 => :EB, :Column1 => :ε, :Column2 => :p)

log10M = range(-6., -2., length = 20); L = 100
axis = 2(10. .^ log10M)*(L^2)

bifurcation_diagram = heatmap(log10M, log10M, reshape(df1.EB, 20, 20),
 size = (400, 400), clim=ctail(tail), color = :Spectral_11)
xlabel!("2L²10^ε"); ylabel!("2L²10^p")
png(bifurcation_diagram, file_name * tail * ".png")
end
end

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
