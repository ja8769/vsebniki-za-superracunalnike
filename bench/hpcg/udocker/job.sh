#!/bin/bash

#SBATCH --job-name=hpcg	
##SBATCH --reservation=psistemi	
#SBATCH --output=out/out.txt
#SBATCH --time=00:30:00	
#SBATCH --mem=16G

IMAGE="ghcr.io/jan146/alma-hpcg:latest"
TMPDIR_BASE="/tmp/udocker-mpirun-$UID"
HPCG_ARGS="${HPCG_ARGS:-"--nx=16 --ny=16 --nz=16 --rt=10"}"
UDOCKER_EXEC_MODE="${UDOCKER_EXEC_MODE:-P1}"
OUTPUT_DIR="${HOME}/bench/hpcg/udocker/out_${UDOCKER_EXEC_MODE}"
CONT_NAME="hpcg_${UDOCKER_EXEC_MODE}"
HPCG_THREADS_PER_PROC="${HPCG_THREADS_PER_PROC:-1}"

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
        --env="OMP_NUM_THREADS=$HPCG_THREADS_PER_PROC" \
		--hostauth \
		--user="$USER" \
		"$CONT_NAME" \
			/out $HPCG_ARGS

mpirun \
	rm -rf "$TMPDIR_BASE"

udocker rm "$CONT_NAME"

cat "$OUTPUT_DIR"/HPCG-Benchmark*.txt
rm "$OUTPUT_DIR"/hpcg*.txt
rm "$OUTPUT_DIR"/HPCG-Benchmark*.txt

