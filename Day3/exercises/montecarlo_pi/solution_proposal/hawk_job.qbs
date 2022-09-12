#!/bin/bash
#PBS -N mc_mpi_solution
#PBS -l select=1:node_type=rome:mpiprocs=128
#PBS -l walltime=00:02:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd $PBS_O_WORKDIR

# load necessary modules
ml r
ml julia

# run program
mpiexecjl --project -n 6 julia mc_mpi_solution.jl
