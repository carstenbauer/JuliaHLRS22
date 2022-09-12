@show Threads.nthreads()
@assert Threads.nthreads() > 1

gethostname()

# # Exercise: Parallel Monte Carlo (Threads)

# Calculate the value of $\pi$ through parallel direct Monte Carlo.
#
# A unit circle is inscribed inside a unit square with side length 2 (from -1 to 1). The area of the circle is $\pi$, the area of the square is 4, and the ratio is $\pi/4$. This means that, if you throw $N$ darts randomly at the square, approximately $M=N\pi/4$ of those darts will land inside the unit circle.
#
# Throw darts randomly at a unit square and count how many of them ($M$) landed inside of a unit circle. Approximate $\pi \approx 4M/N$. Visualization:

# +
ENV["GKS_ENCODING"] = "utf-8"
using Plots, Distributions

# plot circle
circlepts = Plots.partialcircle(0, 2π, 100)
plot(circlepts, aspect_ratio=:equal, xlims=(-1, 1), ylims=(-1, 1), legend=false, lw=3, grid=false, frame=:box)

# plot darts
N = 400
d = Uniform(-1, 1)
scatter!(rand(d, N), rand(d, N), ms=2.5, color=:black)
# -

# ### Basic Julia Implementation

function compute_pi(N)
    M = 0 # number of darts that landed in the circle
    for i in 1:N
        if sqrt(rand()^2 + rand()^2) < 1.0
            M += 1
        end
    end
    return 4 * M / N
end

compute_pi(10_000_000)

# ### Tasks
#
# 1. Based on `compute_pi`, write a function `compute_pi_parallel(N::Int)` which does the same but divides the work among the available `Threads.nthreads()` threads.
#
# 2. Benchmark and compare the serial and parallel variants.
#
# 3. Write a function `compute_pi_multiple(Ns::Vector{Int})` which computes $\pi$ for all given $N$ values. The function should be serial and based on `compute_pi`.
#
# 4. Write a function `compute_pi_multiple_parallel(Ns::Vector{Int})` which does the same as in 3) but in parallel by using multithreading. The function should also be based on `compute_pi`.
#
# 5. Benchmark and compare the methods from 3) and 4).
#
# 6. Calculate $\pi$ estimates for `Ns = ceil.(Int, exp10.(range(1, stop=8, length=50)))`. Plot $\pi$ vs $N$ on a semi-log plot (i.e. provide `xscale=:log10` as a keyword argument to `plot`).
#
# 7. Bonus: Try to write a function `compute_pi_multiple_double_parallel(Ns::Vector{Int})` which computes $\pi$ for all given $N$ values. The calculation should be "as parallel as possible". Multiple different values of $N$ should be calculated at the same time and every one of those calculations should be parallel as well.
#
# A reasonable value could be `N = 10_000_000`.

using BenchmarkTools
using LinearAlgebra

# +
# 1) + 2)
function compute_pi_parallel_threads(N::Int)
    nt = Threads.nthreads()
    pis = zeros(nt)
    Threads.@threads for i in 1:nt
        pis[i] += compute_pi(ceil(Int, N / nt))
    end
    return sum(pis) / nt  # average value
end

tmap(f, itr) = map(fetch, map(i -> Threads.@spawn(f(i)), itr))

function compute_pi_parallel_spawn(N::Int)
    nt = Threads.nthreads()
    pis = tmap(i -> compute_pi(ceil(Int, N / nt)), 1:nt)
    return sum(pis) / nt  # average value
end

@btime compute_pi_parallel_threads(10_000_000)
@btime compute_pi_parallel_spawn(10_000_000)
# -

# 2)
@btime compute_pi(10_000_000)

# +
# 3) + 5)
function compute_pi_multiple(Ns::Vector{Int})
    pis = zeros(length(Ns))

    for i = 1:length(Ns)
        pis[i] = compute_pi(Ns[i])
    end

    return pis
end

some_Ns = [1_000_000, 2_000_000, 3_000_000, 4_000_000]

@btime compute_pi_multiple(some_Ns)

# +
# 4) + 5)

function compute_pi_multiple_parallel_threads(Ns::Vector{Int})
    pis = zeros(length(Ns))
    Threads.@threads for i in 1:length(pis)
        pis[i] += compute_pi(Ns[i])
    end
    return pis
end

function compute_pi_multiple_parallel_spawn(Ns::Vector{Int})
    return tmap(compute_pi, Ns)
end

some_Ns = [1_000_000, 2_000_000, 3_000_000, 4_000_000]

@btime compute_pi_multiple_parallel_threads($some_Ns)
@btime compute_pi_multiple_parallel_spawn($some_Ns)

# +
# 7)

function compute_pi_multiple_nested_parallel_threads(Ns::Vector{Int})
    pis = zeros(length(Ns))
    Threads.@threads for i in 1:length(pis)
        pis[i] += compute_pi_parallel_threads(Ns[i])
    end
    pis
end

function compute_pi_multiple_nested_parallel_spawn(Ns::Vector{Int})
    tmap(compute_pi_parallel_spawn, Ns)
end

some_Ns = [1_000_000, 2_000_000, 3_000_000, 4_000_000]

@btime compute_pi_multiple_nested_parallel_threads($some_Ns)
@btime compute_pi_multiple_nested_parallel_spawn($some_Ns)

# +
# 6)
Ns = ceil.(Int, exp10.(range(1, stop=8, length=50)))
@time pis = compute_pi_multiple_nested_parallel_spawn(Ns)

plot(Ns, pis, color=:black, marker=:circle, lw=1, label="MC", xscale=:log10)
plot!(x -> π, label="π", xscale=:log10, linestyle=:dash, color=:red, lw=2)
ylabel!("π estimate")
xlabel!("number of dart throws N")
# -
