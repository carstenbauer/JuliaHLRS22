#
# STRIAD (Schoenauer Triad): a[i] = b[i] + c[i] * d[i]
#
using CUDA
using BenchmarkTools
using PrettyTables

"Computes the GFLOP/s from the vector length `len` and the measured runtime `t`."
striad_flops(t; len) = nothing # TODO # GFLOP/s

"Computes the GB/s from the vector length `len`, the vector element type `dtype`, and the measured runtime `t`."
striad_bandwidth(t; dtype, len) = nothing # TODO # GB/s

"Computes the STRIAD on the CPU using broadcasting"
function striad_broadcast_cpu!(a, b, c, d)
    # TODO
end

"Computes the STRIAD on the GPU using broadcasting"
function striad_broadcast_gpu!(a, b, c, d)
    # TODO
end

"CUDA kernel for computing the STRIAD on the GPU"
function _striad_kernel!(a, b, c, d)
    # TODO
end

"Computes the STRIAD on the GPU using the custom CUDA kernel `_striad_kernel!`"
function striad_cuda_kernel!(a, b, c, d; nthreads, nblocks)
    # TODO
end

function main()
    if !contains(lowercase(name(device())), "a100")
        @warn("This script was tuned for a NVIDIA A100 GPU. Your GPU: $(name(device())).")
    end
    dtype = Float32
    nthreads = 1024 # CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK
    nblocks = 500_000
    len = nthreads * nblocks # vector length
    #
    # TODO:
    #   Initialize vectors a, b, c, d, agpu, bgpu, cgpu, and dgpu.
    #

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
