#!/bin/bash
#SBATCH -J hello_balance
#SBATCH -A GEN011
#SBATCH -p batch
#SBATCH --nodes=4
#SBATCH --mem=2G
#SBATCH -t 00:00:10
#SBATCH -e ./balance.e
#SBATCH -o ./balance.o

cd ~/mpi_balance
pwd

## modules are specific to andes.olcf.ornl.gov
module load openblas/0.3.17-omp
module load flexiblas
flexiblas add OpenBLAS $OLCF_OPENBLAS_ROOT/lib/libopenblas.so
export LD_PRELOAD=$OLCF_FLEXIBLAS_ROOT/lib64/libflexiblas.so
module load r
echo -e "loaded R with FlexiBLAS"

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
# nodes and mapping picked up from slurm by openmpi
mpirun --map-by ppr:4:node Rscript hello_balance.R
