#!/bin/bash
#SBATCH -J hello_balance
#SBATCH -A ccsd
#SBATCH -p batch
#SBATCH -N 4
#SBATCH --ntasks-per-node 4
#SBATCH --mem=2G
#SBATCH -t 00:02:00
#SBATCH -e ./balance.e
#SBATCH -o ./balance.o
#SBATCH --mail-user=ost@ornl.gov
#SBATCH --mail-type=FAIL

cd ~/mpi_balance
pwd

## module names can vary on different platforms
module purge               # cades condo
module load PE-gnu/3.0     # cades condo
module load R/3.6.0        # cades condo
echo "loaded R"
module list

## prevent warning when fork is used with MPI
export OMPI_MCA_mpi_warn_on_fork=0

## run 4 x 4 = 16 R sessions as requested by SBATCH above
mpirun Rscript hello_balance.R
