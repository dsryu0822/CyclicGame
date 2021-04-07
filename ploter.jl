@time using CSV, DataFrames
@time using Plots

df1 = CSV.read("bifurcation.csv", DataFrame)

