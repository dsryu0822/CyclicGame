const L = 300
row_size = column_size = L + 4
# ε_range = [0, 1//10,1,10]
# p_range = [0, 1//10,1,10]

# ε_range = p_range = rationalize.(10 .^ (-3:0.3:3))
# ε_range = p_range = [1//1]
# ε_range = 10.0 .^ (-3:1)
# log10M = range(-6., -1., length = 20)
# ε_range = 2(10. .^ log10M)*(L^2)
# p_range = 2(10. .^ log10M)*(L^2)
ε_log10M = range(-5., -1., length = 20)
p_log10M = range(-7., -3., length = 20)
ε_range = (10. .^ ε_log10M)*(L^2)
p_range = (10. .^ p_log10M)*(L^2)
# ε_range = [1]
# p_range = [1]

endtime = 10(L^2)
# endtime = L
itr = 1:10