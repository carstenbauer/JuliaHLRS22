# # Exercise: Performance Optimization 1

# Optimize the following code.
#
# (The type and size of the input is fixed/may not be changed.)

# +
function work!(A, N)
    D = zeros(N,N)
    for i in 1:N
        D = b[i]*c*A
        b[i] = sum(D)
    end
end

N = 100
A = rand(N,N)
b = rand(N)
c = 1.23

work!(A,N)
# -

using BenchmarkTools
@btime work!($A, $N);

# ## Optimizations

# +
# ...
