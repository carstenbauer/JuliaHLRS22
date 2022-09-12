using CUDA
using FLoops
using FoldsCUDA
using BenchmarkTools

function compute_pi(N)
    M = 0 # number of darts that landed in the circle
    for i in 1:N
        if sqrt(rand()^2 + rand()^2) < 1.0
            M += 1
        end
    end
    return 4 * M / N
end

function compute_pi_cuda(N)
    xs = CUDA.rand(Float32, N)
    M = count(x -> sqrt(x^2 + rand(Float32)^2) < 1, xs)
    return 4 * M / N
end

function compute_pi_floops_gpu(N)
    @floop CUDAEx() for i in 1:N
        hit = sqrt(rand(Float32)^2 + rand(Float32)^2) < 1
        @reduce(M = 0 + hit)
    end
    return 4 * M / N
end

function _mc_kernel!(counts, iter_per_thread)
    i = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    counter = CuStaticSharedArray(Int32, 32)
    counter[threadIdx().x] = 0

    for i in 1:iter_per_thread
        counter[threadIdx().x] += sqrt(rand(Float32)^2 + rand(Float32)^2) < 1
    end

    sync_warp()
    if threadIdx().x == 1 # first thread in the block
        for i in 1:32
            counts[blockIdx().x] += counter[i]
        end
    end
    return nothing
end

function compute_pi_cuda_kernel(N; nthreads=32, nblocks=6912)
    counts = CUDA.zeros(Int32, nblocks)
    iter_per_thread, r = divrem(N, nthreads * nblocks)
    if r > 0
        throw(ArgumentError("N / $(nthreads * nblocks) must be an integer"))
    end

    CUDA.@sync @cuda(
        threads = nthreads,
        blocks = nblocks,
        _mc_kernel!(counts, iter_per_thread)
    )
    return 4 * sum(counts) / N
end

# function _mc_kernel!(counts)
#     i = (blockIdx().x - 1) * blockDim().x + threadIdx().x
#     # if i <= length(counts)
#         if CUDA.rand()^2 + CUDA.rand()^2 < 1
#             @inbounds counts[i] = 1
#         end
#     # end
#     return nothing
# end

# function compute_pi_cuda_kernel(N; nthreads=32, nblocks=6912)
#     @assert N % nthreads * nblocks == 0
#     fac = N ÷ (nthreads * nblocks)
#     counts = CUDA.zeros(Int32, N)
#     CUDA.@sync @cuda(
#         threads = nthreads,
#         blocks = fac*nblocks,
#         _mc_kernel!(counts)
#     )
#     return 4 * sum(counts) / N
# end

function main()
    if !contains(lowercase(name(device())), "a100")
        @warn("This script was tuned for a NVIDIA A100 GPU. Your GPU: $(name(device())).")
    end
    N = 45 * 221_184 # 9953280 ≈ 10_000_000
    t_serial = @belapsed compute_pi($N) evals=3 samples=5;
    t_cuda = @belapsed compute_pi_cuda($N) evals=3 samples=5;
    t_floops = @belapsed compute_pi_floops_gpu($N) evals=3 samples=5;
    t_cuda_kernel = @belapsed compute_pi_cuda_kernel($N) evals=3 samples=5;

    println("Serial: ", round(t_serial * 1e6; digits=3), " μs")
    println("CUDA: ", round(t_cuda * 1e6; digits=3), " μs")
    println("FLoops: ", round(t_floops * 1e6; digits=3), " μs")
    println("CUDA kernel: ", round(t_cuda_kernel * 1e6; digits=3), " μs")
    return nothing
end

main()

# Example output:
# Serial: 46243.616 μs
# CUDA: 344.775 μs
# FLoops: 197.577 μs
# CUDA kernel: 233.154 μs


# For development
# N = 45 * 221_184
# compute_pi(N)
# compute_pi_cuda(N)
# compute_pi_floops_gpu(N)
# compute_pi_cuda_kernel(N)

# @btime compute_pi($N);
# @btime compute_pi_cuda($N);
# @btime compute_pi_floops_gpu($N);
# @btime compute_pi_cuda_kernel($N);
