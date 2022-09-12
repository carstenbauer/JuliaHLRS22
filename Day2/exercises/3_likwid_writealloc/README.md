# Exercise: LIKWID and Write Allocate

**Note: This exercise should be done on a Hawk compute node.** (You don't have LIKWID available on the laptop.)

In this exercise you will use **LIKWID.jl** to perform a "simple" memory-transfer analysis of a "**Schönauer Triad**" kernel (i.e. `a[i] = b[i] + c[i] * d[i]`).

The file `likwid_writealloc.jl` contains the instructions.