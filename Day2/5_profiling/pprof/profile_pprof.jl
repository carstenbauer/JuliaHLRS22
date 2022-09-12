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

using Profile
using PProf

# compute / runtime
Profile.clear()
Profile.@profile matmul(1000, 100);
PProf.pprof(from_c = false)
