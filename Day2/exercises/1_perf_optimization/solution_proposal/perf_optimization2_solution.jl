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

gethostname()

# ### Analytic optimization

using Test
x = rand()
@test 1-2*cos(x)*cos(x) ≈ sin(x)*sin(x)-cos(x)*cos(x)
@test -cos(2*x) ≈ sin(x)*sin(x)-cos(x)*cos(x)

# +
function work2!(A, B, v, N)
    val = 0
    for i in 1:N
        for j in 1:N
            val = mod(v[i],256);
            A[i,j] = B[i,j]*(-cos(2*val));
        end
    end
end

@btime work2!($A, $B, $v, $N);
# -

# ### Analytic + pulling out val computation

# +
function work3!(A, B, v, N)
    val = 0.0
    for i in 1:N
        val = -cos(2*mod(v[i],256))
        for j in 1:N
            A[i,j] = B[i,j]*val;
        end
    end;
end

@btime work3!($A, $B, $v, $N);
# -

# ### Analytic + separate out val computation

# +
function work4!(A, B, v, N)
    val = [-cos(2*mod(x,256)) for x in v]

    for i in 1:N
        for j in 1:N
            A[i,j] = B[i,j]*val[i];
        end
    end;
end

@btime work4!($A, $B, $v, $N);
# -

# ### Analytic + separate out val computation + switch order of loops

# +
function work5!(A, B, v, N)
    val = [-cos(2*mod(x,256)) for x in v]

    for j in 1:N
        for i in 1:N
            A[i,j] = B[i,j]*val[i];
        end
    end;
end

@btime work5!($A, $B, $v, $N);
# -

# ### Analytic + separate out val computation + switch order of loops + `@inbounds`

# +
function work6!(A, B, v, N)
    val = [-cos(2*mod(x,256)) for x in v]

    @inbounds for j in 1:N
        for i in 1:N
            A[i,j] = B[i,j]*val[i];
        end
    end;
end

@btime work6!($A, $B, $v, $N);
# -

# ### Analytic + separate out val computation + switch order of loops + `@inbounds` + lookup table

# +
lookup = [ -cos(2*j) for j in 0:255 ]

function work7!(A, B, v, N, lookup)
    @inbounds val = [lookup[mod(x,256)+1] for x in v]

    @inbounds for j in 1:N
        for i in 1:N
            A[i,j] = B[i,j]*val[i];
        end
    end;
end

@btime work7!($A, $B, $v, $N, $lookup);
# -





# ### Analytic + separate out val computation + switch order of loops + `@inbounds` + Multi-threading

using Hwloc
Hwloc.num_physical_cores()

Base.Threads.nthreads()

using ThreadPinning
pinthreads(:compact)

# +
import Base.Threads: @threads

function work6_threaded!(A, B, v, N)
    val = [-cos(2*mod(x,256)) for x in v]

    @inbounds @threads for j in 1:N
        for i in 1:N
            A[i,j] = B[i,j]*val[i];
        end
    end;
end

@btime work6_threaded!($A, $B, $v, $N);
# -

runtime = @belapsed work6_threaded!($A, $B, $v, $N);
perf = N * N * 1e-6 / runtime # MIt/s
println("Performance: $perf MIt/s")



# ## Bonus Question: Performance limit?
#
# Look at your final optimized version of `work!`.
#
# * What is conceptually limiting the performance? I.e. is the function compute- or memory-bound?
# * How fast can it "theoretically" be? Can you estimate a performance bound?

using STREAMBenchmark
membw = memory_bandwidth(verbose=true, write_allocate=true)

# +
bs = membw.maximum * 1e-3 # [GB/s] max memory bandwidth
flops = 1
traffic = 3 * 8 # [B/iter] in each iteration

I = flops / traffic
perf_membound = round(I * bs * 1000, digits=2)
runtime_membound = N * N * 1e-6 / perf_membound # in s
println("Memory bounded performance: ", perf_membound, " MIt/s")
println("Memory bounded runtime estimate: ", runtime_membound * 1e3, " ms")
# -

# comparison
runtime = @belapsed work6_threaded!($A, $B, $v, $N)
@show runtime
@show runtime_membound
ratio = runtime_membound / runtime
println("\nWe achieve about ", round(ratio * 100; digits=1), "% of the (practical) memory bound estimate.")
