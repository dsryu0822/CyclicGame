# using Gtk
# folder = open_dialog("폴더 열기")
@time using CSV, DataFrames
@time using Plots

cd(@__DIR__)
@time include("Config.jl")
cd("C:\\Users\\rmsms\\Downloads\\새 폴더")

temp = DataFrame()
for csvfile in readdir()
    temp = vcat(temp, CSV.read(csvfile, DataFrame, header = true))
    # println(temp)
end

scatter(temp.empty, temp.alive, label = :none); ylims!(0,6)
png("16.png")