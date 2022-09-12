#
# You shouldn't modify this file!
#
using CpuId
using Base.Threads: nthreads, @threads
using BenchmarkTools
using Statistics
using ThreadPinning

"""
Choose a (hopefully) reasonable default vector length based on the size
of the outermost (L3) cache and the number of available NUMA domains.
"""
default_vector_length() = Int(nnuma() * last(CpuId.cachesize()) / sizeof(Float64))

"""
Multithreaded Schoenauer triad kernel (SDAXPY): A[i] = A[i] + B[i] * C[i]
"""
function sdaxpy_kernel(A, B, C)
    @threads :static for i in eachindex(A, B, C)
        @inbounds A[i] = A[i] + B[i] * C[i]
    end
    return nothing
end

"""
  measure_membw(; kwargs...) -> membw, flops

Estimate the memory bandwidth (GB/s) by performing a time measurement of a
sdaxpy kernel (Schoenauer triad). Returns the memory bandwidth (GB/s) and the
compute (GFLOP/s).

**Keyword arguments:**
- `niter` (default: `10``): number of benchmark iterations
- `pin` (default: `:compact`): pinning strategy (supported by ThreadPinning)
- `init` (default: `:serial`): initialize arrays in serial or in parallel (`:parallel`)
"""
function measure_membw(; pin=:compact, init=:serial, verbose=true)
    N = default_vector_length()
    bytes = 4 * sizeof(Float64) * N # num bytes transferred in sdaxpy
    flops = 2 * N # num flops in sdaxpy

    # pinning the Julia threads
    ThreadPinning.pinthreads(pin)

    if init == :parallel
        # initialize data in parallel (important for NUMA / first-touch policy)
        A = Vector{Float64}(undef, N)
        B = Vector{Float64}(undef, N)
        C = Vector{Float64}(undef, N)
        @threads :static for i in eachindex(A, B, C)
            A[i] = rand()
            B[i] = rand()
            C[i] = 0.0
        end
    else
        # initialize naively (serially)
        A = rand(N)
        B = rand(N)
        C = zeros(N)
    end
    t = @belapsed sdaxpy_kernel($A, $B, $C) evals = 2 samples = 10
    mem_rate = bytes * 1e-9 / t # GB/s
    flop_rate = flops * 1e-9 / t # GFLOP/s
    if verbose
        println("Pinning: $pin, Init: $init")
        println("\tMemory Bandwidth (GB/s): ", round(mem_rate; digits=2))
        println("\tCompute (GFLOP/s): ", round(flop_rate; digits=2))
    end
    return mem_rate, flop_rate
end
