using CUDA

"Computes the SAXPY on the GPU using broadcasting"
function saxpy_broadcast_gpu!(a, x, y)
    CUDA.@sync y .= a .* x .+ y
end

function main()
    a = 1.23f0
    x = CUDA.rand(1000)
    y = CUDA.rand(1000)
    CUDA.@profile saxpy_broadcast_gpu!(a,x,y)
end

main()
