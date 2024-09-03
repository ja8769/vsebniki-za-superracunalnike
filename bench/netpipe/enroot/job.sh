#!/bin/bash

#SBATCH --job-name=np
##SBATCH --reservation=psistemi	
#SBATCH --cpus-per-task=1
#SBATCH --output=out/out.txt
#SBATCH --time=00:10:00	
#SBATCH --mem=1G

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1

IMAGE="${HOME}/enroot-images/alma-netpipe+latest.sqsh"
CONFIG_ENROOT_MPI="${HOME}/.config/enroot/mpi.conf"
TMPDIR_BASE="/tmp/enroot-mpirun-$UID"
OUTPUT_DIR="${HOME}/bench/netpipe/enroot/out"
NP_ARGS="${NP_ARGS:-"\
	--quickest \
	--printhostnames \
	"}"

module is-loaded OpenMPI/4.1.2 || \
	module load OpenMPI/4.1.2

mpirun sh -c "echo hostname: \$(hostname)"

mpirun \
    --mca orte_tmpdir_base "$TMPDIR_BASE" \
	enroot start \
		--conf "$CONFIG_ENROOT_MPI" \
		--mount "${OUTPUT_DIR}:/out" \
		"$IMAGE" \
		/bin/NPmpi \
			-o /out/np.out \
			$NP_ARGS
