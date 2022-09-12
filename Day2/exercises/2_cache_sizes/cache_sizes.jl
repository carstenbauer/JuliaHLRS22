using Plots
using BenchmarkTools
using CpuId

function vecmul!(c,a,b)
    #
    # TODO: Implement an element-wise vector multiplication kernel here!
    #       (i.e. c[i] = a[i] * b[i])
    #
    return c
end

function bench()
    Ns = round.(Int, exp10.(range(1, log10(10_000_000), length=250))) # vector lengths
    ts = Float64[] # should eventually timing results

    # TODO:
    #
    #  Perform timing measurements of the vecmul! function
    #  for input vectors of varying length (Ns above).
    #  The resulting times should go into `ts`.
    #
    #  Hint: use @belapsed from BenchmarkTools.jl which is similar to @btime
    #        but returns the (minimum) time in seconds.
    #
    #  (You may reduce the `length` argument in the `Ns = ...` line while testing / developing.)
    #

    return Ns, ts
end

function plot_results(Ns, ts)
    p = plot(Ns, Ns ./ ts * 1e-9, marker=:circle, label="vecmul!", frame=:box, ms=2, xscale=:log10)
    ylabel!(p, "gigaflops n/t")
    xlabel!(p, "vector size n")
    L1,L2,L3 = cachesize()
    mem = 3*sizeof(Float64) # three arrays a, b, c
    nL1 = L1/mem
    nL2 = L2/mem
    nL3 = L3/mem
    vline!(p, [nL1], color=:orange, lw=2, label="L1 = $(floor(Int, nL1)) ($(L1/1024) KB)")
    vline!(p, [nL2], color=:red, lw=2, label="L2 = $(floor(Int, nL2)) ($(L2/1024) KB)")
    vline!(p, [nL3], color=:purple, lw=2, label="L3 = $(floor(Int, nL3)) ($(L3/1024) KB)")
    return p
end

"""
Will perform the benchmark and save a plot of the results as png/svg files.
"""
function main()
    Ns, ts = bench()
    p = plot_results(Ns, ts)
    savefig(p, "cache_sizes.png")
    savefig(p, "cache_sizes.svg")
end

@time main()

# Note that depending on the density of considered vector lengths the
# entire benchmark (i.e. the `main()` call) may take up ~20 minutes.
