#
# SAXPY: y[i] = a * x[i] + y[i]
#
using CUDA
using BenchmarkTools
using PrettyTables

"Computes the GFLOP/s from the vector length `len` and the measured runtime `t`."
saxpy_flops(t; len) = nothing # TODO # GFLOP/s

"Computes the GB/s from the vector length `len`, the vector element type `dtype`, and the measured runtime `t`."
saxpy_bandwidth(t; dtype, len) = nothing # TODO # GB/s

"Computes the SAXPY on the CPU using broadcasting"
function saxpy_broadcast_cpu!(a, x, y)
    # TODO
end

"Computes the SAXPY on the GPU using broadcasting"
function saxpy_broadcast_gpu!(a, x, y)
    # TODO
end

"CUDA kernel for computing the SAXPY on the GPU"
function _saxpy_kernel!(a, x, y)
    # TODO
end

"Computes the SAXPY on the GPU using the custom CUDA kernel `_saxpy_kernel!`"
function saxpy_cuda_kernel!(a, x, y; nthreads, nblocks)
    # TODO
end

function saxpy_cublas!(a, x, y)
    # TODO
end

function main()
    if !contains(lowercase(name(device())), "a100")
        @warn("This script was tuned for a NVIDIA A100 GPU. Your GPU: $(name(device())).")
    end
    dtype = Float32
    nthreads = 1024 # CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK
    nblocks = 500_000
    len = nthreads # vector length
    #
    # TODO:
    #   Initialize scalar a. (Make sure that a is of type `dtype` !!)
    #   Initialize vectors x, y, xgpu, and ygpu.
    #

    t_broadcast_cpu = @belapsed saxpy_broadcast_cpu!($a, $x, $y) samples = 10 evals = 2
    t_broadcast_gpu = @belapsed saxpy_broadcast_gpu!($a, $xgpu, $ygpu) samples = 10 evals = 2
    t_cuda_kernel = @belapsed saxpy_cuda_kernel!($a, $xgpu, $ygpu; nthreads=$nthreads, nblocks=$nblocks) samples = 10 evals = 2
    t_cublas = @belapsed saxpy_cublas!($a, $xgpu, $ygpu) samples = 10 evals = 2
    times = [t_broadcast_cpu, t_broadcast_gpu, t_cuda_kernel, t_cublas]

    flops = saxpy_flops.(times; len)
    bandwidths = saxpy_bandwidth.(times; dtype, len)

    labels = ["Broadcast (CPU)", "Broadcast (GPU)", "CUDA kernel", "CUBLAS"]
    data = hcat(labels, 1e3 .* times, flops, bandwidths)
    pretty_table(data; header=(["Variant", "Runtime", "FLOPS", "Bandwidth"], ["", "ms", "GFLOP/s", "GB/s"]))
    println("Theoretical Memory Bandwidth: 1555 GB/s")
    return nothing
end

main()
