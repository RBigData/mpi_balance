# mpi_balance
A batch MPI example for a PBS scheduler of balancing the number of R
instances per node and available cores per R instance. The example
combines pbdMPI (from pbdr.org) with mclapply (from the parallel
package).

Note that other multithreaded R packages using multiple cores are
managed similarly but each may have its own parameters that specify
the number of cores used. Some may require setting environment
variables. Care must be taken. In particular, multithreaded BLAS (such
as OpenBLAS) my by default often use all available cores on a node,
conflicting with the on-node MPI instances.

See also wrathematics/openblasctl on GitHub for OpenBLAS thread control from R.
