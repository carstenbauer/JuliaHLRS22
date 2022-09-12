using LIKWID

function matmul(n, k=n)
    A = rand(n, k)
    B = rand(k, n)
    C = zeros(n, n)
    # simple matmul implementation
    for n in axes(C, 2), m in axes(C, 1)
        Cmn = zero(eltype(C))
        for k in axes(A, 2)
            tmp = A[m, k] * B[k, n]
            Cmn += tmp
        end
        C[m, n] = Cmn
    end
    return C
end

metrics, events = @perfmon "FLOPS_DP" matmul(1000, 100);

function count_flops(f)
    metrics, events = perfmon(f, "FLOPS_DP"; print=false)
    flops_per_second = metrics["FLOPS_DP"][1]["DP [MFLOP/s]"] * 1e6
    runtime = metrics["FLOPS_DP"][1]["Runtime (RDTSC) [s]"]
    flops = round(Int, flops_per_second * runtime)
    return flops
end

N = 1000
K = 100
nflops_rand = 2 * N * K
nflops_matmul = 2 * N^2 * K
using Test
@test count_flops(() -> matmul(N, K)) ≈ nflops_matmul + nflops_rand
