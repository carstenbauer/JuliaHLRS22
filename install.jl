ENV["JULIA_MPI_BINARY"]="" # use BB
ENV["JULIA_CUDA_USE_BINARYBUILDER"]="true" # use BB

using Pkg
println("\n\n\tActivating environment in $(pwd())...")
pkg"activate ."
println("\n\n\tInstantiating environment... (i.e. downloading + installing + precompiling packages)"); flush(stdout);
pkg"instantiate"
pkg"precompile"

println("\n\n\tLoading PythonCall... (to trigger Conda related downloads / installations)"); flush(stdout);
using PythonCall

println("\n\n\tInstalling mpiexecjl ..."); flush(stdout);
using MPI
MPI.install_mpiexecjl(; force=true)
println("\n\n\t!!!!!!!!!!\n\tYou need to manually put mpiexecjl on PATH. Put the following into your .bashrc (or similar):"); flush(stdout);
println("\t\texport PATH=$(joinpath(DEPOT_PATH[1], "bin")):\$PATH"); flush(stdout);
println("\t!!!!!!!!!!")

println("\n\n\tDone!")
