L = 100
row_size = column_size = L + 4
# ε_range = [0, 1//10,1,10]
# p_range = [0, 1//10,1,10]

# ε_range = p_range = rationalize.(10 .^ (-3:0.3:3))
# ε_range = p_range = [1//1]
# ε_range = 10.0 .^ (-3:1)
# log10M = range(-6., -1., length = 20)
# ε_range = 2(10. .^ log10M)*(L^2)
# p_range = 2(10. .^ log10M)*(L^2)
log10M = range(-7., -1., length = 20)
ε_range = (10. .^ log10M)*(L^2)
p_range = (10. .^ log10M)*(L^2)

endtime = 10000
itr = 1:16