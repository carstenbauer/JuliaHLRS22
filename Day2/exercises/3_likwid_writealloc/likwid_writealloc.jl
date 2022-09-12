function striad!(a,b,c,d)
    for i in eachindex(a,b,c,d)
        a[i] = b[i] + c[i] * d[i]
    end
    return nothing
end

N = 1_000_000
a = rand(N)
b = rand(N)
c = rand(N)
d = rand(N)

striad!(a,b,c,d)

# 1) Looking at the Schoenhauer Triad kernel (i.e. the `striad!` function above),
# how many LOADs and STOREs to you expect to happen? Otherwise put, how many bytes do
# you think will need to be transferred to/from memory?
#
# 2) Use LIKWID.jl to empirically measure how much data has been read from / written to memory.
# Hint: @perfmon "MEM" striad!(a,b,c,d);
#
# 3) What do you find? Looking at the ratio of read and write traffic, what do you conclude
# for the number of LOADs and STOREs?
#
# Optional: Research "write-allocate" to find out more about what's going on.
