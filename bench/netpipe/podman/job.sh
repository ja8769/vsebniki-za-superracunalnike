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
PROLOG_PODMAN="${HOME}/.config/containers/prolog.sh"
TMPDIR_BASE="/tmp/podman-mpirun-$UID"
OUTPUT_DIR="${HOME}/bench/netpipe/podman/out"
NP_ARGS="${NP_ARGS:-"\
	--quickest \
	--printhostnames \
	"}"

module is-loaded OpenMPI/4.1.2 || \
	module load OpenMPI/4.1.2

mpirun sh -c "echo hostname: \$(hostname)"

# First "podman run" job step usually fails with sbatch
srun --ntasks-per-node=1 --prolog="$PROLOG_PODMAN" podman run --rm "alpine" > /dev/null 2>&1

mpirun \
	--mca orte_tmpdir_base ${TMPDIR_BASE} \
	--mca prte_tmpdir_base ${TMPDIR_BASE} \
	sh -c " \
		sh $PROLOG_PODMAN ; \
		podman run \
			--rm --env-host \
			-v ${TMPDIR_BASE}:${TMPDIR_BASE} \
			-v ${OUTPUT_DIR}:/out \
			--userns=keep-id \
			--net=host \
			--pid=host \
			--ipc=host \
			$IMAGE \
			/bin/NPmpi \
				-o /out/np.out \
				$NP_ARGS
	"

