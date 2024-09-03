#!/bin/bash

#SBATCH --job-name=hpcg
##SBATCH --reservation=psistemi
#SBATCH --output=out/out.txt
#SBATCH --time=00:30:00
#SBATCH --mem=16G

IMAGE="${HOME}/apptainer-builds/alma-hpcg+latest.sif"
OUTPUT_DIR="${HOME}/bench/hpcg/apptainer/out"
HPCG_ARGS="${HPCG_ARGS:-"--nx=16 --ny=16 --nz=16 --rt=10"}"
HPCG_THREADS_PER_PROC="${HPCG_THREADS_PER_PROC:-1}"

module is-loaded OpenMPI/4.1.2 || \
	module load OpenMPI/4.1.2

mpirun sh -c "echo hostname: \$(hostname)"

mpirun \
	apptainer run \
        --env "OMP_NUM_THREADS=$HPCG_THREADS_PER_PROC" \
		"$IMAGE" \
            "$OUTPUT_DIR" $HPCG_ARGS

cat "$OUTPUT_DIR"/HPCG-Benchmark*.txt
rm "$OUTPUT_DIR"/hpcg*.txt
rm "$OUTPUT_DIR"/HPCG-Benchmark*.txt
