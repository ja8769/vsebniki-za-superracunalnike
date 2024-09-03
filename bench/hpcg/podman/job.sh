#!/bin/bash

#SBATCH --job-name=hpcg	
##SBATCH --reservation=psistemi	
#SBATCH --output=out/out.txt
#SBATCH --time=00:30:00
#SBATCH --mem=16G

IMAGE="ghcr.io/jan146/alma-hpcg:latest"
PROLOG_PODMAN="${HOME}/.config/containers/prolog.sh"
TMPDIR_BASE="/tmp/podman-mpirun-$UID"
OUTPUT_DIR="${HOME}/bench/hpcg/podman/out"
OUTPUT_FILE="${OUTPUT_DIR}/hpcg.out"
HPCG_ARGS="${HPCG_ARGS:-"--nx=16 --ny=16 --nz=16 --rt=10"}"
HPCG_THREADS_PER_PROC="${HPCG_THREADS_PER_PROC:-1}"

module is-loaded OpenMPI/4.1.2 || \
	module load OpenMPI/4.1.2

mpirun sh -c "echo hostname: \$(hostname)"

# First "podman run" job step usually fails with sbatch
srun \
    --ntasks-per-node=1 --nodes=$SLURM_NNODES \
    --prolog="$PROLOG_PODMAN" \
        podman run --rm "alpine" > /dev/null 2>&1

mpirun \
	--mca orte_tmpdir_base "$TMPDIR_BASE" \
	sh -c " \
		sh $PROLOG_PODMAN ; \
		podman run \
			--rm --env-host \
            --env OMP_NUM_THREADS=${HPCG_THREADS_PER_PROC} \
			-v ${TMPDIR_BASE}:${TMPDIR_BASE} \
			-v ${OUTPUT_DIR}:/out \
			--userns=keep-id \
			--net=host \
			--pid=host \
			--ipc=host \
			$IMAGE \
				/out $HPCG_ARGS \
	"

cat "$OUTPUT_DIR"/HPCG-Benchmark*.txt
rm "$OUTPUT_DIR"/hpcg*.txt
rm "$OUTPUT_DIR"/HPCG-Benchmark*.txt
