# # Exercise: Performance Optimization 2

# Optimize the following function.

function work!(A, B, v, N)
    val = 0
    for i in 1:N
        for j in 1:N
            val = mod(v[i],256);
            A[i,j] = B[i,j]*(sin(val)*sin(val)-cos(val)*cos(val));
        end
    end
end

# The (fixed) input is given by:

# +
N = 4000
A = zeros(N,N)
B = rand(N,N)
v = rand(Int, N);

work!(A,B,v,N)
# -

# You can benchmark as follows

using BenchmarkTools
@btime work!($A, $B, $v, $N);

# ## Optimizations

# +
# ...
# -

# ## Bonus Question: Performance limit?
#
# Look at your final optimized version of `work!`.
#
# * What is conceptually limiting the performance? I.e. is the function compute- or memory-bound?
# * How fast can it "theoretically" be? Can you estimate a performance bound?

#
