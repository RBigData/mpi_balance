suppressMessages(library(pbdMPI))

format_pids = function(x) {
  ## splits the digits in integer vector x into a same and diff components, returning a two-component list
  ## with common part and different parts
  x = unlist(x)
  for(i in 1:5) {
    u = unique(x %/% 10^i)
    if(length(u) == 1) break
  }
  formatC(x, width = 8, format = "d", flag = "0")
  paste(paste0("(", u, ")"),
        paste(formatC(x - u*10^i, width = i, format = "d", flag = "0"), collapse = " "))
}

## Small fraction sleep for print synchronization. When zero, some printing may be 
## out of order due to different paths from different nodes.
nominal_work_time = 1
sleep_print = 0.01

## list R session info from rank 0 while others wait
if(comm.rank() == 0) {
  sessionInfo()
  cat("\n") # add newline
}
barrier()

## get node name
host = unlist(strsplit(system("hostname", intern = TRUE), split = "[.]"))[1]
rank = comm.rank()
size = comm.size()

mc.function = function(x) {
    Sys.sleep(nominal_work_time) # replace with your function for mclapply cores here
    Sys.getpid() # returns process id (optional)
}

## Compute how many cores per R session are on this node
ranks_on_my_node = as.numeric(Sys.getenv("OMPI_COMM_WORLD_LOCAL_SIZE"))
ranks_on_my_node_slurm = as.numeric(Sys.getenv("SLURM_NTASKS_PER_NODE"))
if(is.na(ranks_on_my_node)) ranks_on_my_node = ranks_on_my_node_slurm
cores_on_my_node = parallel::detectCores()
cores_per_R = floor(cores_on_my_node/ranks_on_my_node)
cores_total = allreduce(cores_per_R)  # adds up over ranks

## Run and time mclapply on allocated cores to demonstrate fork pids
barrier()
time0 = Sys.time()
my_mcpids = parallel::mclapply(1:cores_per_R, mc.function, mc.cores = cores_per_R)
time1 = Sys.time()
time0 = reduce(as.numeric(time0), op = "min") # gather each rank's time to rank 0
time1 = reduce(as.numeric(time1), op = "max") # gather each rank's time to rank 0

##
## Same cores are shared with OpenBLAS (see flexiblas package)
##            or for other OpenMP enabled codes outside mclapply.
## If BLAS functions are called inside mclapply, they compete for the
##            same cores: avoid or manage appropriately!!!

## Now report what happened and where
msg = paste0("Hello from rank ", rank, " on node ", host, " claiming ",
             cores_per_R, " cores.", "(", ranks_on_my_node, 
             " Rs on ", cores_on_my_node, " cores).\n",
             "      pid: ", format_pids(my_mcpids), "\n")
comm.cat(msg, quiet = TRUE, all.rank = TRUE)

Sys.sleep(sleep_print) ## grace for all Hellos to propagate from nodes
barrier() ## wait to finish all Hellos, then start writing summary by rank 0
comm.cat("\nTotal R sessions:", size, "   Total cores:", cores_total, "\n", quiet = TRUE)
comm.cat(cores_total*numinal_work_time, "seconds of nominal work done in", time1 - time0, "seconds\n", quiet = TRUE)
comm.cat("\nNotes: cores on node obtained by: detectCores {parallel}\n",
         "       ranks (R sessions) per node: OMPI_COMM_WORLD_LOCAL_SIZE\n",
         "       pid to core map changes frequently during mclapply\n",
         quiet = TRUE)

finalize()

