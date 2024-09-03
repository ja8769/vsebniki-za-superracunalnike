#!/bin/bash

#SBATCH --job-name=np
##SBATCH --reservation=psistemi	
#SBATCH --cpus-per-task=1
#SBATCH --output=out/out.txt
#SBATCH --time=00:10:00	
#SBATCH --mem=1G

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1

module is-loaded OpenMPI/4.1.2 || \
	module load OpenMPI/4.1.2

mpirun sh -c "echo hostname: \$(hostname)"

IMAGE="${HOME}/apptainer-builds/alma-netpipe+latest.sif"
OUTPUT_DIR="${HOME}/bench/netpipe/apptainer/out"
NP_ARGS="${NP_ARGS:-"\
	--quickest \
	--printhostnames \
	"}"

mpirun \
	apptainer exec \
	"$IMAGE" \
	/bin/NPmpi \
		-o "${OUTPUT_DIR}/np.out" \
		$NP_ARGS

