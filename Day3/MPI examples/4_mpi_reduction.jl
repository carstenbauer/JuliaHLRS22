using MPI

MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)

# local coin tossing
local_heads_count = count(i -> rand(Bool), 1:10)
# perform reduction
total_heads_count = MPI.Reduce(local_heads_count, +, 0, comm)

sleep(0.1*rank); @show local_heads_count

MPI.Barrier(comm)
if rank == 0
    println("Total sum: $total_heads_count")
end

MPI.Finalize()
