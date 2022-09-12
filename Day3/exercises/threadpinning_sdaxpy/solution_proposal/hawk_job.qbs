#!/bin/bash
#PBS -N threadpinning_sdaxpy
#PBS -l select=1:node_type=rome:mpiprocs=1
#PBS -l walltime=00:10:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd $PBS_O_WORKDIR

# load necessary modules
ml r
ml julia

# run program
julia --project -t 1 exercise_solution.jl
julia --project -t 2 exercise_solution.jl
julia --project -t 4 exercise_solution.jl
julia --project -t 8 exercise_solution.jl
julia --project -t 16 exercise_solution.jl
