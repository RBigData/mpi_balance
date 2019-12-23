suppressMessages(library(pbdMPI))
suppressMessages(library(parallel))

host = system("hostname", intern = TRUE)

mc.function = function(x) {
    ## Put code for mclapply cores here
    Sys.getpid() # returns process id
}

## Compute how many cores per R session are on this node
ranks_per_node = as.numeric(system("echo $OMPI_COMM_WORLD_LOCAL_SIZE",
                                   intern = TRUE))
cores_on_my_node = detectCores()
cores_per_R = floor(cores_on_my_node/ranks_per_node)

## Run lapply on allocated cores to demonstrate fork pids
my_pids = mclapply(1:cores_per_R, mc.function, mc.cores = cores_per_R)
my_pids = do.call(paste, my_pids) # combines results from mclapply

## Same cores available for OpenBLAS (see openblasctl package)
##            or for other OpenMP enabled codes outside mclapply.
## If BLAS functions are called inside mclapply, they compete for the
##            same cores: avoid or manage appropriately.

## Now report what happened and where
msg = paste0("Hello World from rank ", comm.rank(), " on host ", host, "\n",
             "      with ", cores_per_R, " cores allocated (", ranks_per_node,
             " R sessions sharing ", cores_on_my_node, " cores).\n",
             "      pid: ", my_pids, "\n")
comm.cat(msg, quiet = TRUE, all.rank = TRUE)


comm.cat("Total R sessions:", comm.size(), "Total cores:", cores_total, "\n",
         quiet = TRUE)

finalize()

