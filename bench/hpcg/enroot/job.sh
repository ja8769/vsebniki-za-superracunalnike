#!/bin/bash

#SBATCH --job-name=hpcg
##SBATCH --reservation=psistemi
#SBATCH --output=out/out.txt
#SBATCH --time=00:30:00	
#SBATCH --mem=16G

IMAGE="${HOME}/enroot-images/alma-hpcg+latest.sqsh"
CONFIG_ENROOT_MPI="${HOME}/.config/enroot/mpi.conf"
TMPDIR_BASE="/tmp/enroot-mpirun-$UID"
OUTPUT_DIR="${HOME}/bench/hpcg/enroot/out"
HPCG_ARGS="${HPCG_ARGS:-"--nx=16 --ny=16 --nz=16 --rt=10"}"
HPCG_THREADS_PER_PROC="${HPCG_THREADS_PER_PROC:-1}"

module is-loaded OpenMPI/4.1.2 || \
	module load OpenMPI/4.1.2

mpirun sh -c "echo hostname: \$(hostname)"

mpirun \
    --mca orte_tmpdir_base "$TMPDIR_BASE" \
	enroot start \
        --env "OMP_NUM_THREADS=$HPCG_THREADS_PER_PROC" \
        --conf "$CONFIG_ENROOT_MPI" \
		--mount "${OUTPUT_DIR}:/out" \
		"$IMAGE" \
			/out $HPCG_ARGS

cat "$OUTPUT_DIR"/HPCG-Benchmark*.txt
rm "$OUTPUT_DIR"/hpcg*.txt
rm "$OUTPUT_DIR"/HPCG-Benchmark*.txt
