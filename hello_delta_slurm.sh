#!/bin/bash
#SBATCH --job-name bal
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --nodes=2
#SBATCH --tasks=8
#SBATCH --tasks-per-node=4
#SBATCH --time 00:00:10
#SBATCH -e ./bal.e
#SBATCH -o ./bal.o

cd ~/git/mpi_balance
pwd
export

## module names can vary on different platforms
module load openblas
module load flexiblas
module load r
echo "loaded R"
module list

## prevent warning when fork is used with MPI
export OMPI_MCA_mpi_warn_on_fork=0

# An illustration of fine control of R scripts and cores on several nodes
# This runs 4 R sessions on each of 2 nodes (for a total of 8).
#
# Each of the 8 hello_world.R scripts will calculate how many cores are
# available per R session from Slurm environment variables and use that many
# in mclapply.
# 
# NOTE: center policies may require dfferent parameters
#
# nodes and mapping coordinated with slurm by openmpi
Rscript hello_balance.R
