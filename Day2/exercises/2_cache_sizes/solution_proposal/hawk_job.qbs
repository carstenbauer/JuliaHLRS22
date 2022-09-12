#!/bin/bash
#PBS -N cache_sizes
#PBS -l select=1:node_type=rome
#PBS -l walltime=00:45:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd $PBS_O_WORKDIR

# load necessary modules
ml r
ml julia

# run program
julia --project cache_sizes.jl
