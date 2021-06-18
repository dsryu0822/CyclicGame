@time using CSV, DataFrames
@time using Gtk
@time using Plots

file_name = open_dialog("파일 열기")
DF = CSV.read(file_name, DataFrame, header = true)

alive_ = plot(DF.alive_, color = :black, legend = :none);
hline!(1:4, color = :gray, alpha = 0.2); ylims!(1.,5.)
entropy_ = plot(DF.entropy_, color = :black, legend = :none);
hline!(log.(5,1:4), color = :gray, alpha = 0.2); ylims!(0.,1.)
time_evolution = plot(Array(DF[:,3:end]), legend = :none,
 title = sum(DF[end,3:end]));

layin = @layout [a ; b ; c]

plot_to_save = plot(alive_, entropy_, time_evolution, layout = layin, size = (400, 600))
png(plot_to_save, file_name * ".png")