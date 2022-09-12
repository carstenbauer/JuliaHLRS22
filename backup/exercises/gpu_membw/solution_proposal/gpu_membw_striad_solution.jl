#
# STRIAD (Schoenauer Triad): a[i] = b[i] + c[i] * d[i]
#
using CUDA
using BenchmarkTools
using PrettyTables

"Computes the GFLOP/s from the vector length `len` and the measured runtime `t`."
striad_flops(t; len) = 2 * len * 1e-9 / t # GFLOP/s

"Computes the GB/s from the vector length `len`, the vector element type `dtype`, and the measured runtime `t`."
striad_bandwidth(t; dtype, len) = 4 * sizeof(dtype) * len * 1e-9 / t # GB/s

"Computes the STRIAD on the CPU using broadcasting"
function striad_broadcast_cpu!(a, b, c, d)
    a .= b .+ c .* d
end

"Computes the STRIAD on the GPU using broadcasting"
function striad_broadcast_gpu!(a, b, c, d)
    CUDA.@sync a .= b .+ c .* d
end

"CUDA kernel for computing the STRIAD on the GPU"
function _striad_kernel!(a, b, c, d)
    i = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if i <= length(a)
        @inbounds a[i] = b[i] + c[i] * d[i]
    end
    return nothing
end

"Computes the STRIAD on the GPU using the custom CUDA kernel `_striad_kernel!`"
function striad_cuda_kernel!(a, b, c, d; nthreads, nblocks)
    CUDA.@sync @cuda(
        threads = nthreads,
        blocks = nblocks,
        _striad_kernel!(a, b, c, d)
    )
end

function main()
    if !contains(lowercase(name(device())), "a100")
        @warn("This script was tuned for a NVIDIA A100 GPU. Your GPU: $(name(device())).")
    end
    dtype = Float32
    nthreads = 1024 # CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK
    nblocks = 500_000
    len = nthreads * nblocks # vector length
    a = rand(dtype, len)
    b = rand(dtype, len)
    c = rand(dtype, len)
    d = rand(dtype, len)
    agpu = CUDA.rand(dtype, len)
    bgpu = CUDA.rand(dtype, len)
    cgpu = CUDA.rand(dtype, len)
    dgpu = CUDA.rand(dtype, len)

    t_broadcast_cpu = @belapsed striad_broadcast_cpu!($a, $b, $c, $d) samples = 10 evals = 2
    t_broadcast_gpu = @belapsed striad_broadcast_gpu!($agpu, $bgpu, $cgpu, $dgpu) samples = 10 evals = 2
    t_cuda_kernel = @belapsed striad_cuda_kernel!($agpu, $bgpu, $cgpu, $dgpu; nthreads=$nthreads, nblocks=$nblocks) samples = 10 evals = 2
    times = [t_broadcast_cpu, t_broadcast_gpu, t_cuda_kernel]

    flops = striad_flops.(times; len)
    bandwidths = striad_bandwidth.(times; dtype, len)

    labels = ["Broadcast (CPU)", "Broadcast (GPU)", "CUDA kernel"]
    data = hcat(labels, 1e3 .* times, flops, bandwidths)
    pretty_table(data; header=(["Variant", "Runtime", "FLOPS", "Bandwidth"], ["", "ms", "GFLOP/s", "GB/s"]))
    println("Theoretical Memory Bandwidth: 1555 GB/s")
    return nothing
end

main()

# Example output:
# ┌─────────────────┬─────────┬─────────┬───────────┐
# │         Variant │ Runtime │   FLOPS │ Bandwidth │
# │                 │      ms │ GFLOP/s │      GB/s │
# ├─────────────────┼─────────┼─────────┼───────────┤
# │ Broadcast (CPU) │ 366.643 │ 2.79291 │   22.3433 │
# │ Broadcast (GPU) │ 6.58585 │ 155.485 │   1243.88 │
# │     CUDA kernel │ 6.11236 │ 167.529 │   1340.23 │
# └─────────────────┴─────────┴─────────┴───────────┘
# Theoretical Memory Bandwidth: 1555 GB/s
