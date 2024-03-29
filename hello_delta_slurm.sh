#!/bin/bash
#SBATCH --job-name bal
#SBATCH --account=<your-account>
#SBATCH --partition=cpu
#SBATCH --nodes=2
#SBATCH --mem=0
#SBATCH --exclusive
#SBATCH --time 00:00:10
#SBATCH -e ./bal.e
#SBATCH -o ./bal.o
#SBATCH --mail-user=ost@ornl.gov
#SBATCH --mail-type=FAIL

cd ~/mpi_balance
pwd

## module names can vary on different platforms
module load openblas
module load flexiblas
module load r
echo "loaded R"
module list

## prevent warning when fork is used with MPI
export OMPI_MCA_mpi_warn_on_fork=0

# An illustration of fine control of R scripts and cores on several nodes
# This runs 4 R sessions on each of 4 nodes (for a total of 16).
#
# Each of the 16 hello_world.R scripts will calculate how many cores are
# available per R session from PBS environment variables and use that many
# in mclapply.
# 
# NOTE: center policies may require dfferent parameters
#
# nodes and mapping coordinated with slurm by openmpi
mpirun --map-by ppr:4:node Rscript hello_balance.R
