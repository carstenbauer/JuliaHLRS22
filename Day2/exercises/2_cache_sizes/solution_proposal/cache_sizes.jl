using Plots
using BenchmarkTools
using CpuId

function vecmul!(c,a,b)
    @assert length(a) == length(b) == length(c)
    n = length(c)
    @inbounds for i in 1:n
        c[i] = a[i] * b[i]
    end
    return c
end

function bench()
    Ns = round.(Int, exp10.(range(1, log10(10_000_000), length=250)))
    ts = Float64[]
    for n in Ns
        a = fill(1.2, n)
        b = fill(0.8, n)
        c = fill(3.14, n)
        push!(ts, @belapsed vecmul!($c, $a,$b))
        println("finished n = $n, time: ", ts[end], " flops/t: ", n/ts[end])
    end
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
