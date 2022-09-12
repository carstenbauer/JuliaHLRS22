# # Exercise: Performance Optimization 1

# Optimize the following code.
#
# (The type and size of the input is fixed/may not be changed.)

# +
function work!(A, N)
    D = zeros(N,N)
    for i in 1:N
        D = b[i]*c*A
        b[i] = sum(D)
    end
end

N = 100
A = rand(N,N)
b = rand(N)
c = 1.23

work!(A,N)
# -

using BenchmarkTools
@btime work!($A, $N);

# ## Optimizations

# ### Avoiding globals

@code_warntype work!(A,N)

function work1!(A, N, b, c) # b and c are now function arguments
    D = zeros(N,N)
    for i in 1:N
        D = b[i]*c*A
        b[i] = sum(D)
    end
end

@code_warntype work1!(A,N,b,c)

@btime work1!($A, $N, $b, $c);

# ### Avoiding globals + temporary allocations

# +
function work2!(A, N, b)
    D = zeros(N,N)
    for i in 1:N
        @. D = b[i]*c*A
        b[i] = sum(D)
    end
end

@btime work2!($A, $N, $b);

# +
function work3!(A, N, b, c)
    D = zeros(N,N)
    for i in 1:N
        @inbounds for j in eachindex(D)
            D[j] = b[i]*c*A[j]
        end
        b[i] = sum(D)
    end
end

@btime work3!($A, $N, $b, $c);
# -

# ### Avoiding globals + temporary allocations and merging `sum` with loop

# +
function work4!(A, N, b, c)
    D = zeros(N,N)
    for i in 1:N
        s = zero(eltype(D))
        @inbounds @simd for j in eachindex(D)
            D[j] = b[i]*c*A[j]
            s += D[j]
        end
        b[i] = s
    end
end

@btime work4!($A, $N, $b, $c);
# -

# ### Realizing that one can factor out `b` and `c`

# +
# function work!(A, N)
#     D = zeros(N,N)
#     for i in 1:N
#         D = b[i]*c*A
#         b[i] = sum(D)
#     end
# end

# function work!(A, N)
#     for i in 1:N
#         b[i] = sum(b[i]*c*A)
#     end
# end

# function work!(A, N)
#     for i in 1:N
#         b[i] = b[i]*c*sum(A)
#     end
# end

# function work!(A, N)
#     D = c*sum(A)
#     for i in 1:N
#         b[i] *= D
#     end
# end

function work5!(A, N, b, c)
    D = c * sum(A)
    b .*= D
end

@btime work5!($A, $N, $b, $c);
# -
