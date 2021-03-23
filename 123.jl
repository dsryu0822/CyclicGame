using NearestNeighbors
S = rand(2, 10^4)
I = rand(2, 10^2)
k = 0.01
point = rand(3)

kdtree = KDTree(S)
contact = length.(inrange(kdtree, I, k, true))

