# Thread Pinning: Performance Scaling

1. Make yourself familiar with `threadinfo()` and `pinthreads()` from ThreadPinning.jl. For example:
    * Start a Julia session with multiple threads (e.g. `-t 10`).
    * Use `threadinfo()` to see which cores / CPU threads the Julia threads are running on. (Note: try the keyword argument `groupby=:numa`)
    * Check `?pinthreads` to understand which pinning strategies are available and play around with them (always check with `threadinfo()` afterwards)

**"Answer":** `pinthreads(:compact)` pins threads from the first core to the last. `pinthreads(:spread)` alternates between different sockets. `pinthreads(:numa)` alternates between NUMA domains.

2. Use `threadinfo()` and, e.g., `ncores()`, `nnuma()`, `nsockets()`, `ncores_per_numa()` etc. to get a feeling for the architecture of the compute node.
    * How many NUMA domains are there?
    * How many cores constitute a NUMA domain?

3. Look at the given code file `sdaxpy_measurement.jl` and understand what it does.

**"Answer":** It performs a timing measurement of a multi-threaded, memory-bound sdaxpy kernel (Schoenauer triad). From the known number of transferred bytes and performed FLOPs it then computes the empirical memory bandwidth in GB/s and the compute in GFLOP/s. For `init=:parallel` the used vectors are initialized in parallel (i.e. in the same way as the parallel kernel will later access them). The function `measure_sdaxpy_perf()` also takes a keyword argument `pin` which is directly passed into `ThreadPinning.pinthreads()` and can be used for choosing a specific thread pinning strategy.

4. To understand how thread pinning and array initialization(!) effect the observed performance, implement the function `scaling_analysis()` in the code file `exercise.jl`. Specifically, you should call `measure_sdaxpy_perf()` for different pinning strategies (`:compact`, `:spread`, and `:numa`), and both initialization variants (`:serial` and `:parallel`).
    * You can just print the results with, e.g., `println` or, optionally, use PrettyTables.jl to produce a nice tabular layout of the results (see below for an inspiration).
    * Note: You can skip this bit and use `solution_proposal/exercise_solution.jl) if you want to directly move on to performing measurements and analyzing the findings (points 5 and 6 below).

```
Memory Bandwidth (GB/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = X │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │   00.00 │     00.00 │
│       :spread │   00.00 │     00.00 │
│         :numa │   00.00 │     00.00 │
└───────────────┴─────────┴───────────┘
Compute (GFLOP/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = X │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │   00.00 │     00.00 │
│       :spread │   00.00 │     00.00 │
│         :numa │   00.00 │     00.00 │
└───────────────┴─────────┴───────────┘
```

5. Run the modified file `exercise.jl` for various number of threads, i.e. `julia --project -t n exercise.jl` for `n = 1,2,4,8` and collect all the results.

**Examplatory results:**

Memory Bandwidth (GB/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = 1 │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │   29.77 │     31.08 │
│       :spread │   29.58 │     30.61 │
│         :numa │   29.87 │     30.51 │
└───────────────┴─────────┴───────────┘
Compute (GFLOP/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = 1 │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │    1.86 │      1.94 │
│       :spread │    1.85 │      1.91 │
│         :numa │    1.87 │      1.91 │
└───────────────┴─────────┴───────────┘

Memory Bandwidth (GB/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = 2 │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │   34.86 │     35.66 │
│       :spread │   42.01 │      60.4 │
│         :numa │   39.66 │     60.64 │
└───────────────┴─────────┴───────────┘
Compute (GFLOP/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = 2 │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │    2.18 │      2.23 │
│       :spread │    2.63 │      3.78 │
│         :numa │    2.48 │      3.79 │
└───────────────┴─────────┴───────────┘

Memory Bandwidth (GB/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = 4 │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │    33.5 │     34.21 │
│       :spread │    48.1 │     70.17 │
│         :numa │   38.94 │    119.77 │
└───────────────┴─────────┴───────────┘
Compute (GFLOP/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = 4 │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │    2.09 │      2.14 │
│       :spread │    3.01 │      4.39 │
│         :numa │    2.43 │      7.49 │
└───────────────┴─────────┴───────────┘

Memory Bandwidth (GB/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = 8 │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │    33.0 │     33.44 │
│       :spread │   34.45 │      66.9 │
│         :numa │    34.3 │    233.05 │
└───────────────┴─────────┴───────────┘
Compute (GFLOP/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = 8 │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│      :compact │    2.06 │      2.09 │
│       :spread │    2.15 │      4.18 │
│         :numa │    2.14 │     14.57 │
└───────────────┴─────────┴───────────┘

Memory Bandwidth (GB/s)
┌────────────────┬─────────┬───────────┐
│ # Threads = 16 │ :serial │ :parallel │
├────────────────┼─────────┼───────────┤
│       :compact │   37.99 │     38.63 │
│        :spread │   34.09 │      66.3 │
│          :numa │   33.93 │    270.17 │
└────────────────┴─────────┴───────────┘
Compute (GFLOP/s)
┌────────────────┬─────────┬───────────┐
│ # Threads = 16 │ :serial │ :parallel │
├────────────────┼─────────┼───────────┤
│       :compact │    2.37 │      2.41 │
│        :spread │    2.13 │      4.14 │
│          :numa │    2.12 │     16.89 │
└────────────────┴─────────┴───────────┘

6. What do you observe? Can you explain your findings?
    * Hint: Consider ratios of the numbers (e.g. "`:parallel / :serial`" for different pinning strategies). Can you explain the factors (approximately)?

**"Answer":** We observe that a combination of spreading, i.e. between sockets (`:spread`) or NUMA domains (`:numa`), and parallel initialization can give much higher memory bandwidths and flops! The former is understood from the fact that we're utilizing multiple memory channels (typically) associated with different NUMA domains much more efficiently by putting threads in different domains (whereas for `:compact` we're filling NUMA domains gradually). The fact that `:parallel` is so crucial is more subtle and related to first touch policy. See https://discourse.julialang.org/t/poor-scaling-results-with-implicitglobalgrid-jl/65170/24 for more information.

**"Answer":** Let's consider `nthreads() == 8`. Essentially, we find the factors 1 (for `:compact`), 2 (for `:spread`) and 8 (for `:numa`). This makes quite a lot of sense since with 8 threads we are precisely using this many NUMA domains / memory channels with each pinning strategy.
