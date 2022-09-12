# # Exercise: Distributed Monte Carlo (MPI)

# Calculate the value of $\pi$ through parallel direct Monte Carlo.
#
# A unit circle is inscribed inside a unit square with side length 2 (from -1 to 1). The area of the circle is $\pi$, the area of the square is 4, and the ratio is $\pi/4$. This means that, if you throw $N$ darts randomly at the square, approximately $M=N\pi/4$ of those darts will land inside the unit circle.
#
# Throw darts randomly at a unit square and count how many of them ($M$) landed inside of a unit circle. Approximate $\pi \approx 4M/N$. Visualization:

# +
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
# 1. Based on `compute_pi`, write a MPI script that computes $\pi$ but divides the work among the available MPI ranks (i.e. each rank runs `compute_pi` for a certain `N_local` and, afterwards, the results are then `MPI.Reduce`d to the master).
#
# 3. How does the performance of 2) compare to Distributed.jl and/or a multithreaded implementation (other exercises)?
#
# A reasonable value could be `N = 10_000_000`.
