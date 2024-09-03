#!/bin/bash

#SBATCH --job-name=np
##SBATCH --reservation=psistemi
#SBATCH --cpus-per-task=1
#SBATCH --output=out/out.txt
#SBATCH --time=00:10:00	
#SBATCH --mem=1G

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1

IMAGE="ghcr.io/jan146/alma-netpipe:latest"
TMPDIR_BASE="/tmp/udocker-mpirun-$UID"
UDOCKER_EXEC_MODE="${UDOCKER_EXEC_MODE:-P1}"
CONT_NAME="netpipe_${UDOCKER_EXEC_MODE}"
OUTPUT_DIR="${HOME}/bench/netpipe/udocker/out_${UDOCKER_EXEC_MODE}"
NP_ARGS="${NP_ARGS:-"\
	--quickest \
	--printhostnames \
	"}"

module is-loaded Python || \
	module load Python

module is-loaded OpenMPI/4.1.2 || \
	module load OpenMPI/4.1.2

mpirun sh -c "echo hostname: \$(hostname)"

udocker create --name="$CONT_NAME" "$IMAGE"
udocker setup --execmode="$UDOCKER_EXEC_MODE" "$CONT_NAME"

mpirun \
	--mca orte_tmpdir_base "$TMPDIR_BASE" \
	udocker run \
		--nobanner \
		--volume="${OUTPUT_DIR}:/out" \
		--workdir="/out" \
		--volume="$TMPDIR_BASE" \
		--hostenv \
		--hostauth \
		--user="$USER" \
		"$CONT_NAME" \
		/bin/NPmpi \
			-o /out/np.out \
			$NP_ARGS

mpirun \
	rm -rf "$TMPDIR_BASE"

udocker rm "$CONT_NAME"

