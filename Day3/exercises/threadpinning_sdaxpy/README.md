# Exercise: Thread Affinity and Performance Scaling

**Note: This exercise should be done on a Hawk compute node.**

In the following exercise you will make yourself familiar with the basics of ThreadPinning.jl and use it to analyze the **performance scaling** of a **Schönauer Triad** kernel (`a[i] = a[i] + b[i] * c[i]`, i.e. without write allocate) for **three different thread pinning schemes**. You will also learn about a subtle NUMA-related performance pitfall.

1. Make yourself familiar with `threadinfo()` and `pinthreads()` from ThreadPinning.jl. For example:
    * Start a Julia session with multiple threads (e.g. `-t 10`).
    * Use `threadinfo()` to see which cores / CPU threads the Julia threads are running on. (Note: try the keyword argument `groupby=:numa`)
    * Check `?pinthreads` to understand which pinning strategies are available and play around with them (always check with `threadinfo()` afterwards)

2. Use `threadinfo()` and, e.g., `ncores()`, `nnuma()`, `nsockets()`, `ncores_per_numa()` etc. to get a feeling for the architecture of the compute node.
    * How many NUMA domains are there?
    * How many cores constitute a NUMA domain?

3. Look at the given code file `sdaxpy_measurement.jl` and understand what it does.

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

6. What do you observe? Can you explain your findings?
    * Hint: Consider ratios of the numbers (e.g. "`:parallel / :serial`" for different pinning strategies). Can you explain the factors (approximately)?