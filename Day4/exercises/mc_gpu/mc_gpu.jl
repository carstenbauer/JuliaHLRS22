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
    xs = CUDA.rand(Float32, N) # random x coordinates (on the GPU)
    #
    # TODO: Use the high-level function `count(f, itr)` and `xs` above
    #       to implement the Monte Carlo sampling of π on the GPU.
    #
    return 4 * M / N
end

function compute_pi_floops_gpu(N)
    #
    # TODO: Use `@floop CUDAEx() for ...`
    #       to implement the Monte Carlo sampling of π on the GPU.
    #
    return 4 * M / N
end

function _mc_kernel!(counts)
    i = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    #
    # TODO: Implement a CUDA kernel for the Monte Carlo sampling of π
    #
    return nothing
end

function compute_pi_cuda_kernel(N; nthreads=32, nblocks=6912) # change nthreads and nblocks to match your kernel
    #
    # TODO: Launch your CUDA kernel `_mc_kernel!` such that `N` random draws
    #       have been used to estimate π
    #
    # Hint:     CUDA.@sync @cuda(
    #               threads = nthreads,
    #               blocks = nblocks,
    #               _mc_kernel!(counts)
    #           )
end

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
