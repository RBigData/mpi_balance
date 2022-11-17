suppressMessages(library(pbdMPI))

## get node name
host = unlist(strsplit(system("hostname", intern = TRUE), split = "[.]"))[1]
rank = comm.rank()
size = comm.size()

mc.function = function(x) {
    Sys.sleep(1) # replace with your function for mclapply cores here
    Sys.getpid() # returns process id
}

## Compute how many cores per R session are on this node
local_ranks_query = "echo $OMPI_COMM_WORLD_LOCAL_SIZE"
ranks_on_my_node = as.numeric(system(local_ranks_query, intern = TRUE))
cores_on_my_node = parallel::detectCores()
cores_per_R = floor(cores_on_my_node/ranks_on_my_node)
cores_total = allreduce(cores_per_R)  # adds up over ranks

## Run mclapply on allocated cores to demonstrate fork pids
barrier()
mc_time = system.time({
my_mcpids = parallel::mclapply(1:cores_per_R, mc.function, mc.cores = cores_per_R)
barrier()
})
my_mcpids = do.call(paste, my_mcpids) # combines results from mclapply

## Run lapply this time with same function
l_time = system.time({
  my_pids = lapply(1:cores_per_R, mc.function)
})

##
## Same cores are shared with OpenBLAS (see flexiblas package)
##            or for other OpenMP enabled codes outside mclapply.
## If BLAS functions are called inside mclapply, they compete for the
##            same cores: avoid or manage appropriately!!!

## Now report what happened and where
msg = paste0("Hello from rank ", rank, " on node ", host, " claiming ",
             cores_per_R, " cores.", "(", ranks_on_my_node, 
             " Rs on ", cores_on_my_node, " cores).\n",
             "      pid: ", my_mcpids, "\n")
comm.cat(msg, quiet = TRUE, all.rank = TRUE)

comm.cat("Total R sessions:", size, "Total cores:", cores_total, "\n",
         quiet = TRUE)
comm.cat("\nNotes: cores on node obtained by: detectCores {parallel}\n",
         "       ranks (R sessions) per node: OMPI_COMM_WORLD_LOCAL_SIZE\n",
         "       pid to core map changes frequently during mclapply\n",
         quiet = TRUE)

comm.cat("\nFor correct scaling, time lapply ~", cores_per_R, "* mclapply\n", 
         quiet = TRUE)
comm.cat("     mclapply time on each of the", size, "ranks:", mc_time[3], "\n", 
         quiet = TRUE)
comm.cat("     lapply time on each of the", size, "ranks:", l_time[3], "\n\n", 
         quiet = TRUE)

finalize()

