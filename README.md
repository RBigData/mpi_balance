# mpi_balance 

A batch MPI example for slurm or PBS scheduler to illustrate balancing
the number of R instances per node and available cores per R
instance. The example combines
[pbdMPI](https://github.com/RBigData/pbdMPI) (from pbdr.org) with
`mclapply()` (from the parallel package).

The example is intended to provide practice and insight into how R
multinode and multicore concepts play out on a cluster. I hope that
understanding these concepts can lead to more efficient use of
parallel resources.

You may need to modify the SLURM or PBS parameter values and possibly
the `module`s that are loaded in the `hello_balance.pbs` and
`hello_balance.slurm` scripts to match your local requirements. We
would love to hear from you if you get this example to run with a
different job scheduler.

The script expects both files to be in a directory named
`~/mpi_balance`. Typically, this is submitted at the shell prompt on a
cluster login node using slurm by

```{sh}
$ sbatch hello_balance.slurm
```
or on one using PBS by
```{sh}
$ qsub hello_balance.pbs 
```

A correct execution produces two output files `balance.e` and
`balance.o`. The `balance.e` is the error output and a correct
execution only gives the loaded modules list. The `balance.o` gives
"Hello" messages from all ranks, specifying node names and process ids
used by `mclapply()` within each rank. The following is the output in
file `balance.o` obtained on one of ORNL's CADES clusters:

```
/home/ost/mpi_balance
loaded R
Hello World from rank 0 on host or-condo-c96.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 56636 56640 56644 56648 56652 56656 56660 56664
Hello World from rank 1 on host or-condo-c96.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 56637 56642 56646 56650 56653 56657 56661 56665
Hello World from rank 2 on host or-condo-c96.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 56635 56639 56643 56647 56651 56655 56659 56663
Hello World from rank 3 on host or-condo-c96.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 56638 56641 56645 56649 56654 56658 56662 56666
Hello World from rank 4 on host or-condo-c122.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 62034 62038 62042 62046 62050 62054 62058 62062
Hello World from rank 5 on host or-condo-c122.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 62035 62039 62043 62047 62051 62055 62059 62064
Hello World from rank 6 on host or-condo-c122.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 62033 62037 62041 62045 62049 62053 62057 62061
Hello World from rank 7 on host or-condo-c122.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 62036 62040 62044 62048 62052 62056 62060 62063
Hello World from rank 8 on host or-condo-c123.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 128743 128747 128751 128755 128759 128762 128766 128773
Hello World from rank 9 on host or-condo-c123.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 128745 128749 128753 128757 128761 128765 128771 128772
Hello World from rank 10 on host or-condo-c123.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 128742 128746 128750 128754 128758 128763 128767 128769
Hello World from rank 11 on host or-condo-c123.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 128744 128748 128752 128756 128760 128764 128768 128770
Hello World from rank 12 on host or-condo-c146.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 45706 45710 45714 45718 45722 45726 45734 45735
Hello World from rank 13 on host or-condo-c146.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 45707 45711 45715 45719 45723 45727 45730 45732
Hello World from rank 14 on host or-condo-c146.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 45705 45709 45713 45717 45721 45725 45729 45736
Hello World from rank 15 on host or-condo-c146.ornl.gov with 8 cores allocated
            (4 R sessions sharing 32 cores on this host node).
      pid: 45708 45712 45716 45720 45724 45728 45731 45733
Total R sessions: 16 Total cores: 128 

Notes: cores on node obtained by: detectCores {parallel}
        ranks (R sessions) per node: OMPI_COMM_WORLD_LOCAL_SIZE
        pid to core map changes frequently during mclapply
```

The corresponding `balance.e` output is:
```
Currently Loaded Modulefiles:
  1) gcc/8.1.0       2) openmpi/3.1.5   3) PE-gnu/3.0      4) R/3.6.0
```

Note that other multithreaded R packages using multiple cores are
managed similarly but each may have its own parameters that specify
the number of cores used. Some may require setting environment
variables.

Care must be taken to prevent oversubscribing available cores and
slowing things down. In particular, multithreaded BLAS (such as
OpenBLAS) may by default use all available cores on a node,
conflicting with other on-node MPI instances or processes forked by
mclapply. See also wrathematics/openblasctl on GitHub for OpenBLAS
thread control from R.

While this script illustrates how to manage availability of cores to
MPI ranks, the actual placement of threads is done by the OS. The OS
does a pretty good job in our experience, although there can be a
difference between theory and reality as is illustrated in this
[Multithreaded Programming post on
reddit](https://www.reddit.com/r/aww/comments/2oagj8/multithreaded_programming_theory_and_practice/).
