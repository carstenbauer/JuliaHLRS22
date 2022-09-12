#!/bin/bash
#PBS -N gpu_membw_saxpy
#PBS -l select=1:node_type=nv-a100-40gb:mpiprocs=8
#PBS -l walltime=00:05:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd $PBS_O_WORKDIR

# load necessary modules
ml r
ml julia/cuda

# run program
julia --project gpu_membw_saxpy_solution.jl 
