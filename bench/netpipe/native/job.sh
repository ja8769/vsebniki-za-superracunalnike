#!/bin/bash

#SBATCH --job-name=np
##SBATCH --reservation=psistemi	
#SBATCH --cpus-per-task=1
#SBATCH --output=out/out.txt
#SBATCH --time=00:10:00
#SBATCH --mem=1G

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1

NP_EXEC_PATH="${HOME}/bench/netpipe/native"
OUTPUT_DIR="${HOME}/bench/netpipe/native/out"
NP_ARGS="${NP_ARGS:-"\
	--quickest \
	--printhostnames \
	"}"

module is-loaded OpenMPI/4.1.2 || \
	module load OpenMPI/4.1.2

mpirun sh -c "echo hostname: \$(hostname)"

export LD_LIBRARY_PATH="${NP_EXEC_PATH}/libs:${LD_LIBRARY_PATH}"

mpirun \
	"${NP_EXEC_PATH}/NPmpi" -o "${OUTPUT_DIR}/np.out" $NP_ARGS
